import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class Helpers {
  static String formatDate(DateTime date) {
    return DateFormat('d MMM yyyy').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

  static String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Abhi';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min pehle';
    if (diff.inHours < 24) return '${diff.inHours} ghante pehle';
    if (diff.inDays < 7) return '${diff.inDays} din pehle';
    return formatDate(date);
  }

  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  static String generateInviteCode(String familyName) {
    final cleaned = familyName.replaceAll(' ', '');
    final random  = const Uuid().v4().substring(0, 6);
    return '$cleaned-$random';
  }

  static String getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}