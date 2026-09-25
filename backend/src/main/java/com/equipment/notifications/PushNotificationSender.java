package com.equipment.notifications;

import java.util.UUID;

public interface PushNotificationSender {
    void send(UUID workspace,UUID recipient,String title,String body);
}
