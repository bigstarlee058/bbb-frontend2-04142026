import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> clearNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  static Future<void> zonedScheduleNotification(int second, int id, Map<String, dynamic> payload) async {
    clearNotification(10);
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
  }

  static Future<void> scheduleWeekReminder(int id, DateTime startDateUtc, DateTime endDateUtc) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'weekly_reminder_channel',
      'Weekly Reminder',
      channelDescription: 'This channel is for weekly workout reminders',
      importance: Importance.max,
      priority: Priority.high,
    );

    final tz.TZDateTime startDate = tz.TZDateTime.from(startDateUtc, tz.local);
    final tz.TZDateTime endDate = tz.TZDateTime.from(endDateUtc, tz.local);
    tz.TZDateTime current = startDate;
    while (current.weekday != DateTime.sunday) {
      current = current.add(const Duration(days: 1));
    }
    int notificationId = id;
    while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
      clearNotification(id);
      await flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        'Workout Reminder',
        'Your workout week is ending today at midnight. Update your progress and prepare for next week!',
        current,
        const NotificationDetails(android: androidDetails),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
      debugPrint("Scheduled notification for: $current");
      notificationId++;
      current = current.add(const Duration(days: 7));
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

    final tz.TZDateTime scheduledTime = tz.TZDateTime.from(utcDate.subtract(Duration(hours: 12)), tz.local);

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
        .catchError(
      (error) {
        debugPrint('error==========>>>>>$error');
      },
    );
  }
}
