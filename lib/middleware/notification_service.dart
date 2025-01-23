import 'dart:developer';

import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> clearNotification() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  static Future<void> showNotification() async {
    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails('your channel id', 'your channel name',
        channelDescription: 'your channel description', importance: Importance.max, priority: Priority.high, ticker: 'ticker');
    const NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.show(0, 'plain title', 'plain body', notificationDetails, payload: 'item x');
  }

  static Future<void> zonedScheduleNotification(int second, int id, Map<String, dynamic> payload) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'scheduled_channel', // Unique ID
      'Scheduled Notifications', // Channel name
      channelDescription: 'This channel is for scheduled notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    await flutterLocalNotificationsPlugin
        .zonedSchedule(id, 'Scheduled notification title $id', 'Scheduled notification body',
            tz.TZDateTime.now(tz.local).add(Duration(seconds: second)), const NotificationDetails(android: androidDetails),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            payload: payload.toString(),
            uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime)
        .catchError(
      (error) {
        print('error==========>>>>>${error}');
      },
    );
  }
}
