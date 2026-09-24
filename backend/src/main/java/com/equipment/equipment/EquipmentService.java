package com.equipment.equipment;

import com.equipment.audit.Audit;
import com.equipment.common.*;
import com.equipment.identity.Actor;
import com.equipment.workspaces.Access;
import java.util.*;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class EquipmentService {
    private final JdbcTemplate db; private final Access access; private final Idempotency retries; private final Audit audit;
    public EquipmentService(JdbcTemplate db,Access access,Idempotency retries,Audit audit) { this.db=db; this.access=access; this.retries=retries; this.audit=audit; }
    public record Equipment(UUID id,String reference,String name,String model,String createdAt) {}
    public record Create(String name,String model) {}
    public Equipment get(Actor actor,UUID workspace,UUID id) { access.owner(actor,workspace); return require(workspace,id); }
    public Equipment require(UUID workspace,UUID id) {
        var rows=db.query("select * from equipment where workspace_id=? and id=?",(rs,n)->new Equipment(rs.getObject("id",UUID.class),"EQ-"+String.format("%06d",rs.getLong("reference")),rs.getString("name"),rs.getString("model"),rs.getTimestamp("created_at").toInstant().toString()),workspace,id);
        if(rows.isEmpty()) throw ApiException.missing(); return rows.getFirst();
    }
    public Map<String,Object> list(Actor actor,UUID workspace,int page,String search) {
        access.owner(actor,workspace); if(page<0 || page>100000) throw ApiException.invalid("رقم الصفحة غير صالح");
        String term=search==null?"":search.trim(); if(term.length()>100) throw ApiException.invalid("اختصر نص البحث");
        String like="%"+term.replace("\\","\\\\").replace("%","\\%").replace("_","\\_")+"%";
        var rows=db.query("select * from equipment where workspace_id=? and (name ilike ? or ('EQ-'||lpad(reference::text,6,'0')) ilike ?) order by created_at desc,id desc limit 30 offset ?",(rs,n)->new Equipment(rs.getObject("id",UUID.class),"EQ-"+String.format("%06d",rs.getLong("reference")),rs.getString("name"),rs.getString("model"),rs.getTimestamp("created_at").toInstant().toString()),workspace,like,like,page*30);
        Long count=db.queryForObject("select count(*) from equipment where workspace_id=? and (name ilike ? or ('EQ-'||lpad(reference::text,6,'0')) ilike ?)",Long.class,workspace,like,like);
        return Map.of("items",rows,"page",page,"pageSize",30,"total",count);
    }
    @Transactional
    public Equipment create(Actor actor,UUID workspace,String key,Create request) {
        access.owner(actor,workspace); String name=Values.text(request.name(),100,"اسم المعدة"),model=Values.text(request.model(),100,"الموديل");
        UUID id=retries.execute(workspace,actor.userId(),"equipment.create",key,Values.payload(name,model),()->{
            UUID created=UUID.randomUUID(); db.update("insert into equipment(id,workspace_id,name,model,created_by) values(?,?,?,?,?)",created,workspace,name,model,actor.userId());
            audit.record(workspace,actor.userId(),"EQUIPMENT_CREATED",created); return created;
        }); return require(workspace,id);
    }
}
