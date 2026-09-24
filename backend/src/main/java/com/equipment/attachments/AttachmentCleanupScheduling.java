package com.equipment.attachments;

import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.scheduling.annotation.EnableScheduling;

@Configuration
@Profile("dev")
@EnableScheduling
class AttachmentCleanupScheduling {}
