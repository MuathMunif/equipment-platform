package com.equipment.common;

import com.equipment.identity.SessionInterceptor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.*;

@Configuration
public class WebConfiguration implements WebMvcConfigurer {
    private final SessionInterceptor sessions;
    private final String[] origins;
    public WebConfiguration(SessionInterceptor sessions,@Value("${app.allowed-origins}") String origins) { this.sessions=sessions; this.origins=origins.split(","); }
    @Override public void addInterceptors(InterceptorRegistry registry) { registry.addInterceptor(sessions).addPathPatterns("/api/v1/**"); }
    @Override public void addCorsMappings(CorsRegistry registry) { registry.addMapping("/api/v1/**").allowedOrigins(origins).allowedMethods("GET","POST","PUT","OPTIONS").allowedHeaders("Content-Type","Authorization","X-CSRF-Token","Idempotency-Key").allowCredentials(true); }
}
