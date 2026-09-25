package com.equipment.notifications;

import java.util.UUID;
import java.util.Map;

public interface PushNotificationSender {
    void send(UUID workspace,UUID recipient,String templateKey,Map<String,Object> params,String preferredLocale);
}
