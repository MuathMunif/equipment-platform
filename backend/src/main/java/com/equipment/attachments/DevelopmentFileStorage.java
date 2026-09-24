package com.equipment.attachments;

import com.equipment.common.DevelopmentBoundary;
import java.io.IOException;
import java.nio.file.*;
import java.time.Instant;
import java.util.*;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

/** Isolated dev adapter only. Production does not fall back to application disk. */
@Component
public class DevelopmentFileStorage implements ObjectStorageService {
    private final Path root;
    public DevelopmentFileStorage(@Value("${app.storage-root}") String root,DevelopmentBoundary boundary) throws IOException {
        this.root=Path.of(root).toAbsolutePath().normalize(); Files.createDirectories(this.root);
    }
    private Path path(String key) throws IOException {
        if(key==null || !key.matches("[a-f0-9-]{36}/[a-f0-9-]{36}/[a-f0-9]{64}")) throw new IOException("Invalid internal object key");
        Path path=root.resolve(key).normalize();
        if(!path.startsWith(root) || Files.isSymbolicLink(path.getParent().getParent()) || Files.isSymbolicLink(path.getParent()) || Files.isSymbolicLink(path)) throw new IOException("Invalid object path");
        return path;
    }
    private Path cleanupPath(String key) throws IOException {
        if(key==null || !key.matches("[a-f0-9-]{36}/[a-f0-9-]{36}/(?:[a-f0-9]{64}|pending-[a-zA-Z0-9-]+\\.tmp)")) throw new IOException("Invalid cleanup key");
        Path target=root.resolve(key).normalize();
        if(!target.startsWith(root) || Files.isSymbolicLink(target.getParent()) || Files.isSymbolicLink(target.getParent().getParent()) || Files.isSymbolicLink(target)) throw new IOException("Unsafe cleanup path");
        return target;
    }
    @Override public void putImmutable(String key,byte[] content) throws IOException {
        Path target=path(key); Files.createDirectories(target.getParent());
        if(Files.exists(target)) {
            if(!java.security.MessageDigest.isEqual(Files.readAllBytes(target),content)) throw new IOException("Immutable object differs"); return;
        }
        Path temp=Files.createTempFile(target.getParent(),"pending-",".tmp");
        try { Files.write(temp,content); Files.move(temp,target,StandardCopyOption.ATOMIC_MOVE); }
        finally { Files.deleteIfExists(temp); }
    }
    @Override public byte[] read(String key) throws IOException { return Files.readAllBytes(path(key)); }
    @Override public List<CleanupCandidate> cleanupCandidatesOlderThan(Instant cutoff) throws IOException {
        var candidates=new ArrayList<CleanupCandidate>();
        try(var files=Files.walk(root,3)) {
            for(Path file:files.filter(path->Files.isRegularFile(path,LinkOption.NOFOLLOW_LINKS)).toList()) {
                if(!Files.getLastModifiedTime(file,LinkOption.NOFOLLOW_LINKS).toInstant().isBefore(cutoff)) continue;
                String key=root.relativize(file).toString().replace('\\','/');
                if(!key.matches("[a-f0-9-]{36}/[a-f0-9-]{36}/(?:[a-f0-9]{64}|pending-[a-zA-Z0-9-]+\\.tmp)")) continue;
                try {
                    UUID workspace=UUID.fromString(key.substring(0,36));
                    UUID.fromString(key.substring(37,73));
                    candidates.add(new CleanupCandidate(workspace,key,key.substring(key.lastIndexOf('/')+1).startsWith("pending-")));
                } catch(IllegalArgumentException ignored) { /* Unknown files are never cleanup targets. */ }
            }
        }
        return candidates;
    }
    @Override public void deleteIfExists(String key) throws IOException {
        Path target=cleanupPath(key);
        Files.deleteIfExists(target);
        try { Files.delete(target.getParent()); } catch(DirectoryNotEmptyException | NoSuchFileException ignored) { }
        try { Files.delete(target.getParent().getParent()); } catch(DirectoryNotEmptyException | NoSuchFileException ignored) { }
    }
}
