package com.equipment.maintenance;

import com.equipment.identity.Actor;
import com.equipment.finance.FinanceService;
import java.util.*;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/workspaces/{workspace}")
public class MaintenanceController {
    private final MaintenanceService service;
    public MaintenanceController(MaintenanceService service){this.service=service;}
    @GetMapping("/issues") Map<String,Object> issues(@RequestAttribute Actor actor,@PathVariable UUID workspace,@RequestParam(required=false) UUID equipmentId,@RequestParam(required=false) String status,@RequestParam(required=false) Boolean equipmentStopped,@RequestParam(required=false) String fromDate,@RequestParam(required=false) String toDate,@RequestParam(required=false) String search,@RequestParam(defaultValue="0") int page){return service.listIssues(actor,workspace,equipmentId,status,equipmentStopped,fromDate,toDate,search,page);}
    @PostMapping("/equipment/{equipment}/issues") Map<String,Object> createIssue(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID equipment,@RequestHeader("Idempotency-Key") String key,@RequestBody MaintenanceService.IssueInput input){return service.createIssue(actor,workspace,equipment,key,input);}
    @GetMapping("/issues/{id}") Map<String,Object> issue(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID id){return service.getIssue(actor,workspace,id);}
    @PutMapping("/issues/{id}") Map<String,Object> editIssue(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID id,@RequestBody MaintenanceService.IssueInput input){return service.editIssue(actor,workspace,id,input);}
    @PostMapping("/issues/{id}/start") Map<String,Object> start(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID id){return service.start(actor,workspace,id);}
    @PostMapping("/issues/{id}/close") Map<String,Object> close(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID id,@RequestBody MaintenanceService.CloseInput input){return service.close(actor,workspace,id,input);}
    @PostMapping("/issues/{id}/reopen") Map<String,Object> reopen(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID id){return service.reopen(actor,workspace,id);}
    @GetMapping("/maintenance") Map<String,Object> maintenance(@RequestAttribute Actor actor,@PathVariable UUID workspace,@RequestParam(required=false) UUID equipmentId,@RequestParam(required=false) String type,@RequestParam(required=false) Boolean cancelled,@RequestParam(required=false) String fromDate,@RequestParam(required=false) String toDate,@RequestParam(required=false) String search,@RequestParam(defaultValue="0") int page){return service.listMaintenance(actor,workspace,equipmentId,type,cancelled,fromDate,toDate,search,page);}
    @PostMapping("/equipment/{equipment}/maintenance") Map<String,Object> createMaintenance(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID equipment,@RequestHeader("Idempotency-Key") String key,@RequestBody MaintenanceService.MaintenanceInput input){return service.createMaintenance(actor,workspace,equipment,key,input);}
    @GetMapping("/maintenance/{id}") Map<String,Object> getMaintenance(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID id){return service.getMaintenance(actor,workspace,id);}
    @PutMapping("/maintenance/{id}") Map<String,Object> editMaintenance(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID id,@RequestBody MaintenanceService.MaintenanceInput input){return service.editMaintenance(actor,workspace,id,input);}
    @PostMapping("/maintenance/{id}/cancellation") Map<String,Object> cancel(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID id,@RequestBody MaintenanceService.CancelInput input){return service.cancelMaintenance(actor,workspace,id,input);}
    @GetMapping("/maintenance/{id}/eligible-expenses") Map<String,Object> eligible(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID id,@RequestParam(required=false) String search,@RequestParam(defaultValue="0") int page){return service.eligibleExpenses(actor,workspace,id,search,page);}
    @PostMapping("/maintenance/{id}/expenses/{entryId}") Map<String,Object> link(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID id,@PathVariable UUID entryId){return service.linkExpense(actor,workspace,id,entryId);}
    @PostMapping("/maintenance/{id}/expenses") Map<String,Object> createExpense(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID id,@RequestHeader("Idempotency-Key") String key,@RequestBody FinanceService.Create input){return service.createExpense(actor,workspace,id,key,input);}
    @DeleteMapping("/maintenance/{id}/expenses/{entryId}") Map<String,Object> unlink(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID id,@PathVariable UUID entryId){return service.unlinkExpense(actor,workspace,id,entryId);}
}
