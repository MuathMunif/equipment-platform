package com.equipment.reports;

import com.equipment.common.ApiException;
import com.equipment.common.Values;
import com.equipment.finance.FinanceService;
import com.equipment.identity.Actor;
import com.equipment.workspaces.Access;
import java.math.BigDecimal;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.time.LocalDate;
import java.time.YearMonth;
import java.time.ZoneId;
import java.util.*;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class ReportService {
    private static final int SIZE=30;
    private static final ZoneId RIYADH=ZoneId.of("Asia/Riyadh");
    private static final BigDecimal ZERO=new BigDecimal("0.00");
    private final JdbcTemplate db;
    private final Access access;
    private final FinanceService finance;
    public ReportService(JdbcTemplate db,Access access,FinanceService finance){this.db=db;this.access=access;this.finance=finance;}
    public record Filter(String fromDate,String toDate,UUID equipmentId,UUID projectId,String entryType,String movementType,int page,boolean generalExpense){
        public Filter(String fromDate,String toDate,UUID equipmentId,UUID projectId,String entryType,String movementType,int page){this(fromDate,toDate,equipmentId,projectId,entryType,movementType,page,false);}
    }
    private record Scope(Access.Member member,String where,List<Object> args,LocalDate from,LocalDate to){}
    private String money(BigDecimal value){return value.setScale(2).toPlainString();}
    private BigDecimal amount(Object value){return value==null?ZERO:(BigDecimal)value;}
    private Scope scope(Actor actor,UUID workspace,Filter filter,boolean report,boolean dates){
        Access.Member member=access.require(actor,workspace,"FINANCE_VIEW");
        if(report&&!member.has("REPORT_VIEW"))throw ApiException.missing();
        if(filter.page()<0||filter.page()>100000)throw ApiException.invalid("رقم الصفحة غير صالح");
        if(filter.entryType()!=null&&!Set.of("INCOME","EXPENSE").contains(filter.entryType()))throw ApiException.invalid("نوع العملية غير صالح");
        if(filter.movementType()!=null&&!Set.of("SETTLEMENT","REFUND").contains(filter.movementType()))throw ApiException.invalid("نوع الحركة غير صالح");
        LocalDate from=null,to=null;
        if(dates){
            if(filter.fromDate()==null||filter.toDate()==null)throw ApiException.invalid("حدد بداية الفترة ونهايتها");
            from=Values.date(filter.fromDate());to=Values.date(filter.toDate());
            if(from.isAfter(to))throw ApiException.invalid("بداية الفترة بعد نهايتها");
        }else if(filter.fromDate()!=null||filter.toDate()!=null)throw ApiException.invalid("المتبقي الحالي لا يقبل فترة تاريخية");
        if(filter.generalExpense()&&filter.equipmentId()!=null)throw ApiException.invalid("اختر المصروف العام أو المعدة");
        if(filter.equipmentId()!=null){
            access.equipment(actor,workspace,filter.equipmentId(),"EQUIPMENT_VIEW");
            if(!Boolean.TRUE.equals(db.queryForObject("select exists(select 1 from equipment where workspace_id=? and id=?)",Boolean.class,workspace,filter.equipmentId())))throw ApiException.missing();
        }
        if(filter.projectId()!=null)access.project(actor,workspace,filter.projectId(),"PROJECT_VIEW");
        StringBuilder where=new StringBuilder("f.workspace_id=? and f.lifecycle='POSTED'");
        List<Object> args=new ArrayList<>();args.add(workspace);
        if(!member.scope().equals("ALL_EQUIPMENT")){where.append(" and ").append(access.financialPredicate(member));Collections.addAll(args,access.financialScopeArgs(member));where.append(" and f.expense_scope<>'GENERAL'");}
        if(filter.equipmentId()!=null){where.append(" and (f.equipment_id=? or exists(select 1 from expense_allocation x where x.workspace_id=f.workspace_id and x.entry_id=f.id and x.equipment_id=?))");args.add(filter.equipmentId());args.add(filter.equipmentId());}
        if(filter.projectId()!=null){where.append(" and f.project_id=?");args.add(filter.projectId());}
        if(filter.entryType()!=null){where.append(" and f.entry_type=?");args.add(filter.entryType());}
        if(filter.generalExpense())where.append(" and f.expense_scope='GENERAL'");
        return new Scope(member,where.toString(),args,from,to);
    }
    private void scan(String sql,List<Object> args,java.util.function.Consumer<Map<String,Object>> consumer){
        db.query(con->{PreparedStatement ps=con.prepareStatement(sql);ps.setFetchSize(256);for(int i=0;i<args.size();i++)ps.setObject(i+1,args.get(i));return ps;},rs->{
            while(rs.next()){
                Map<String,Object> row=new HashMap<>();var meta=rs.getMetaData();for(int i=1;i<=meta.getColumnCount();i++)row.put(meta.getColumnLabel(i),rs.getObject(i));consumer.accept(row);
            }return null;
        });
    }
    private static final class PageRows {
        final List<Map<String,Object>> items=new ArrayList<>();final int page;long total;
        PageRows(int page){this.page=page;}
        void add(Map<String,Object> row){long index=total++;if(index>=(long)page*SIZE&&index<(long)(page+1)*SIZE)items.add(row);}
        Map<String,Object> result(Map<String,Object> summary){return Map.of("summary",summary,"items",items,"page",page,"pageSize",SIZE,"total",total);}
    }
    private BigDecimal contribution(UUID workspace,Map<String,Object> row,UUID equipmentId,BigDecimal value,boolean movement){
        if(equipmentId==null||!"EXPENSE".equals(row.get("entry_type")))return value;
        if(!movement)return amount(row.get("allocation_amount"));
        return finance.movementShareDelta(workspace,(UUID)row.get("entry_id"),equipmentId,amount(row.get("entry_amount")),amount(row.get("prior_paid")),amount(row.get("prior_refunded")),amount(row.get("final_paid")),value,"REFUND".equals(row.get("movement_type")));
    }
    private List<Map<String,Object>> recordedGroups(Scope s,UUID equipmentId){
        List<Object> args=new ArrayList<>();
        if(equipmentId!=null)args.add(equipmentId);
        args.addAll(s.args());args.add(Date.valueOf(s.from()));args.add(Date.valueOf(s.to()));
        String join=equipmentId==null?"":" and a.equipment_id=?";
        String sql="select f.entry_type,coalesce(a.equipment_id,f.equipment_id) as group_equipment_id,e.name as equipment_name,sum(case when f.entry_type='EXPENSE' and f.expense_scope<>'GENERAL' then a.amount else f.amount end) as amount from financial_entry f left join expense_allocation a on a.workspace_id=f.workspace_id and a.entry_id=f.id"+join+" left join equipment e on e.workspace_id=f.workspace_id and e.id=coalesce(a.equipment_id,f.equipment_id) where "+s.where()+" and f.operation_date>=? and f.operation_date<=? group by f.entry_type,coalesce(a.equipment_id,f.equipment_id),e.name order by f.entry_type,group_equipment_id nulls first";
        var groups=new ArrayList<Map<String,Object>>();
        scan(sql,args,row->{Map<String,Object> group=new LinkedHashMap<>();group.put("entryType",row.get("entry_type"));group.put("equipmentId",row.get("group_equipment_id"));group.put("equipmentName",row.get("equipment_name"));group.put("generalExpense",row.get("group_equipment_id")==null);group.put("amount",money(amount(row.get("amount"))));groups.add(group);});
        return groups;
    }
    @Transactional(readOnly=true)
    public Map<String,Object> recorded(Actor actor,UUID workspace,Filter filter,boolean report){
        Scope s=scope(actor,workspace,filter,report,true);
        String allocation=filter.equipmentId()==null?"null::numeric as allocation_amount":"(select a.amount from expense_allocation a where a.workspace_id=f.workspace_id and a.entry_id=f.id and a.equipment_id=?) as allocation_amount";
        List<Object> args=new ArrayList<>();if(filter.equipmentId()!=null)args.add(filter.equipmentId());args.addAll(s.args());
        String sql="select f.id as entry_id,f.entry_type,f.amount as entry_amount,f.operation_date,f.expense_scope,f.equipment_id,e.name as equipment_name,f.party_name,"+allocation+" from financial_entry f left join equipment e on e.workspace_id=f.workspace_id and e.id=f.equipment_id where "+s.where()+" and f.operation_date>=? and f.operation_date<=? order by f.operation_date desc,f.id desc";
        args.add(Date.valueOf(s.from()));args.add(Date.valueOf(s.to()));
        BigDecimal[] totals={ZERO,ZERO};PageRows detail=new PageRows(filter.page());
        scan(sql,args,row->{
            BigDecimal share=contribution(workspace,row,filter.equipmentId(),amount(row.get("entry_amount")),false);
            if("INCOME".equals(row.get("entry_type")))totals[0]=totals[0].add(share);else totals[1]=totals[1].add(share);
            Map<String,Object> item=new LinkedHashMap<>();item.put("entryId",row.get("entry_id"));item.put("entryType",row.get("entry_type"));item.put("operationDate",row.get("operation_date").toString());item.put("amount",money(share));item.put("entryTotal",money(amount(row.get("entry_amount"))));item.put("expenseScope",row.get("expense_scope"));item.put("equipmentId",row.get("equipment_id"));item.put("equipmentName",row.get("equipment_name"));item.put("partyName",row.get("party_name"));detail.add(item);
        });
        Map<String,Object> summary=Map.of("recordedIncome",money(totals[0]),"recordedExpenses",money(totals[1]),"recordedDifference",money(totals[0].subtract(totals[1])),"fromDate",s.from().toString(),"toDate",s.to().toString(),"groups",recordedGroups(s,filter.equipmentId()));
        return detail.result(summary);
    }
    @Transactional(readOnly=true)
    public Map<String,Object> movements(Actor actor,UUID workspace,Filter filter){
        Scope s=scope(actor,workspace,filter,true,true);
        String sql="select f.id as entry_id,f.entry_type,f.amount as entry_amount,f.expense_scope,f.equipment_id,e.name as equipment_name,m.id as movement_id,m.movement_type,m.movement_date,m.amount as movement_amount,m.prior_paid,m.prior_refunded,m.final_paid from financial_entry f join lateral (select x.*,coalesce(sum(case when x.movement_type='SETTLEMENT' then x.amount else 0 end) over (order by x.movement_date,case when x.movement_type='SETTLEMENT' then 0 else 1 end,x.id rows between unbounded preceding and 1 preceding),0) as prior_paid,coalesce(sum(case when x.movement_type='REFUND' then x.amount else 0 end) over (order by x.movement_date,case when x.movement_type='SETTLEMENT' then 0 else 1 end,x.id rows between unbounded preceding and 1 preceding),0) as prior_refunded,coalesce(sum(case when x.movement_type='SETTLEMENT' then x.amount else 0 end) over (),0) as final_paid from (select id,'SETTLEMENT' as movement_type,paid_on as movement_date,amount from settlement where workspace_id=f.workspace_id and entry_id=f.id union all select id,'REFUND',refunded_on,amount from financial_refund where workspace_id=f.workspace_id and entry_id=f.id) x) m on true left join equipment e on e.workspace_id=f.workspace_id and e.id=f.equipment_id where "+s.where()+" and m.movement_date>=? and m.movement_date<=?"+(filter.movementType()==null?"":" and m.movement_type=?")+" order by m.movement_date desc,m.id desc";
        List<Object> args=new ArrayList<>(s.args());args.add(Date.valueOf(s.from()));args.add(Date.valueOf(s.to()));if(filter.movementType()!=null)args.add(filter.movementType());
        BigDecimal[] totals={ZERO,ZERO,ZERO,ZERO};PageRows detail=new PageRows(filter.page());
        scan(sql,args,row->{
            BigDecimal share=contribution(workspace,row,filter.equipmentId(),amount(row.get("movement_amount")),true);
            boolean income="INCOME".equals(row.get("entry_type")),refund="REFUND".equals(row.get("movement_type"));
            if(income){if(refund)totals[1]=totals[1].add(share);else totals[0]=totals[0].add(share);}else{if(refund)totals[3]=totals[3].add(share);else totals[2]=totals[2].add(share);}
            Map<String,Object> item=new LinkedHashMap<>();item.put("movementId",row.get("movement_id"));item.put("entryId",row.get("entry_id"));item.put("entryType",row.get("entry_type"));item.put("movementType",row.get("movement_type"));item.put("movementDate",row.get("movement_date").toString());item.put("amount",money(share));item.put("movementTotal",money(amount(row.get("movement_amount"))));item.put("entryTotal",money(amount(row.get("entry_amount"))));item.put("expenseScope",row.get("expense_scope"));item.put("equipmentId",row.get("equipment_id"));item.put("equipmentName",row.get("equipment_name"));detail.add(item);
        });
        Map<String,Object> summary=Map.of("collected",money(totals[0]),"incomeRefunds",money(totals[1]),"netCollected",money(totals[0].subtract(totals[1])),"paid",money(totals[2]),"expenseRefunds",money(totals[3]),"netPaid",money(totals[2].subtract(totals[3])),"fromDate",s.from().toString(),"toDate",s.to().toString());
        return detail.result(summary);
    }
    @Transactional(readOnly=true)
    public Map<String,Object> outstanding(Actor actor,UUID workspace,Filter filter){
        Scope s=scope(actor,workspace,filter,true,false);
        String allocation=filter.equipmentId()==null?"null::numeric as allocation_amount":"(select a.amount from expense_allocation a where a.workspace_id=f.workspace_id and a.entry_id=f.id and a.equipment_id=?) as allocation_amount";
        List<Object> args=new ArrayList<>();if(filter.equipmentId()!=null)args.add(filter.equipmentId());args.addAll(s.args());
        String sql="select f.id as entry_id,f.entry_type,f.amount as entry_amount,f.operation_date,f.due_date,f.party_name,f.expense_scope,f.equipment_id,e.name as equipment_name,"+allocation+",coalesce((select sum(x.amount) from settlement x where x.workspace_id=f.workspace_id and x.entry_id=f.id),0) as settled,coalesce((select sum(x.amount) from financial_refund x where x.workspace_id=f.workspace_id and x.entry_id=f.id),0) as refunded from financial_entry f left join equipment e on e.workspace_id=f.workspace_id and e.id=f.equipment_id where "+s.where()+" order by f.due_date nulls last,f.operation_date,f.id";
        BigDecimal[] totals={ZERO,ZERO};PageRows detail=new PageRows(filter.page());
        LocalDate today=LocalDate.now(RIYADH);
        scan(sql,args,row->{
            BigDecimal total=amount(row.get("entry_amount")),net=amount(row.get("settled")).subtract(amount(row.get("refunded"))),remaining=total.subtract(net);
            if(filter.equipmentId()!=null&&"EXPENSE".equals(row.get("entry_type"))){
                // M2 bounds net shares by gross shares, including fractional-cent refund cases.
                remaining=finance.remainingShare(workspace,(UUID)row.get("entry_id"),filter.equipmentId(),total,amount(row.get("settled")),amount(row.get("refunded")));
            }
            if(remaining.signum()<=0)return;
            if("INCOME".equals(row.get("entry_type")))totals[0]=totals[0].add(remaining);else totals[1]=totals[1].add(remaining);
            Date due=(Date)row.get("due_date");Map<String,Object> item=new LinkedHashMap<>();item.put("entryId",row.get("entry_id"));item.put("entryType",row.get("entry_type"));item.put("operationDate",row.get("operation_date").toString());item.put("dueDate",due==null?null:due.toString());item.put("overdue",due!=null&&due.toLocalDate().isBefore(today));item.put("partyName",row.get("party_name"));item.put("remaining",money(remaining));item.put("entryTotal",money(total));item.put("expenseScope",row.get("expense_scope"));item.put("equipmentId",row.get("equipment_id"));item.put("equipmentName",row.get("equipment_name"));detail.add(item);
        });
        return detail.result(Map.of("receivable",money(totals[0]),"payable",money(totals[1]),"asOfDate",today.toString()));
    }
    @Transactional(readOnly=true)
    public Map<String,Object> dashboard(Actor actor,UUID workspace,String month){
        Access.Member member=access.member(actor,workspace);
        if(!member.has("EQUIPMENT_VIEW")&&!member.has("FINANCE_VIEW"))throw ApiException.missing();
        YearMonth selected;
        try{selected=month==null?YearMonth.now(RIYADH):YearMonth.parse(month);}catch(Exception ex){throw ApiException.invalid("الشهر غير صالح");}
        Map<String,Object> result=new LinkedHashMap<>();result.put("month",selected.toString());result.put("fromDate",selected.atDay(1).toString());result.put("toDate",selected.atEndOfMonth().toString());
        if(member.has("EQUIPMENT_VIEW")){
            String equipmentScope=access.equipmentPredicate(member,"equipment");
            long count=member.scope().equals("ALL_EQUIPMENT")
                ?db.queryForObject("select count(*) from equipment where workspace_id=? and archived_at is null",Long.class,workspace)
                :db.queryForObject("select count(*) from equipment where workspace_id=? and archived_at is null and "+equipmentScope,Long.class,workspace,member.userId());
            result.put("activeEquipmentCount",count);
        }
        if(member.has("FINANCE_VIEW")){
            Filter filter=new Filter(selected.atDay(1).toString(),selected.atEndOfMonth().toString(),null,null,null,null,0);
            @SuppressWarnings("unchecked") Map<String,Object> recorded=(Map<String,Object>)recorded(actor,workspace,filter,false).get("summary");
            result.put("summary",Map.of("recordedIncome",recorded.get("recordedIncome"),"recordedExpenses",recorded.get("recordedExpenses"),"recordedDifference",recorded.get("recordedDifference"),"fromDate",recorded.get("fromDate"),"toDate",recorded.get("toDate")));
            String condition=member.scope().equals("ALL_EQUIPMENT")?"":" and "+access.financialPredicate(member)+" and f.expense_scope<>'GENERAL'";
            List<Object> args=new ArrayList<>();args.add(workspace);if(!condition.isEmpty())Collections.addAll(args,access.financialScopeArgs(member));
            var recent=db.queryForList("select f.id as entry_id,f.entry_type,f.amount,f.operation_date from financial_entry f where f.workspace_id=? and f.lifecycle='POSTED'"+condition+" order by f.created_at desc,f.id desc limit 5",args.toArray());
            result.put("recentEntries",recent.stream().map(row->Map.of("entryId",row.get("entry_id"),"entryType",row.get("entry_type"),"amount",money(amount(row.get("amount"))),"operationDate",row.get("operation_date").toString())).toList());
        }
        return result;
    }
}
