package com.equipment.workspaces;

import com.equipment.common.ApiException;
import com.equipment.identity.Actor;
import java.util.UUID;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

@Component
public class Access {
    private final JdbcTemplate db;
    public Access(JdbcTemplate db) { this.db=db; }
    public void owner(Actor actor,UUID workspace) {
        Boolean allowed=db.queryForObject("select exists(select 1 from membership where workspace_id=? and user_id=? and role='OWNER' and active=true)",Boolean.class,workspace,actor.userId());
        if(!Boolean.TRUE.equals(allowed)) throw ApiException.missing();
    }
}
