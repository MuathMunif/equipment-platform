package com.equipment.notifications;

import java.util.UUID;
import org.springframework.stereotype.Component;

/** Local development has no configured device tokens or external push provider. */
@Component
public class DevelopmentPushNotificationSender implements PushNotificationSender {
    @Override public void send(UUID workspace,UUID recipient,String title,String body) { }
}
