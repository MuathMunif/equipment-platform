package com.equipment.finance;

import com.equipment.identity.Actor;
import java.util.*;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/workspaces/{workspace}/entries")
public class FinanceController {
    private final FinanceService service;
    public FinanceController(FinanceService service) { this.service=service; }
    @GetMapping Map<String,Object> list(@RequestAttribute Actor actor,@PathVariable UUID workspace,@RequestParam(required=false) UUID equipmentId,@RequestParam(defaultValue="0") int page,@RequestParam(required=false) String search,@RequestParam(required=false) String fromDate,@RequestParam(required=false) String toDate,@RequestParam(required=false) String entryType,@RequestParam(required=false) Boolean generalExpense,@RequestParam(required=false) String lifecycle,@RequestParam(required=false) String settlementStatus) {
        return service.list(actor,workspace,new FinanceService.HistoryFilter(search,fromDate,toDate,entryType,equipmentId,generalExpense,lifecycle,settlementStatus),page);
    }
    @GetMapping("/totals") Map<String,String> totals(@RequestAttribute Actor actor,@PathVariable UUID workspace,@RequestParam(required=false) UUID equipmentId) { return service.totals(actor,workspace,equipmentId); }
    @GetMapping("/{id}") FinanceService.Entry get(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID id) { return service.get(actor,workspace,id); }
    @PostMapping FinanceService.Entry create(@RequestAttribute Actor actor,@PathVariable UUID workspace,@RequestHeader("Idempotency-Key") String key,@RequestBody FinanceService.Create request) { return service.create(actor,workspace,key,request); }
    @PostMapping("/{id}/settlements") FinanceService.Entry settle(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID id,@RequestHeader("Idempotency-Key") String key,@RequestBody FinanceService.AddSettlement request) { return service.settle(actor,workspace,id,key,request); }
    @PostMapping("/{id}/refunds") FinanceService.Entry refund(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID id,@RequestHeader("Idempotency-Key") String key,@RequestBody FinanceService.CreateRefund request) { return service.refund(actor,workspace,id,key,request); }
    @PutMapping("/{id}") FinanceService.Entry edit(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID id,@RequestBody FinanceService.Edit request) { return service.edit(actor,workspace,id,request); }
    @PostMapping("/{id}/cancellation") FinanceService.Entry cancel(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID id,@RequestBody FinanceService.Cancel request) { return service.cancel(actor,workspace,id,request); }
    public record ProjectClassification(UUID projectId) {}
    @PutMapping("/{id}/project") FinanceService.Entry classifyProject(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID id,@RequestBody ProjectClassification request) { return service.classifyProject(actor,workspace,id,request.projectId()); }
}
