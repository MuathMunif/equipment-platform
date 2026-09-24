package com.equipment.audit;

import java.util.UUID;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

@Component
public class Audit {
    private final JdbcTemplate db;
    public Audit(JdbcTemplate db) { this.db=db; }
    public void record(UUID workspace, UUID actor, String action, UUID resource) {
        db.update("insert into audit_event(id,workspace_id,actor_id,action,resource_id) values(?,?,?,?,?)",UUID.randomUUID(),workspace,actor,action,resource);
    }
}
