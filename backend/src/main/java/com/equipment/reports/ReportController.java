package com.equipment.reports;

import com.equipment.identity.Actor;
import java.util.Map;
import java.util.UUID;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/workspaces/{workspace}")
public class ReportController {
    private final ReportService service;
    public ReportController(ReportService service){this.service=service;}
    @GetMapping("/dashboard") public Map<String,Object> dashboard(@RequestAttribute Actor actor,@PathVariable UUID workspace,@RequestParam(required=false) String month){return service.dashboard(actor,workspace,month);}
    @GetMapping("/reports/recorded") public Map<String,Object> recorded(@RequestAttribute Actor actor,@PathVariable UUID workspace,@RequestParam String fromDate,@RequestParam String toDate,@RequestParam(required=false) UUID equipmentId,@RequestParam(required=false) UUID projectId,@RequestParam(required=false) String entryType,@RequestParam(defaultValue="false") boolean generalExpense,@RequestParam(defaultValue="0") int page){return service.recorded(actor,workspace,new ReportService.Filter(fromDate,toDate,equipmentId,projectId,entryType,null,page,generalExpense),true);}
    @GetMapping("/reports/movements") public Map<String,Object> movements(@RequestAttribute Actor actor,@PathVariable UUID workspace,@RequestParam String fromDate,@RequestParam String toDate,@RequestParam(required=false) UUID equipmentId,@RequestParam(required=false) UUID projectId,@RequestParam(required=false) String entryType,@RequestParam(required=false) String movementType,@RequestParam(defaultValue="0") int page){return service.movements(actor,workspace,new ReportService.Filter(fromDate,toDate,equipmentId,projectId,entryType,movementType,page));}
    @GetMapping("/reports/outstanding") public Map<String,Object> outstanding(@RequestAttribute Actor actor,@PathVariable UUID workspace,@RequestParam(required=false) UUID equipmentId,@RequestParam(required=false) UUID projectId,@RequestParam(required=false) String entryType,@RequestParam(defaultValue="0") int page){return service.outstanding(actor,workspace,new ReportService.Filter(null,null,equipmentId,projectId,entryType,null,page));}
}
