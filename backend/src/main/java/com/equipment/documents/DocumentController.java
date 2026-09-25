package com.equipment.documents;
import com.equipment.identity.Actor;
import java.util.*;
import org.springframework.web.bind.annotation.*;
@RestController
@RequestMapping("/api/v1/workspaces/{workspace}")
public class DocumentController {
 private final DocumentService service;
 public DocumentController(DocumentService service){this.service=service;}
 @GetMapping("/equipment/{equipment}/documents") List<Map<String,Object>> list(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID equipment,@RequestParam(defaultValue="false") boolean archived){return service.list(actor,workspace,equipment,archived);}
 @GetMapping("/equipment/{equipment}/documents/duplicates") List<Map<String,Object>> duplicate(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID equipment,@RequestParam String type,@RequestParam(required=false) String customTypeName){return service.duplicate(actor,workspace,equipment,type,customTypeName);}
 @PostMapping("/equipment/{equipment}/documents") Map<String,Object> create(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID equipment,@RequestHeader("Idempotency-Key") String key,@RequestBody DocumentService.Input input){return service.create(actor,workspace,equipment,key,input);}
 @GetMapping("/documents/incomplete") List<Map<String,Object>> incomplete(@RequestAttribute Actor actor,@PathVariable UUID workspace){return service.incomplete(actor,workspace);}
 @GetMapping("/documents/{id}") Map<String,Object> get(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID id){return service.get(actor,workspace,id);}
 @PutMapping("/documents/{id}") Map<String,Object> edit(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID id,@RequestBody DocumentService.Edit input){return service.edit(actor,workspace,id,input);}
 @PostMapping("/documents/{id}/renewals") Map<String,Object> renew(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID id,@RequestBody DocumentService.Renew input){return service.renew(actor,workspace,id,input);}
 @GetMapping("/documents/{id}/versions") List<Map<String,Object>> versions(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID id){return service.versions(actor,workspace,id);}
 @GetMapping("/documents/{id}/versions/{version}") Map<String,Object> version(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID id,@PathVariable UUID version){return service.getVersion(actor,workspace,id,version);}
 @PostMapping("/documents/{id}/archive") Map<String,Object> archive(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID id,@RequestBody(required=false) Map<String,String> body){return service.archive(actor,workspace,id,body==null?null:body.get("reason"));}
 @PostMapping("/documents/{id}/restore") Map<String,Object> restore(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID id){return service.restore(actor,workspace,id);}
}
