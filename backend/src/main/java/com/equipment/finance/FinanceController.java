package com.equipment.finance;

import com.equipment.identity.Actor;
import java.util.*;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/workspaces/{workspace}/entries")
public class FinanceController {
    private final FinanceService service;
    public FinanceController(FinanceService service) { this.service=service; }
    @GetMapping Map<String,Object> list(@RequestAttribute Actor actor,@PathVariable UUID workspace,@RequestParam(required=false) UUID equipmentId,@RequestParam(defaultValue="0") int page) { return service.list(actor,workspace,equipmentId,page); }
    @GetMapping("/{id}") FinanceService.Entry get(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID id) { return service.get(actor,workspace,id); }
    @PostMapping FinanceService.Entry create(@RequestAttribute Actor actor,@PathVariable UUID workspace,@RequestHeader("Idempotency-Key") String key,@RequestBody FinanceService.Create request) { return service.create(actor,workspace,key,request); }
    @PostMapping("/{id}/settlements") FinanceService.Entry settle(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID id,@RequestHeader("Idempotency-Key") String key,@RequestBody FinanceService.AddSettlement request) { return service.settle(actor,workspace,id,key,request); }
    @PutMapping("/{id}") FinanceService.Entry edit(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID id,@RequestBody FinanceService.Edit request) { return service.edit(actor,workspace,id,request); }
    @PostMapping("/{id}/cancellation") FinanceService.Entry cancel(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID id,@RequestBody FinanceService.Cancel request) { return service.cancel(actor,workspace,id,request); }
}
