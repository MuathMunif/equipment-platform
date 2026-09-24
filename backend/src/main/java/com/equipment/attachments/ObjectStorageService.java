package com.equipment.attachments;

import java.io.IOException;

public interface ObjectStorageService {
    void putImmutable(String key,byte[] content) throws IOException;
    byte[] read(String key) throws IOException;
}
