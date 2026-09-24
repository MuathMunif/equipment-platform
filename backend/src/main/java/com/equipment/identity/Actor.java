package com.equipment.identity;

import java.util.UUID;
public record Actor(UUID userId, String sessionHash, String csrfToken) {}
