// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import '../models/event_model.dart';
// import 'event_service.dart';
//
// class NotificationService {
//   final _plugin = FlutterLocalNotificationsPlugin();
//   final _eventService = EventService();
//
//   Future<void> initialize() async {
//     const androidSettings =
//     AndroidInitializationSettings('@mipmap/ic_launcher');
//     const iosSettings = DarwinInitializationSettings();
//     const settings = InitializationSettings(
//       android: androidSettings,
//       iOS: iosSettings,
//     );
//     await _plugin.initialize(settings);
//   }
//
//   // Family ke aane wale events check karke notification dikhana
//   Future<void> checkAndNotifyUpcomingEvents(String familyId) async {
//     final events = await _eventService.upcomingEvents(familyId);
//
//     for (final event in events) {
//       if (event.daysUntil == 3 || event.daysUntil == 1 || event.daysUntil == 0) {
//         await _showNotification(
//           id: event.id.hashCode,
//           title: event.daysUntil == 0
//               ? 'Aaj hai! 🎉'
//               : '${event.daysUntil} din baqi hain',
//           body: event.title,
//         );
//       }
//     }
//   }
//
//   Future<void> _showNotification({
//     required int id,
//     required String title,
//     required String body,
//   }) async {
//     const androidDetails = AndroidNotificationDetails(
//       'family_circle_events',
//       'Family Events',
//       channelDescription: 'Birthday aur anniversary reminders',
//       importance: Importance.high,
//       priority: Priority.high,
//     );
//     const iosDetails = DarwinNotificationDetails();
//     const details = NotificationDetails(
//       android: androidDetails,
//       iOS: iosDetails,
//     );
//
//     await _plugin.show(id, title, body, details);
//   }
// }
