import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> clearNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  static Future<void> clearScheduledNotification() async {
    await clearNotification(10);
    await clearNotification(30);
    await clearNotification(31);
    await clearNotification(31);
    await clearNotification(33);
    await clearNotification(20);
  }

  static Future<void> zonedScheduleNotification(int second, int id, Map<String, dynamic> payload) async {
    await clearNotification(10).then(
      (value) async {
        const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
          'scheduled_channel',
          'Scheduled Notifications',
          channelDescription: 'This channel is for scheduled notifications',
          importance: Importance.max,
          priority: Priority.high,
        );

        await flutterLocalNotificationsPlugin
            .zonedSchedule(10, 'Target rest reached!', 'Your Timer has reached 0, get back to your workout and keep your progress going',
                tz.TZDateTime.now(tz.local).add(Duration(seconds: second)), const NotificationDetails(android: androidDetails),
                androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
                payload: jsonEncode(payload),
                uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime)
            .catchError(
          (error) {
            debugPrint('error==========>>>>>$error');
          },
        );
      },
    );
  }

  static Future<void> scheduleWeekReminder(int id, DateTime endDateUtc) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'weekly_reminder_channel',
      'Weekly Reminder',
      channelDescription: 'This channel is for weekly workout reminders',
      importance: Importance.max,
      priority: Priority.high,
    );

    DateTime nowUtc = DateTime.now().toUtc();
    tz.TZDateTime nowLocal = tz.TZDateTime.from(nowUtc, tz.local);
    tz.TZDateTime endDate = tz.TZDateTime.from(endDateUtc, tz.local);

    tz.TZDateTime nextSunday = tz.TZDateTime(tz.local, nowLocal.year, nowLocal.month, nowLocal.day, 12, 0, 0);

    if (nowLocal.weekday != DateTime.sunday) {
      nextSunday = nextSunday.add(Duration(days: (7 - nowLocal.weekday) % 7));
    }

    if (nowLocal.weekday == DateTime.sunday && nowLocal.hour >= 12) {
      nextSunday = nextSunday.add(const Duration(days: 7));
    }

    if (nextSunday.isBefore(nowLocal)) {
      debugPrint("Skipping scheduling: nextSunday ($nextSunday) is in the past.");
      return;
    }

    int notificationId = id;
    while (nextSunday.isBefore(endDate) || nextSunday.isAtSameMomentAs(endDate)) {
      await clearNotification(id);
      await flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        'Workout Reminder',
        'Your workout week is ending today at midnight. Update your progress and prepare for next week!',
        nextSunday,
        const NotificationDetails(android: androidDetails),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );

      debugPrint("✅ Scheduled Sunday notification for: $nextSunday");

      nextSunday = nextSunday.add(const Duration(days: 7));
      notificationId++;
    }
  }

  static Future<void> scheduleMonthlyReminder(int id, DateTime utcDate) async {
    clearNotification(id);
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'monthly_reminder_channel',
      'Monthly Reminder',
      channelDescription: 'This channel is for monthly workout reminders',
      importance: Importance.max,
      priority: Priority.high,
    );

    final tz.TZDateTime nowLocal = tz.TZDateTime.from(utcDate, tz.local).subtract(const Duration(hours: 12));

    final tz.TZDateTime scheduledTime = tz.TZDateTime(tz.local, nowLocal.year, nowLocal.month, nowLocal.day, 14, 0, 0);

    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    if (scheduledTime.isBefore(now)) {
      debugPrint("Skipping notification scheduling because the date is in the past: $scheduledTime");
      return;
    }

    await flutterLocalNotificationsPlugin
        .zonedSchedule(
      id,
      'Monthly Workout Reminder',
      'Your workout month is ending today at midnight. Update your progress and prepare for a new month!',
      scheduledTime,
      const NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    )
        .catchError((error) {
      debugPrint('Error scheduling notification: $error');
    });

    debugPrint("✅ Scheduled monthly reminder for: $scheduledTime");
  }
}
