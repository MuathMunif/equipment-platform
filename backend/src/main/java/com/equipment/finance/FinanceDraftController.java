package com.equipment.finance;

import com.equipment.identity.Actor;
import java.util.Map;
import java.util.UUID;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/workspaces/{workspace}/drafts")
public class FinanceDraftController {
    private final FinanceService service;
    public FinanceDraftController(FinanceService service) { this.service=service; }
    @GetMapping Map<String,Object> list(@RequestAttribute Actor actor,@PathVariable UUID workspace,@RequestParam(defaultValue="0") int page,@RequestParam(required=false) UUID equipmentId) { return service.listDrafts(actor,workspace,page,equipmentId); }
    @GetMapping("/{id}") FinanceService.Draft get(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID id) { return service.getDraft(actor,workspace,id); }
    @PostMapping FinanceService.Draft create(@RequestAttribute Actor actor,@PathVariable UUID workspace,@RequestHeader("Idempotency-Key") String key,@RequestBody FinanceService.CreateDraft request) { return service.createDraft(actor,workspace,key,request); }
    @PostMapping("/{id}/completion") FinanceService.Entry complete(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID id,@RequestHeader("Idempotency-Key") String key,@RequestBody FinanceService.Create request) { return service.completeDraft(actor,workspace,id,key,request); }
    @DeleteMapping("/{id}") FinanceService.Draft discard(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID id) { return service.discardDraft(actor,workspace,id); }
}
