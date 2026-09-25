package com.equipment.notifications;

import java.time.Clock;
import java.time.LocalDate;
import java.time.ZoneId;
import org.springframework.context.annotation.Profile;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
@Profile("dev")
public class DocumentReminderScheduler {
    private final NotificationService notifications;private final Clock clock;
    public DocumentReminderScheduler(NotificationService notifications,Clock clock){this.notifications=notifications;this.clock=clock;}
    @Scheduled(cron="0 0 8 * * *",zone="Asia/Riyadh")
    public void daily(){notifications.runDaily(LocalDate.now(clock.withZone(ZoneId.of("Asia/Riyadh"))));}
    @Scheduled(cron="0 0 9 * * SUN",zone="Asia/Riyadh")
    public void weekly(){notifications.runWeekly(LocalDate.now(clock.withZone(ZoneId.of("Asia/Riyadh"))));}
}
