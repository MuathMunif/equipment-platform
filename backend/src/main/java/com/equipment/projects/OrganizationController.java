package com.equipment.projects;

import com.equipment.identity.Actor;
import java.util.*;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/workspaces/{workspace}")
public class OrganizationController {
    private final OrganizationService service;
    public OrganizationController(OrganizationService service){this.service=service;}
    @GetMapping("/organizations") List<Map<String,Object>> list(@RequestAttribute Actor actor,@PathVariable UUID workspace,@RequestParam(defaultValue="false") boolean archived,@RequestParam(required=false) String search){return service.list(actor,workspace,archived,search);}
    @PostMapping("/organizations") Map<String,Object> create(@RequestAttribute Actor actor,@PathVariable UUID workspace,@RequestBody OrganizationService.Input input){return service.create(actor,workspace,input);}
    @GetMapping("/organizations/{id}") Map<String,Object> get(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID id){return service.get(actor,workspace,id);}
    @PutMapping("/organizations/{id}") Map<String,Object> edit(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID id,@RequestBody OrganizationService.Input input){return service.edit(actor,workspace,id,input);}
    @PostMapping("/organizations/{id}/archive") Map<String,Object> archive(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID id){return service.archive(actor,workspace,id);}
    @PostMapping("/organizations/{id}/restore") Map<String,Object> restore(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID id){return service.restore(actor,workspace,id);}
    @GetMapping("/equipment/{equipment}/organization-history") List<Map<String,Object>> history(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID equipment){return service.history(actor,workspace,equipment);}
    @PutMapping("/equipment/{equipment}/organization") Map<String,Object> assign(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID equipment,@RequestBody OrganizationService.Assignment input){return service.assign(actor,workspace,equipment,input);}
}
