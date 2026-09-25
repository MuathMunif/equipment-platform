package com.equipment.workspaces;

import com.equipment.identity.Actor;
import java.util.*;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/workspaces/{workspace}/drivers")
public class DriverController {
    private final DriverService service;
    public DriverController(DriverService service){this.service=service;}
    public record AssignmentInput(UUID driverUserId,UUID equipmentId){}
    @GetMapping("/me/assignment") Map<String,Object> current(@RequestAttribute Actor actor,@PathVariable UUID workspace){return Collections.singletonMap("equipmentId",service.current(actor,workspace));}
    @GetMapping("/eligible") List<Map<String,Object>> eligible(@RequestAttribute Actor actor,@PathVariable UUID workspace,@RequestParam UUID equipmentId){return service.eligible(actor,workspace,equipmentId);}
    @GetMapping("/equipment/{equipment}/assignment") Map<String,Object> equipmentAssignment(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID equipment){return service.equipmentAssignment(actor,workspace,equipment);}
    @GetMapping("/{user}/assignments") List<Map<String,Object>> history(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID user){return service.history(actor,workspace,user);}
    @PostMapping("/assignments") Map<String,Object> assign(@RequestAttribute Actor actor,@PathVariable UUID workspace,@RequestBody AssignmentInput input){return service.assign(actor,workspace,input.driverUserId(),input.equipmentId());}
    @DeleteMapping("/equipment/{equipment}/assignment") Map<String,Object> unassign(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID equipment){service.unassign(actor,workspace,equipment);return Map.of("unassigned",true);}
}
