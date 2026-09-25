package com.equipment.workspaces;

import com.equipment.common.ApiException;
import com.equipment.identity.Actor;
import java.sql.Array;
import java.sql.SQLException;
import java.util.*;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

/** Effective workspace access is read from the database for every request. */
@Component
public class Access {
    public static final Set<String> CAPABILITIES=Set.of("EQUIPMENT_VIEW","EQUIPMENT_MANAGE","FINANCE_VIEW","FINANCE_MANAGE","FINANCE_REVIEW","DOCUMENT_VIEW","DOCUMENT_MANAGE","ISSUE_VIEW","ISSUE_MANAGE","MAINTENANCE_VIEW","MAINTENANCE_MANAGE","DRIVER_ASSIGNMENT_MANAGE","REPORT_VIEW","TEAM_MANAGE");
    private final JdbcTemplate db;
    public Access(JdbcTemplate db) { this.db=db; }
    public static Set<String> defaults(String role) {
        return switch(role) {
            case "OWNER" -> CAPABILITIES;
            case "MANAGER" -> Set.of("EQUIPMENT_VIEW","EQUIPMENT_MANAGE","FINANCE_VIEW","FINANCE_MANAGE","FINANCE_REVIEW","DOCUMENT_VIEW","DOCUMENT_MANAGE","ISSUE_VIEW","ISSUE_MANAGE","MAINTENANCE_VIEW","MAINTENANCE_MANAGE","DRIVER_ASSIGNMENT_MANAGE","REPORT_VIEW");
            case "ACCOUNTANT" -> Set.of("EQUIPMENT_VIEW","FINANCE_VIEW","FINANCE_MANAGE","FINANCE_REVIEW","DOCUMENT_VIEW","DOCUMENT_MANAGE","ISSUE_VIEW","ISSUE_MANAGE","MAINTENANCE_VIEW","MAINTENANCE_MANAGE","REPORT_VIEW");
            case "DRIVER" -> Set.of("EQUIPMENT_VIEW","ISSUE_VIEW","ISSUE_MANAGE","MAINTENANCE_VIEW","FINANCE_MANAGE");
            default -> throw ApiException.invalid("الدور غير صالح");
        };
    }
    public record Member(UUID userId,String role,Set<String> capabilities,String scope,String financialMode) { public boolean has(String capability){return role.equals("OWNER")||capabilities.contains(capability);} }
    public Member member(Actor actor,UUID workspace) {
        var rows=db.queryForList("select role,capabilities,scope,financial_mode from membership where workspace_id=? and user_id=? and active=true",workspace,actor.userId());
        if(rows.isEmpty())throw ApiException.missing();
        var row=rows.getFirst();String role=(String)row.get("role");Set<String> capabilities=new HashSet<>();
        if(row.get("capabilities") instanceof Array array)try{capabilities.addAll(Arrays.asList((String[])array.getArray()));}catch(SQLException ex){throw new IllegalStateException(ex);}
        if(role.equals("OWNER"))capabilities.addAll(CAPABILITIES);
        return new Member(actor.userId(),role,Set.copyOf(capabilities),(String)row.get("scope"),(String)row.get("financial_mode"));
    }
    public Member require(Actor actor,UUID workspace,String capability){Member m=member(actor,workspace);if(!m.has(capability))throw ApiException.missing();return m;}
    public void owner(Actor actor,UUID workspace){if(!member(actor,workspace).role().equals("OWNER"))throw ApiException.missing();}
    public void equipment(Actor actor,UUID workspace,UUID equipment,String capability){Member m=require(actor,workspace,capability);if(equipment==null||!contains(m,workspace,equipment))throw ApiException.missing();}
    public boolean contains(Member m,UUID workspace,UUID equipment) {
        if(equipment==null)return false;
        if(m.role().equals("OWNER")||m.scope().equals("ALL_EQUIPMENT"))return true;
        if(m.scope().equals("ASSIGNED_EQUIPMENT"))return Boolean.TRUE.equals(db.queryForObject("select exists(select 1 from driver_assignment where workspace_id=? and driver_user_id=? and equipment_id=? and ended_at is null)",Boolean.class,workspace,m.userId(),equipment));
        return Boolean.TRUE.equals(db.queryForObject("select exists(select 1 from membership_equipment where workspace_id=? and user_id=? and equipment_id=?)",Boolean.class,workspace,m.userId(),equipment));
    }
    public String equipmentPredicate(Member m,String alias){
        if(!Set.of("i","m","d","s").contains(alias))throw new IllegalArgumentException("alias");
        if(m.scope().equals("ALL_EQUIPMENT"))return "true";
        if(m.scope().equals("ASSIGNED_EQUIPMENT"))return "exists(select 1 from driver_assignment scope_row where scope_row.workspace_id="+alias+".workspace_id and scope_row.equipment_id="+alias+".equipment_id and scope_row.driver_user_id=? and scope_row.ended_at is null)";
        return "exists(select 1 from membership_equipment scope_row where scope_row.workspace_id="+alias+".workspace_id and scope_row.equipment_id="+alias+".equipment_id and scope_row.user_id=?)";
    }
    public void resource(Actor actor,UUID workspace,String table,UUID id,String capability){
        if(!Set.of("equipment_issue","maintenance_record","equipment_document").contains(table))throw new IllegalArgumentException("unsupported resource");
        Member m=require(actor,workspace,capability);var rows=db.queryForList("select equipment_id from "+table+" where workspace_id=? and id=?",workspace,id);
        if(rows.isEmpty()||!contains(m,workspace,(UUID)rows.getFirst().get("equipment_id")))throw ApiException.missing();
    }
    public boolean financial(Member m,UUID workspace,UUID entryId){
        var rows=db.queryForList("select equipment_id,expense_scope,entry_type from financial_entry where workspace_id=? and id=?",workspace,entryId);if(rows.isEmpty())return false;
        var row=rows.getFirst();if(m.role().equals("DRIVER")&&(!"EXPENSE".equals(row.get("entry_type"))||!"SINGLE".equals(row.get("expense_scope"))))return false;if(m.scope().equals("ALL_EQUIPMENT"))return true;if("GENERAL".equals(row.get("expense_scope")))return false;
        if("SHARED".equals(row.get("expense_scope"))) {var allocations=db.queryForList("select equipment_id from expense_allocation where workspace_id=? and entry_id=?",workspace,entryId);return !allocations.isEmpty()&&allocations.stream().allMatch(a->contains(m,workspace,(UUID)a.get("equipment_id")));}
        return contains(m,workspace,(UUID)row.get("equipment_id"));
    }
    public void financial(Actor actor,UUID workspace,UUID entryId,String capability){Member m=require(actor,workspace,capability);if(!financial(m,workspace,entryId))throw ApiException.missing();}
    public void directFinancialEntry(Actor actor,UUID workspace,UUID entryId){Member m=require(actor,workspace,"FINANCE_MANAGE");if(!"DIRECT".equals(m.financialMode())||!financial(m,workspace,entryId))throw ApiException.missing();}
    /** SQL predicate for alias f; caller adds member user id for each returned placeholder. */
    public String financialPredicate(Member m){
        if(m.scope().equals("ALL_EQUIPMENT"))return m.role().equals("DRIVER")?"(f.entry_type='EXPENSE' and f.expense_scope='SINGLE')":"true";
        String authorized=m.scope().equals("ASSIGNED_EQUIPMENT")
            ?"exists(select 1 from driver_assignment s where s.workspace_id=f.workspace_id and s.driver_user_id=? and s.equipment_id=%s and s.ended_at is null)"
            :"exists(select 1 from membership_equipment s where s.workspace_id=f.workspace_id and s.user_id=? and s.equipment_id=%s)";
        String result="(f.expense_scope<>'GENERAL' and ((f.expense_scope='SHARED' and exists(select 1 from expense_allocation aa where aa.workspace_id=f.workspace_id and aa.entry_id=f.id) and not exists(select 1 from expense_allocation aa where aa.workspace_id=f.workspace_id and aa.entry_id=f.id and not "+authorized.formatted("aa.equipment_id")+")) or (f.expense_scope<>'SHARED' and "+authorized.formatted("f.equipment_id")+")))";
        return m.role().equals("DRIVER")?"(f.entry_type='EXPENSE' and f.expense_scope='SINGLE' and "+result+")":result;
    }
    public void directFinance(Actor actor,UUID workspace,UUID equipment,String type,String scope){Member m=require(actor,workspace,"FINANCE_MANAGE");if(!m.financialMode().equals("DIRECT"))throw ApiException.missing();if(m.role().equals("DRIVER")&&(!"EXPENSE".equals(type)||!"SINGLE".equals(scope)))throw ApiException.missing();if(!m.scope().equals("ALL_EQUIPMENT")&&"GENERAL".equals(scope))throw ApiException.missing();if(equipment!=null&&!contains(m,workspace,equipment))throw ApiException.missing();}
}
