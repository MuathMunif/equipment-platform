package com.equipment.attachments;

import java.io.IOException;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

public interface ObjectStorageService {
    record CleanupCandidate(UUID workspaceId,String key,boolean temporary) {}
    void putImmutable(String key,byte[] content) throws IOException;
    byte[] read(String key) throws IOException;
    List<CleanupCandidate> cleanupCandidatesOlderThan(Instant cutoff) throws IOException;
    void deleteIfExists(String key) throws IOException;
}
