package com.equipment.common;

import java.util.UUID;
import java.util.function.Supplier;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

@Component
public class Idempotency {
    private final JdbcTemplate db;
    public Idempotency(JdbcTemplate db) { this.db=db; }
    /** Caller supplies a transaction and performs current authorization before entering this method. */
    public UUID execute(UUID workspace, UUID actor, String operation, String key, String payload, Supplier<UUID> create) {
        if(key==null || !key.matches("[a-zA-Z0-9_-]{8,100}")) throw ApiException.invalid("مفتاح حفظ الطلب غير صالح");
        String scope=workspace+":"+actor+":"+operation+":"+key;
        db.queryForList("select pg_advisory_xact_lock(hashtextextended(?,0))", scope);
        var existing=db.queryForList("select payload_hash,resource_id from idempotency_record where workspace_id=? and actor_id=? and operation=? and request_key=?",workspace,actor,operation,key);
        String hash=Values.hash(payload);
        if(!existing.isEmpty()) {
            var row=existing.getFirst();
            if(!row.get("payload_hash").equals(hash)) throw new ApiException(409,"IDEMPOTENCY_CONFLICT","هذا الطلب محفوظ ببيانات مختلفة؛ افتح السجل قبل إعادة الحفظ");
            return (UUID) row.get("resource_id");
        }
        UUID id=create.get();
        db.update("insert into idempotency_record(workspace_id,actor_id,operation,request_key,payload_hash,resource_id) values(?,?,?,?,?,?)",workspace,actor,operation,key,hash,id);
        return id;
    }
}
