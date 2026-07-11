import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../utils/constants.dart';

/// Background message handler MUST be a top-level function (not inside a class)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase already shows the notification automatically when the app is
  // fully killed / backgrounded and the payload has a `notification` block.
  // Nothing else to do here for now.
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final _fcm = FirebaseMessaging.instance;
  final _local = FlutterLocalNotificationsPlugin();
  final _firestore = FirebaseFirestore.instance;

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    tz.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings =
    InitializationSettings(android: androidInit, iOS: iosInit);
    await _local.initialize(initSettings);

    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((message) {
      final notif = message.notification;
      if (notif != null) {
        _showLocalNotification(
          title: notif.title ?? AppStrings.appName,
          body: notif.body ?? '',
        );
      }
    });

    // Token save/refresh only makes sense once someone is logged in.
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) _syncToken(user.uid);
    });
  }

  Future<void> _syncToken(String uid) async {
    try {
      final token = await _fcm.getToken();
      if (token == null) return;
      await _firestore.collection(Collections.users).doc(uid).set(
        {'fcmToken': token, 'tokenUpdatedAt': Timestamp.now()},
        SetOptions(merge: true),
      );
      _fcm.onTokenRefresh.listen((newToken) {
        _firestore.collection(Collections.users).doc(uid).set(
          {'fcmToken': newToken, 'tokenUpdatedAt': Timestamp.now()},
          SetOptions(merge: true),
        );
      });
    } catch (_) {
      // Token sync failing shouldn't crash the app - reminders still work locally.
    }
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'family_circle_channel',
      'Family Circle Notifications',
      channelDescription: 'Chat, tasks, events aur reminders',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _local.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000 % 100000,
      title,
      body,
      details,
    );
  }

  /// General purpose scheduled local reminder (task/event/birthday).
  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (scheduledDate.isBefore(DateTime.now())) return;

    const androidDetails = AndroidNotificationDetails(
      'reminders_channel',
      'Reminders',
      channelDescription: 'Task, event aur birthday reminders',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _local.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelReminder(int id) async {
    await _local.cancel(id);
  }

  Future<void> scheduleBirthdayReminder({
    required String memberId,
    required String memberName,
    required DateTime birthday,
  }) async {
    final now = DateTime.now();
    var nextBirthday = DateTime(now.year, birthday.month, birthday.day);
    if (nextBirthday.isBefore(now)) {
      nextBirthday = DateTime(now.year + 1, birthday.month, birthday.day);
    }
    final reminderDay = nextBirthday.subtract(const Duration(days: 1));
    final scheduledAt =
    DateTime(reminderDay.year, reminderDay.month, reminderDay.day, 9, 0);

    await scheduleReminder(
      id: memberId.hashCode,
      title: '🎂 Kal Birthday hai!',
      body: '$memberName ka kal birthday hai — wish karna na bhoolna!',
      scheduledDate: scheduledAt,
    );
  }

  Future<void> scheduleTaskReminder({
    required String taskId,
    required String taskTitle,
    required DateTime dueDate,
  }) async {
    await scheduleReminder(
      id: taskId.hashCode,
      title: '✅ Task Reminder',
      body: '"$taskTitle" - 2 ghante mein due hai',
      scheduledDate: dueDate.subtract(const Duration(hours: 2)),
    );
  }

  Future<void> scheduleEventReminder({
    required String eventId,
    required String eventTitle,
    required DateTime eventDate,
  }) async {
    await scheduleReminder(
      id: eventId.hashCode,
      title: '📅 Kal Event hai',
      body: '"$eventTitle" kal hai — tayyari kar lo!',
      scheduledDate: eventDate.subtract(const Duration(days: 1)),
    );
  }
}