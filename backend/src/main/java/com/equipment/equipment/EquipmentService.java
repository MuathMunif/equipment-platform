package com.equipment.equipment;

import com.equipment.audit.Audit;
import com.equipment.common.*;
import com.equipment.identity.Actor;
import com.equipment.notifications.NotificationService;
import com.equipment.workspaces.Access;
import java.util.*;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class EquipmentService {
    private final JdbcTemplate db; private final Access access; private final Idempotency retries; private final Audit audit; private final NotificationService notifications;
    public EquipmentService(JdbcTemplate db,Access access,Idempotency retries,Audit audit,NotificationService notifications) { this.db=db; this.access=access; this.retries=retries; this.audit=audit; this.notifications=notifications; }
    public record Equipment(UUID id,String reference,String name,String model,String createdAt,String archivedAt) {}
    public record Create(String name,String model) {}
    public Equipment get(Actor actor,UUID workspace,UUID id) { access.equipment(actor,workspace,id,"EQUIPMENT_VIEW"); return require(workspace,id); }
    public Equipment require(UUID workspace,UUID id) {
        var rows=db.query("select * from equipment where workspace_id=? and id=?",(rs,n)->new Equipment(rs.getObject("id",UUID.class),"EQ-"+String.format("%06d",rs.getLong("reference")),rs.getString("name"),rs.getString("model"),rs.getTimestamp("created_at").toInstant().toString(),rs.getTimestamp("archived_at")==null?null:rs.getTimestamp("archived_at").toInstant().toString()),workspace,id);
        if(rows.isEmpty()) throw ApiException.missing(); return rows.getFirst();
    }
    public Map<String,Object> list(Actor actor,UUID workspace,int page,String search) {
        Access.Member member=access.require(actor,workspace,"EQUIPMENT_VIEW"); if(page<0 || page>100000) throw ApiException.invalid("رقم الصفحة غير صالح");
        String term=search==null?"":search.trim(); if(term.length()>100) throw ApiException.invalid("اختصر نص البحث");
        String like="%"+term.replace("\\","\\\\").replace("%","\\%").replace("_","\\_")+"%";
        String scope=member.scope().equals("ALL_EQUIPMENT")?"":member.scope().equals("ASSIGNED_EQUIPMENT")?" and exists(select 1 from driver_assignment da where da.workspace_id=equipment.workspace_id and da.equipment_id=equipment.id and da.driver_user_id=? and da.ended_at is null)":" and exists(select 1 from membership_equipment me where me.workspace_id=equipment.workspace_id and me.equipment_id=equipment.id and me.user_id=?)";
        Object[] args=scope.isEmpty()?new Object[]{workspace,like,like,page*30}:new Object[]{workspace,like,like,member.userId(),page*30};
        var rows=db.query("select * from equipment where workspace_id=? and (name ilike ? or ('EQ-'||lpad(reference::text,6,'0')) ilike ?)"+scope+" order by created_at desc,id desc limit 30 offset ?",(rs,n)->new Equipment(rs.getObject("id",UUID.class),"EQ-"+String.format("%06d",rs.getLong("reference")),rs.getString("name"),rs.getString("model"),rs.getTimestamp("created_at").toInstant().toString(),rs.getTimestamp("archived_at")==null?null:rs.getTimestamp("archived_at").toInstant().toString()),args);
        Object[] countArgs=scope.isEmpty()?new Object[]{workspace,like,like}:new Object[]{workspace,like,like,member.userId()};
        Long count=db.queryForObject("select count(*) from equipment where workspace_id=? and (name ilike ? or ('EQ-'||lpad(reference::text,6,'0')) ilike ?)"+scope,Long.class,countArgs);
        return Map.of("items",rows,"page",page,"pageSize",30,"total",count);
    }
    @Transactional
    public Equipment archive(Actor actor,UUID workspace,UUID id) {
        access.equipment(actor,workspace,id,"EQUIPMENT_MANAGE");require(workspace,id);
        if(db.update("update equipment set archived_at=now(),archived_by=? where workspace_id=? and id=? and archived_at is null",actor.userId(),workspace,id)==1){db.update("update driver_assignment set ended_at=now() where workspace_id=? and equipment_id=? and ended_at is null",workspace,id);audit.record(workspace,actor.userId(),"EQUIPMENT_ARCHIVED",id);}
        return require(workspace,id);
    }
    @Transactional
    public Equipment restore(Actor actor,UUID workspace,UUID id) {
        access.equipment(actor,workspace,id,"EQUIPMENT_MANAGE");require(workspace,id);
        if(db.update("update equipment set archived_at=null,archived_by=null where workspace_id=? and id=? and archived_at is not null",workspace,id)==1) { audit.record(workspace,actor.userId(),"EQUIPMENT_RESTORED",id); notifications.equipmentRestored(workspace,id); }
        return require(workspace,id);
    }
    @Transactional
    public Equipment create(Actor actor,UUID workspace,String key,Create request) {
        Access.Member member=access.require(actor,workspace,"EQUIPMENT_MANAGE");if(!member.scope().equals("ALL_EQUIPMENT"))throw ApiException.missing(); String name=Values.text(request.name(),100,"اسم المعدة"),model=Values.text(request.model(),100,"الموديل");
        UUID id=retries.execute(workspace,actor.userId(),"equipment.create",key,Values.payload(name,model),()->{
            UUID created=UUID.randomUUID(); db.update("insert into equipment(id,workspace_id,name,model,created_by) values(?,?,?,?,?)",created,workspace,name,model,actor.userId());
            audit.record(workspace,actor.userId(),"EQUIPMENT_CREATED",created); return created;
        }); return require(workspace,id);
    }
}
