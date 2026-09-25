package com.equipment.notifications;

import com.equipment.identity.Actor;
import java.util.*;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/workspaces/{workspace}")
public class NotificationController {
    private final NotificationService service;
    public NotificationController(NotificationService service){this.service=service;}
    @GetMapping("/attention/documents") List<Map<String,Object>> attention(@RequestAttribute Actor actor,@PathVariable UUID workspace,@RequestParam(required=false) UUID equipmentId){return service.attention(actor,workspace,equipmentId);}
    @GetMapping("/attention") List<Map<String,Object>> operationalAttention(@RequestAttribute Actor actor,@PathVariable UUID workspace,@RequestParam(required=false) UUID equipmentId){return service.operationalAttention(actor,workspace,equipmentId);}
    @GetMapping("/notifications") NotificationService.Page list(@RequestAttribute Actor actor,@PathVariable UUID workspace,@RequestParam(defaultValue="0") int page){return service.list(actor,workspace,page);}
    @GetMapping("/notifications/unread-count") Map<String,Long> unreadCount(@RequestAttribute Actor actor,@PathVariable UUID workspace){return service.unreadCount(actor,workspace);}
    @PostMapping("/notifications/{id}/read") NotificationService.Notification read(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID id){return service.read(actor,workspace,id);}
    @PostMapping("/notifications/read-all") Map<String,Integer> readAll(@RequestAttribute Actor actor,@PathVariable UUID workspace){return service.readAll(actor,workspace);}
}
