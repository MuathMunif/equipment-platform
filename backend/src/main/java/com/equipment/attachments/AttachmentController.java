package com.equipment.attachments;

import com.equipment.common.ApiException;
import com.equipment.identity.Actor;
import jakarta.servlet.http.HttpServletRequest;
import java.io.IOException;
import java.util.*;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/workspaces/{workspace}")
public class AttachmentController {
    private final AttachmentService service;
    public AttachmentController(AttachmentService service) { this.service=service; }
    @GetMapping("/entries/{entry}/attachments") List<AttachmentService.Attachment> list(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID entry) { return service.list(actor,workspace,entry); }
    @PostMapping("/entries/{entry}/attachments") AttachmentService.Attachment initiate(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID entry,@RequestHeader("Idempotency-Key") String key,@RequestBody AttachmentService.Initiate request) { return service.initiate(actor,workspace,entry,key,request); }
    @PutMapping("/attachments/{id}/content") AttachmentService.Attachment upload(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID id,HttpServletRequest request) throws IOException {
        service.get(actor,workspace,id); byte[] bytes=request.getInputStream().readNBytes(ContentValidator.MAX_BYTES+1);
        if(bytes.length>ContentValidator.MAX_BYTES) throw new ApiException(413,"FILE_TOO_LARGE","اختر ملفًا لا يتجاوز 10 ميغابايت");
        return service.upload(actor,workspace,id,request.getContentType(),bytes);
    }
    @GetMapping("/attachments/{id}/content") ResponseEntity<byte[]> download(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID id) {
        var file=service.download(actor,workspace,id);
        return ResponseEntity.ok().contentType(MediaType.parseMediaType(file.mediaType())).header("Cache-Control","no-store").header("X-Content-Type-Options","nosniff").header("Content-Security-Policy","sandbox").header(HttpHeaders.CONTENT_DISPOSITION,ContentDisposition.attachment().filename(file.filename(),java.nio.charset.StandardCharsets.UTF_8).build().toString()).body(file.bytes());
    }
}
