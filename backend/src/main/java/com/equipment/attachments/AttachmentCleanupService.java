package com.equipment.attachments;

import com.equipment.common.DevelopmentBoundary;
import java.io.IOException;
import java.time.Duration;
import java.time.Instant;
import java.sql.Timestamp;
import java.util.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Profile;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.support.TransactionTemplate;

/** Cleans only development disk objects and non-historical attachment records. */
@Component
@Profile("dev")
@ConditionalOnProperty(prefix="app",name="attachment-cleanup-enabled",havingValue="true",matchIfMissing=true)
public class AttachmentCleanupService {
    private static final Logger LOG=LoggerFactory.getLogger(AttachmentCleanupService.class);
    private final JdbcTemplate db;
    private final TransactionTemplate transactions;
    private final ObjectStorageService storage;
    private final Duration retention;
    public record Result(int recordsRemoved,int objectsRemoved,int failures) {}
    private record StaleAttachment(UUID workspace,UUID id,String objectKey) {}
    public AttachmentCleanupService(JdbcTemplate db,TransactionTemplate transactions,ObjectStorageService storage,DevelopmentBoundary boundary,@Value("${app.attachment-retention-days:7}") long retentionDays) {
        if(retentionDays<1 || retentionDays>3650) throw new IllegalArgumentException("Attachment retention must be 1..3650 days");
        this.db=db;this.transactions=transactions;this.storage=storage;this.retention=Duration.ofDays(retentionDays);
    }
    @Scheduled(fixedDelayString="${app.attachment-cleanup-interval-ms:86400000}",initialDelayString="${app.attachment-cleanup-interval-ms:86400000}")
    public void scheduledCleanup() {
        Result result=clean(Instant.now());
        if(result.recordsRemoved()>0 || result.objectsRemoved()>0 || result.failures()>0) LOG.info("Development attachment cleanup: {} records, {} objects, {} failures",result.recordsRemoved(),result.objectsRemoved(),result.failures());
    }
    /** The supplied clock makes retention tests deterministic. Each run removes at most 100 DB rows. */
    public synchronized Result clean(Instant now) {
        Instant cutoff=Objects.requireNonNull(now).minus(retention);
        List<StaleAttachment> removed=transactions.execute(status->{
            var rows=db.queryForList("select a.workspace_id,a.id,a.object_key from attachment a join financial_entry f on f.workspace_id=a.workspace_id and f.id=a.entry_id where ((a.state in ('PENDING','FAILED') and a.updated_at<?) or (f.lifecycle='DISCARDED' and f.discarded_at<?)) order by a.updated_at,a.id limit 100 for update of a skip locked",Timestamp.from(cutoff),Timestamp.from(cutoff));
            var deleted=new ArrayList<StaleAttachment>();
            for(var row:rows) {
                UUID workspace=(UUID)row.get("workspace_id"),id=(UUID)row.get("id");
                int count=db.update("delete from attachment a where a.workspace_id=? and a.id=? and ((a.state in ('PENDING','FAILED') and a.updated_at<?) or exists (select 1 from financial_entry f where f.workspace_id=a.workspace_id and f.id=a.entry_id and f.lifecycle='DISCARDED' and f.discarded_at<?))",workspace,id,Timestamp.from(cutoff),Timestamp.from(cutoff));
                if(count==1) deleted.add(new StaleAttachment(workspace,id,(String)row.get("object_key")));
            }
            return deleted;
        });
        int objects=0,failures=0;
        for(var row:Objects.requireNonNull(removed)) {
            if(row.objectKey()==null) continue;
            if(!row.objectKey().startsWith(row.workspace()+"/"+row.id()+"/")) {
                failures++; LOG.warn("Skipped attachment object with mismatched workspace or attachment ID {}",row.id()); continue;
            }
            try { storage.deleteIfExists(row.objectKey()); objects++; }
            catch(IOException e) { failures++; LOG.warn("Could not delete stale development attachment object {}",row.id(),e); }
        }
        try {
            for(var candidate:storage.cleanupCandidatesOlderThan(cutoff)) {
                if(!candidate.temporary()) {
                    Long references=db.queryForObject("select count(*) from attachment where workspace_id=? and object_key=?",Long.class,candidate.workspaceId(),candidate.key());
                    if(references!=null && references>0) continue;
                    UUID attachmentId=UUID.fromString(candidate.key().substring(37,73));
                    Long inProgress=db.queryForObject("select count(*) from attachment where workspace_id=? and id=?",Long.class,candidate.workspaceId(),attachmentId);
                    if(inProgress!=null && inProgress>0) continue;
                }
                try { storage.deleteIfExists(candidate.key()); objects++; }
                catch(IOException e) { failures++; LOG.warn("Could not delete orphan development object in workspace {}",candidate.workspaceId(),e); }
            }
        } catch(IOException e) { failures++; LOG.warn("Could not enumerate development attachment objects",e); }
        return new Result(removed.size(),objects,failures);
    }
}
