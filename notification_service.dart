// lib/config/notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// ✅ Initialize local notification settings
  static Future<void> initializeNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Optional: Handle notification tap here
        debugPrint("Notification clicked: ${response.payload}");
      },
    );
  }

  /// ✅ Show notification when receiving a message from Firebase
  static Future<void> showNotification(RemoteMessage message) async {
    if (message.notification == null) return;

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'volunteer_channel', // custom channel ID
      'Volunteer Notifications', // channel name
      channelDescription: 'Notifications for volunteers after donation',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000, // Unique ID
      message.notification!.title,
      message.notification!.body,
      platformDetails,
    );
  }
}
