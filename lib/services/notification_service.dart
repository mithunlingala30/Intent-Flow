import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../firebase_options.dart';
import '../models/task_model.dart';

/// Top-level background message handler for Firebase Cloud Messaging.
/// Must be outside of any class and annotated with @pragma('vm:entry-point').
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (_) {}
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'intentflow_reminders',
    'Task Reminders & Alerts',
    description: 'High-priority notifications for your tasks, just like WhatsApp and Instagram.',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
    showBadge: true,
  );

  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize time zones for scheduled notifications
    try {
      tz.initializeTimeZones();
    } catch (e) {
      debugPrint('Timezone init error: $e');
    }

    if (!kIsWeb) {
      // 1. Initialize local notifications
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _local.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (response) {
          debugPrint('Notification clicked: ${response.payload}');
        },
      );

      // Create Android Notification Channel with Maximum Importance
      final androidPlugin = _local.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(_channel);

        // Request POST_NOTIFICATIONS (Android 13+)
        await androidPlugin.requestNotificationsPermission();

        // Request exact alarm permission (Android 12+)
        if (Platform.isAndroid) {
          await androidPlugin.requestExactAlarmsPermission();
        }
      }
    }

    // 2. Initialize Firebase Cloud Messaging
    try {
      final fcm = FirebaseMessaging.instance;

      // Request remote notification permissions
      await fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      // Foreground notification presentation options (iOS / Android heads-up)
      await fcm.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Register background FCM handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Handle FCM messages when app is in foreground
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final notification = message.notification;
        if (notification != null && !kIsWeb) {
          showInstantNotification(
            title: notification.title ?? 'IntentFlow Reminder',
            body: notification.body ?? '',
          );
        }
      });
    } catch (e) {
      debugPrint('FCM initialization warning: $e');
    }

    _initialized = true;
  }

  /// Displays an immediate high-priority heads-up banner notification
  /// with sound and vibration.
  Future<void> showInstantNotification({
    required String title,
    required String body,
    int id = 0,
  }) async {
    if (kIsWeb) return;

    final androidDetails = AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.reminder,
      visibility: NotificationVisibility.public,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _local.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
  }

  /// Schedules a reminder for an upcoming task at its exact date & time.
  /// Uses Android exact alarms so the notification will fire even when the
  /// phone screen is off or another app is open.
  Future<void> scheduleTaskReminder(TaskModel task) async {
    if (kIsWeb || task.done) return;

    final scheduledDate = task.dateTime;
    if (scheduledDate.isBefore(DateTime.now())) {
      // Do not schedule notifications in the past
      return;
    }

    final id = task.id.hashCode;
    final tzScheduled = tz.TZDateTime.from(scheduledDate, tz.local);

    final androidDetails = AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.reminder,
      visibility: NotificationVisibility.public,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    try {
      await _local.zonedSchedule(
        id: id,
        title: 'Task Reminder: ${task.title}',
        body: 'It\'s time for: ${task.title} (${task.category})',
        scheduledDate: tzScheduled,
        notificationDetails: NotificationDetails(android: androidDetails, iOS: iosDetails),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint('Error scheduling task reminder: $e');
    }
  }

  /// Cancels any scheduled notification for the given task id.
  Future<void> cancelTaskReminder(String taskId) async {
    if (kIsWeb) return;
    try {
      await _local.cancel(id: taskId.hashCode);
    } catch (_) {}
  }

  /// Synchronizes scheduled notifications for a list of tasks.
  Future<void> syncReminders(List<TaskModel> tasks) async {
    if (kIsWeb) return;
    final now = DateTime.now();
    for (final task in tasks) {
      if (task.done || task.dateTime.isBefore(now)) {
        await cancelTaskReminder(task.id);
      } else {
        await scheduleTaskReminder(task);
      }
    }
  }
}
