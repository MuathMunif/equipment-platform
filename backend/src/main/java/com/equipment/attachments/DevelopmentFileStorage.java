package com.equipment.attachments;

import com.equipment.common.DevelopmentBoundary;
import java.io.IOException;
import java.nio.file.*;
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
        Path path=root.resolve(key).normalize(); if(!path.startsWith(root)) throw new IOException("Invalid object path"); return path;
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
}
