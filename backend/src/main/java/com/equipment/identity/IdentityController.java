package com.equipment.identity;

import com.equipment.common.ApiException;
import java.util.*;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseCookie;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1")
public class IdentityController {
    private final IdentityService service;
    public IdentityController(IdentityService service) { this.service=service; }
    public record ChallengeRequest(String phone) {}
    public record VerifyRequest(UUID challengeId,String code,String name,String client) {}
    @GetMapping("/health") Map<String,Object> health() { return Map.of("status","UP","mode","ISOLATED_DEVELOPMENT","storage","LOCAL_FILESYSTEM","malwareScan","NOT_CONFIGURED"); }
    @PostMapping("/auth/challenges") IdentityService.Challenge challenge(@RequestBody ChallengeRequest request) { return service.challenge(request.phone()); }
    @PostMapping("/auth/verify") Map<String,Object> verify(@RequestBody VerifyRequest request,HttpServletResponse response) {
        if(request.challengeId()==null || !Set.of("WEB","NATIVE").contains(request.client()==null?"":request.client())) throw ApiException.invalid("راجع بيانات الدخول");
        var result=service.verify(request.challengeId(),request.code(),request.name());
        response.setHeader("Cache-Control","no-store");
        if(result.requiresName()) return Map.of("requiresName",true);
        if(request.client().equals("WEB")) response.addHeader(HttpHeaders.SET_COOKIE,ResponseCookie.from(IdentityService.COOKIE,result.token()).httpOnly(true).sameSite("Strict").path("/api/v1").build().toString());
        var body=new HashMap<String,Object>(); body.put("requiresName",false); body.put("csrfToken",result.csrfToken());
        if(request.client().equals("NATIVE")) body.put("accessToken",result.token());
        return body;
    }
    @GetMapping("/auth/me") Map<String,Object> me(@RequestAttribute Actor actor) { return service.me(actor); }
    @PostMapping("/auth/logout") Map<String,Object> logout(@RequestAttribute Actor actor,HttpServletResponse response) {
        service.logout(actor); response.addHeader(HttpHeaders.SET_COOKIE,ResponseCookie.from(IdentityService.COOKIE,"").httpOnly(true).sameSite("Strict").path("/api/v1").maxAge(0).build().toString()); return Map.of("loggedOut",true);
    }
}
