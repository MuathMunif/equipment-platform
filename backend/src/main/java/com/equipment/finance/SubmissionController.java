package com.equipment.finance;

import com.equipment.identity.Actor;
import java.util.*;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/workspaces/{workspace}/financial-submissions")
public class SubmissionController {
    private final SubmissionService service;
    public SubmissionController(SubmissionService service){this.service=service;}
    @PostMapping Map<String,Object> create(@RequestAttribute Actor actor,@PathVariable UUID workspace,@RequestBody SubmissionService.Create input){return service.create(actor,workspace,input);}
    @GetMapping("/mine") Map<String,Object> mine(@RequestAttribute Actor actor,@PathVariable UUID workspace,@RequestParam(defaultValue="0") int page){return service.own(actor,workspace,page);}
    @GetMapping("/review-queue") Map<String,Object> queue(@RequestAttribute Actor actor,@PathVariable UUID workspace,@RequestParam(defaultValue="0") int page){return service.queue(actor,workspace,page);}
    @GetMapping("/{id}") Map<String,Object> get(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID id){return service.get(actor,workspace,id);}
    @PostMapping("/{id}/resubmit") Map<String,Object> resubmit(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID id){return service.resubmit(actor,workspace,id);}
    @PostMapping("/{id}/approve") Map<String,Object> approve(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID id,@RequestBody FinanceService.Create input){return service.approve(actor,workspace,id,input);}
    @PostMapping("/{id}/reject") Map<String,Object> reject(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID id,@RequestBody SubmissionService.Reject input){return service.reject(actor,workspace,id,input);}
}
