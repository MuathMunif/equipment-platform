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
    @GetMapping("/documents/{document}/versions/{version}/attachments") List<AttachmentService.Attachment> listDocument(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID document,@PathVariable UUID version) { return service.listDocument(actor,workspace,document,version); }
    @PostMapping("/documents/{document}/versions/{version}/attachments") AttachmentService.Attachment initiateDocument(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID document,@PathVariable UUID version,@RequestHeader("Idempotency-Key") String key,@RequestBody AttachmentService.Initiate request) { return service.initiateDocument(actor,workspace,document,version,key,request); }
    @GetMapping("/issues/{issue}/attachments") List<AttachmentService.Attachment> listIssue(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID issue){return service.listIssue(actor,workspace,issue);}
    @PostMapping("/issues/{issue}/attachments") AttachmentService.Attachment initiateIssue(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID issue,@RequestHeader("Idempotency-Key") String key,@RequestBody AttachmentService.Initiate request){return service.initiateIssue(actor,workspace,issue,key,request);}
    @DeleteMapping("/issues/{issue}/attachments/{id}") void removeIssue(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID issue,@PathVariable UUID id){service.removeOperational(actor,workspace,issue,true,id);}
    @GetMapping("/maintenance/{maintenance}/attachments") List<AttachmentService.Attachment> listMaintenance(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID maintenance){return service.listMaintenance(actor,workspace,maintenance);}
    @PostMapping("/maintenance/{maintenance}/attachments") AttachmentService.Attachment initiateMaintenance(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID maintenance,@RequestHeader("Idempotency-Key") String key,@RequestBody AttachmentService.Initiate request){return service.initiateMaintenance(actor,workspace,maintenance,key,request);}
    @GetMapping("/projects/{project}/attachments") List<AttachmentService.Attachment> listProject(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID project){return service.listProject(actor,workspace,project);}
    @PostMapping("/projects/{project}/attachments") AttachmentService.Attachment initiateProject(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID project,@RequestHeader("Idempotency-Key") String key,@RequestBody AttachmentService.Initiate request){return service.initiateProject(actor,workspace,project,key,request);}
    @DeleteMapping("/maintenance/{maintenance}/attachments/{id}") void removeMaintenance(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID maintenance,@PathVariable UUID id){service.removeOperational(actor,workspace,maintenance,false,id);}
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
