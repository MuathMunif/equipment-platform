package com.equipment.workspaces;

import com.equipment.identity.Actor;
import java.util.*;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1")
public class TeamController {
    private final TeamService team;
    public TeamController(TeamService team){this.team=team;}
    @GetMapping("/account/invitations") List<Map<String,Object>> pending(@RequestAttribute Actor actor){return team.pendingForAccount(actor);}
    @PostMapping("/account/invitations/{id}/accept") Map<String,Object> accept(@RequestAttribute Actor actor,@PathVariable UUID id){return team.decide(actor,id,true);}
    @PostMapping("/account/invitations/{id}/decline") Map<String,Object> decline(@RequestAttribute Actor actor,@PathVariable UUID id){return team.decide(actor,id,false);}
    @GetMapping("/workspaces") List<Map<String,Object>> workspaces(@RequestAttribute Actor actor){return team.workspaces(actor);}
    @PutMapping("/workspaces/{workspace}/selection") Map<String,Object> select(@RequestAttribute Actor actor,@PathVariable UUID workspace){team.selectWorkspace(actor,workspace);return Map.of("selectedWorkspaceId",workspace);}
    @GetMapping("/workspaces/{workspace}/team/invitations") List<Map<String,Object>> invitations(@RequestAttribute Actor actor,@PathVariable UUID workspace){return team.invitations(actor,workspace);}
    @PostMapping("/workspaces/{workspace}/team/invitations") Map<String,Object> invite(@RequestAttribute Actor actor,@PathVariable UUID workspace,@RequestBody TeamService.Invite input){return team.invite(actor,workspace,input);}
    @PostMapping("/workspaces/{workspace}/team/invitations/{id}/resend") Map<String,Object> resend(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID id){return team.resend(actor,workspace,id);}
    @PostMapping("/workspaces/{workspace}/team/invitations/{id}/cancel") Map<String,Object> cancel(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID id){return team.cancel(actor,workspace,id);}
    @GetMapping("/workspaces/{workspace}/team/members") List<Map<String,Object>> members(@RequestAttribute Actor actor,@PathVariable UUID workspace){return team.members(actor,workspace);}
    @GetMapping("/workspaces/{workspace}/team/members/{user}") Map<String,Object> member(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID user){return team.member(actor,workspace,user);}
    @PutMapping("/workspaces/{workspace}/team/members/{user}") Map<String,Object> change(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID user,@RequestBody TeamService.MemberChange input){return team.change(actor,workspace,user,input);}
    @DeleteMapping("/workspaces/{workspace}/team/members/{user}") Map<String,Object> revoke(@RequestAttribute Actor actor,@PathVariable UUID workspace,@PathVariable UUID user){team.revoke(actor,workspace,user);return Map.of("revoked",true);}
}
