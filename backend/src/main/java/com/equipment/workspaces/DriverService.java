package com.equipment.workspaces;

import com.equipment.audit.Audit;
import com.equipment.common.ApiException;
import com.equipment.identity.Actor;
import com.equipment.notifications.NotificationService;
import java.util.*;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class DriverService {
    private final JdbcTemplate db;private final Access access;private final Audit audit;private final NotificationService notifications;
    public DriverService(JdbcTemplate db,Access access,Audit audit,NotificationService notifications){this.db=db;this.access=access;this.audit=audit;this.notifications=notifications;}
    private Map<String,Object> view(Map<String,Object> row){Map<String,Object> result=new LinkedHashMap<>();row.forEach((key,value)->{StringBuilder name=new StringBuilder();boolean upper=false;for(char c:key.toCharArray()){if(c=='_'){upper=true;continue;}name.append(upper?Character.toUpperCase(c):c);upper=false;}result.put(name.toString(),value instanceof java.sql.Timestamp timestamp?timestamp.toInstant().toString():value);});return result;}
    public UUID current(Actor actor,UUID workspace){Access.Member member=access.member(actor,workspace);if(!member.role().equals("DRIVER"))throw ApiException.missing();var rows=db.queryForList("select equipment_id from driver_assignment where workspace_id=? and driver_user_id=? and ended_at is null",workspace,actor.userId());return rows.isEmpty()?null:(UUID)rows.getFirst().get("equipment_id");}
    public UUID requireCurrent(Actor actor,UUID workspace){UUID equipment=current(actor,workspace);if(equipment==null)throw new ApiException(409,"NO_DRIVER_ASSIGNMENT","لا توجد معدة مسندة إليك حاليًا");return equipment;}
    /** Minimal picker data; drivers assigned outside the caller's scope are not eligible to move. */
    public List<Map<String,Object>> eligible(Actor actor,UUID workspace,UUID equipment){
        access.equipment(actor,workspace,equipment,"DRIVER_ASSIGNMENT_MANAGE");
        var target=db.queryForList("select archived_at from equipment where workspace_id=? and id=?",workspace,equipment);
        if(target.isEmpty())throw ApiException.missing();
        if(target.getFirst().get("archived_at")!=null)throw new ApiException(409,"EQUIPMENT_ARCHIVED","المعدة مؤرشفة");
        Access.Member caller=access.member(actor,workspace);
        String scope=caller.scope().equals("ALL_EQUIPMENT")?"":caller.scope().equals("SELECTED_EQUIPMENT")
            ?" and (a.equipment_id is null or exists(select 1 from membership_equipment me where me.workspace_id=m.workspace_id and me.user_id=? and me.equipment_id=a.equipment_id))"
            :caller.scope().equals("SELECTED_ORGANIZATIONS")
            ?" and (a.equipment_id is null or exists(select 1 from equipment_organization_assignment oa join membership_organization mo on mo.workspace_id=oa.workspace_id and mo.organization_id=oa.organization_id where oa.workspace_id=m.workspace_id and oa.equipment_id=a.equipment_id and oa.ended_at is null and mo.user_id=?))"
            :" and (a.equipment_id is null or exists(select 1 from driver_assignment mine where mine.workspace_id=m.workspace_id and mine.driver_user_id=? and mine.equipment_id=a.equipment_id and mine.ended_at is null))";
        String sql="select m.user_id,coalesce(m.display_name,u.name) as display_name,a.equipment_id as current_equipment_id,e.name as current_equipment_name,a.started_at from membership m join app_user u on u.id=m.user_id left join driver_assignment a on a.workspace_id=m.workspace_id and a.driver_user_id=m.user_id and a.ended_at is null left join equipment e on e.workspace_id=a.workspace_id and e.id=a.equipment_id where m.workspace_id=? and m.role='DRIVER' and m.active=true"+scope+" order by coalesce(m.display_name,u.name),m.user_id limit 100";
        Object[] args=scope.isEmpty()?new Object[]{workspace}:new Object[]{workspace,actor.userId()};
        return db.queryForList(sql,args).stream().map(this::view).toList();
    }
    /** Active assignment for an authorized equipment, including the name shown before replacement. */
    public Map<String,Object> equipmentAssignment(Actor actor,UUID workspace,UUID equipment){
        access.equipment(actor,workspace,equipment,"DRIVER_ASSIGNMENT_MANAGE");
        Boolean exists=db.queryForObject("select exists(select 1 from equipment where workspace_id=? and id=?)",Boolean.class,workspace,equipment);
        if(!Boolean.TRUE.equals(exists))throw ApiException.missing();
        var rows=db.queryForList("select a.id as assignment_id,a.driver_user_id,coalesce(m.display_name,u.name) as driver_name,a.started_at from driver_assignment a join membership m on m.workspace_id=a.workspace_id and m.user_id=a.driver_user_id join app_user u on u.id=a.driver_user_id where a.workspace_id=? and a.equipment_id=? and a.ended_at is null",workspace,equipment);
        Map<String,Object> result=new LinkedHashMap<>();result.put("equipmentId",equipment);
        result.put("assignmentId",rows.isEmpty()?null:rows.getFirst().get("assignment_id"));
        result.put("driverUserId",rows.isEmpty()?null:rows.getFirst().get("driver_user_id"));
        result.put("driverName",rows.isEmpty()?null:rows.getFirst().get("driver_name"));
        result.put("startedAt",rows.isEmpty()?null:((java.sql.Timestamp)rows.getFirst().get("started_at")).toInstant().toString());
        return result;
    }
    public List<Map<String,Object>> history(Actor actor,UUID workspace,UUID user){Access.Member member=access.require(actor,workspace,"DRIVER_ASSIGNMENT_MANAGE");return db.queryForList("select a.id,a.equipment_id,e.name as equipment_name,a.started_at,a.ended_at from driver_assignment a join equipment e on e.workspace_id=a.workspace_id and e.id=a.equipment_id where a.workspace_id=? and a.driver_user_id=? order by a.started_at desc limit 100",workspace,user).stream().filter(r->access.contains(member,workspace,(UUID)r.get("equipment_id"))).map(this::view).toList();}
    @Transactional public Map<String,Object> assign(Actor actor,UUID workspace,UUID driver,UUID equipment){access.equipment(actor,workspace,equipment,"DRIVER_ASSIGNMENT_MANAGE");if(driver==null||equipment==null)throw ApiException.invalid("اختر السائق والمعدة");db.queryForList("select pg_advisory_xact_lock(hashtextextended(?,0))","assign:"+workspace);var members=db.queryForList("select role from membership where workspace_id=? and user_id=? and active=true for update",workspace,driver);if(members.isEmpty()||!"DRIVER".equals(members.getFirst().get("role")))throw ApiException.missing();var rows=db.queryForList("select archived_at,name from equipment where workspace_id=? and id=? for update",workspace,equipment);if(rows.isEmpty())throw ApiException.missing();if(rows.getFirst().get("archived_at")!=null)throw new ApiException(409,"EQUIPMENT_ARCHIVED","المعدة مؤرشفة");Access.Member manager=access.member(actor,workspace);var currentAssignments=db.queryForList("select equipment_id from driver_assignment where workspace_id=? and driver_user_id=? and ended_at is null",workspace,driver);for(var active:currentAssignments)if(!access.contains(manager,workspace,(UUID)active.get("equipment_id")))throw ApiException.missing();var existing=db.queryForList("select id from driver_assignment where workspace_id=? and driver_user_id=? and equipment_id=? and ended_at is null",workspace,driver,equipment);if(!existing.isEmpty())return view(db.queryForMap("select * from driver_assignment where id=?",existing.getFirst().get("id")));db.update("update driver_assignment set ended_at=now() where workspace_id=? and ended_at is null and (driver_user_id=? or equipment_id=?)",workspace,driver,equipment);UUID id=UUID.randomUUID();db.update("insert into driver_assignment(id,workspace_id,driver_user_id,equipment_id,assigned_by) values(?,?,?,?,?)",id,workspace,driver,equipment,actor.userId());audit.record(workspace,actor.userId(),currentAssignments.isEmpty()?"DRIVER_ASSIGNED":"DRIVER_MOVED",id);if(!driver.equals(actor.userId()))notifications.event(workspace,driver,"DRIVER_ASSIGNED","EQUIPMENT",equipment,Map.of("equipmentName",rows.getFirst().get("name")));return view(db.queryForMap("select * from driver_assignment where id=?",id));}
    @Transactional public void unassign(Actor actor,UUID workspace,UUID equipment){access.equipment(actor,workspace,equipment,"DRIVER_ASSIGNMENT_MANAGE");db.queryForList("select pg_advisory_xact_lock(hashtextextended(?,0))","assign:"+workspace);int n=db.update("update driver_assignment set ended_at=now() where workspace_id=? and equipment_id=? and ended_at is null",workspace,equipment);if(n>0)audit.record(workspace,actor.userId(),"DRIVER_UNASSIGNED",equipment);}
}
