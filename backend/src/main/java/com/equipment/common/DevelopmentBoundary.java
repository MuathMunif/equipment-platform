package com.equipment.common;

import java.util.Arrays;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;

/** This slice deliberately has no production auth/storage adapter. It fails closed. */
@Component
public class DevelopmentBoundary {
    public DevelopmentBoundary(Environment env, @Value("${app.dev-enabled:false}") boolean enabled) {
        boolean dev = Arrays.asList(env.getActiveProfiles()).contains("dev");
        boolean production = Arrays.stream(env.getActiveProfiles()).anyMatch(p -> !p.equals("dev") && !p.equals("test"));
        if (!enabled || !dev || production) throw new IllegalStateException("Only explicit isolated dev profile is supported; production providers are not configured");
    }
}
