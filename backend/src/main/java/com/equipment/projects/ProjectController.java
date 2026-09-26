package com.equipment.projects;

import com.equipment.identity.Actor;
import java.util.*;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/workspaces/{workspace}/projects")
public class ProjectController {
    private final ProjectService service;
    public ProjectController(ProjectService service){this.service=service;}
    @GetMapping("/equipment/{equipment}/active-projects") List<Map<String,Object>> equipmentProjects(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID equipment){return service.activeForEquipment(actor,workspace,equipment);}
    @GetMapping List<Map<String,Object>> list(@RequestAttribute Actor actor,@PathVariable UUID workspace,@RequestParam(defaultValue="false") boolean archived,@RequestParam(required=false) String kind,@RequestParam(required=false) String status,@RequestParam(required=false) UUID organizationId,@RequestParam(required=false) String search){return service.list(actor,workspace,archived,kind,status,organizationId,search);}
    @PostMapping Map<String,Object> create(@RequestAttribute Actor actor,@PathVariable UUID workspace,@RequestBody ProjectService.Input input){return service.create(actor,workspace,input);}
    @GetMapping("/{id}") Map<String,Object> get(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID id){return service.get(actor,workspace,id);}
    @PutMapping("/{id}") Map<String,Object> edit(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID id,@RequestBody ProjectService.Input input){return service.edit(actor,workspace,id,input);}
    @PostMapping("/{id}/complete") Map<String,Object> complete(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID id){return service.transition(actor,workspace,id,"complete");}
    @PostMapping("/{id}/reopen") Map<String,Object> reopen(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID id){return service.transition(actor,workspace,id,"reopen");}
    @PostMapping("/{id}/archive") Map<String,Object> archive(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID id){return service.transition(actor,workspace,id,"archive");}
    @PostMapping("/{id}/restore") Map<String,Object> restore(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID id){return service.transition(actor,workspace,id,"restore");}
    @GetMapping("/{id}/equipment") List<Map<String,Object>> equipment(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID id){return service.equipment(actor,workspace,id);}
    @PostMapping("/{id}/equipment/{equipment}") Map<String,Object> link(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID id,@PathVariable UUID equipment){return service.link(actor,workspace,id,equipment);}
    @DeleteMapping("/{id}/equipment/{equipment}") void unlink(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID id,@PathVariable UUID equipment){service.unlink(actor,workspace,id,equipment);}
    @GetMapping("/{id}/financial-summary") Map<String,String> summary(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID id){return service.summary(actor,workspace,id);}
}
