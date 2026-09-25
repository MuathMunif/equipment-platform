package com.equipment.equipment;

import com.equipment.identity.Actor;
import java.util.*;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/workspaces/{workspace}/equipment")
public class EquipmentController {
    private final EquipmentService service;
    public EquipmentController(EquipmentService service) { this.service=service; }
    @GetMapping Map<String,Object> list(@RequestAttribute Actor actor,@PathVariable UUID workspace,@RequestParam(defaultValue="0") int page,@RequestParam(required=false) String search) { return service.list(actor,workspace,page,search); }
    @GetMapping("/{id}") EquipmentService.Equipment get(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID id) { return service.get(actor,workspace,id); }
    @PostMapping("/{id}/archive") EquipmentService.Equipment archive(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID id) {return service.archive(actor,workspace,id);}
    @PostMapping("/{id}/restore") EquipmentService.Equipment restore(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID id) {return service.restore(actor,workspace,id);}
    @PostMapping EquipmentService.Equipment create(@RequestAttribute Actor actor,@PathVariable UUID workspace,@RequestHeader("Idempotency-Key") String key,@RequestBody EquipmentService.Create request) { return service.create(actor,workspace,key,request); }
}
