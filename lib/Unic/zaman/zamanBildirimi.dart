import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:unicotantic/Unic/zaman/dakikaSayac.dart';
import 'package:unicotantic/akis/anasayfa.dart';

class NotificationService {
  static Future<void> initializeNotification() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelGroupKey: 'high_importance_chanel',
          channelKey: 'high_importance_chanel',
          channelName: 'Basic notifications',
          channelDescription: 'Notification channel basic test',
          defaultColor: const Color(0xff9d50dd),
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
          onlyAlertOnce: true,
          playSound: true,
          //criticalAlerts: true,
        ),
      ],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: 'high_importance_chanel',
          channelGroupName: 'Group 1',
        ),
      ],
      debug: true,
    );
    await AwesomeNotifications().isNotificationAllowed().then((
      isAllowed,
    ) async {
      if (!isAllowed) {
        await AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    );
  }

  static Future<void> onActionReceivedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    debugPrint('onActionReceivedMethod');
  }

  static Future<void> onNotificationCreatedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    debugPrint('onNotificationCreatedMethod');
  }

  static Future<void> onNotificationDisplayedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    debugPrint('onNotificationDisplayedMethod');
  }

  static Future<void> onDismissActionReceivedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    debugPrint('onDismissActionReceivedMethod');
    final payload = receivedNotification.payload ?? {};
    if (payload['navigate'] == 'true') {
      DakikaSayac.navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => const DoluAkisAnaSayfa()),
      );
    }
  }

  static Future<void> showNotification({
    required final String title,
    required final String body,
    final String? summary,
    final Map<String, String>? payload,
    final ActionType actionType = ActionType.Default,
    final NotificationLayout notificationLayout = NotificationLayout.Default,
    final NotificationCategory? category,
    final String? bigPicture,
    final List<NotificationActionButton>? actionButton,
    final bool scheduled = false,
    final int? interval,
  }) async {
    assert(!scheduled || (scheduled && interval != null));

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        criticalAlert: true,
        autoDismissible: true,
        id: -1,
        channelKey: 'high_importance_chanel',
        displayOnBackground: true,
        title: title,
        body: body,
        actionType: actionType,
        notificationLayout: notificationLayout,
        summary: summary,
        category: category,
        payload: payload,
        bigPicture: bigPicture,
      ),
      actionButtons: actionButton,
      schedule: scheduled
          ? NotificationInterval(
              // interval'ı Duration nesnesine dönüştürün
              interval: interval != null ? Duration(seconds: interval) : null,
              timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
              preciseAlarm: false, // Android 13 ve sonrası için SCHEDULE_EXACT_ALARM iznini gözden geçirin
              allowWhileIdle: true,
            )
          : null,
    );
  }
}
