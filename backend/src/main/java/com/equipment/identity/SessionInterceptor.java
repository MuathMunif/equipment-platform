package com.equipment.identity;

import com.equipment.common.ApiException;
import jakarta.servlet.http.*;
import java.security.MessageDigest;
import java.nio.charset.StandardCharsets;
import java.util.*;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

@Component
public class SessionInterceptor implements HandlerInterceptor {
    private final IdentityService identity;
    private final Set<String> origins;
    public SessionInterceptor(IdentityService identity,@Value("${app.allowed-origins}") String origins) { this.identity=identity; this.origins=Set.of(origins.split(",")); }
    @Override public boolean preHandle(HttpServletRequest req,HttpServletResponse response,Object handler) {
        if(req.getMethod().equals("OPTIONS")) return true;
        String origin=req.getHeader("Origin");
        if(origin!=null && !origins.contains(origin)) throw new ApiException(403,"ORIGIN_DENIED","تعذر قبول الطلب من هذا الموقع");
        if(req.getRequestURI().equals("/api/v1/health") || req.getRequestURI().equals("/api/v1/auth/challenges") || req.getRequestURI().equals("/api/v1/auth/verify")) return true;
        String authorization=req.getHeader("Authorization");
        boolean bearer=authorization!=null && authorization.startsWith("Bearer ");
        String token=bearer?authorization.substring(7):null;
        if(!bearer && req.getCookies()!=null) for(Cookie cookie:req.getCookies()) if(cookie.getName().equals(IdentityService.COOKIE)) token=cookie.getValue();
        Actor actor=identity.authenticate(token);
        if(!bearer && !Set.of("GET","HEAD").contains(req.getMethod())) {
            String csrf=req.getHeader("X-CSRF-Token");
            if(csrf==null || !MessageDigest.isEqual(csrf.getBytes(StandardCharsets.UTF_8),actor.csrfToken().getBytes(StandardCharsets.UTF_8)))
                throw new ApiException(403,"CSRF_REQUIRED","حدّث الصفحة ثم أعد المحاولة");
        }
        req.setAttribute("actor",actor);
        response.setHeader("Cache-Control","no-store");
        response.setHeader("X-Content-Type-Options","nosniff");
        return true;
    }
}
