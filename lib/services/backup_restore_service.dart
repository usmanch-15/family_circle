import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';

class BackupRestoreService {
  final _firestore = FirebaseFirestore.instance;

  // Family ka pura data ek JSON mein export karna
  Future<String> exportFamilyData(String familyId) async {
    final familyDoc = await _firestore
        .collection(Collections.families)
        .doc(familyId)
        .get();

    final mediaSnap = await _firestore
        .collection(Collections.media)
        .where('familyId', isEqualTo: familyId)
        .get();

    final eventsSnap = await _firestore
        .collection('events')
        .where('familyId', isEqualTo: familyId)
        .get();

    final backup = {
      'family': familyDoc.data(),
      'media': mediaSnap.docs.map((d) => d.data()).toList(),
      'events': eventsSnap.docs.map((d) => d.data()).toList(),
      'exportedAt': DateTime.now().toIso8601String(),
    };

    return jsonEncode(backup);
  }

  // Backup se data wapis restore karna
  Future<void> restoreFromBackup(String jsonData, String familyId) async {
    final backup = jsonDecode(jsonData) as Map<String, dynamic>;

    if (backup['events'] != null) {
      for (final event in backup['events']) {
        await _firestore.collection('events').add({
          ...event,
          'familyId': familyId,
        });
      }
    }
  }

  // Automatic daily backup - timestamp save karna
  Future<void> markBackupComplete(String familyId) async {
    await _firestore.collection('backups').add({
      'familyId': familyId,
      'completedAt': Timestamp.now(),
    });
  }

  Future<DateTime?> lastBackupDate(String familyId) async {
    final snap = await _firestore
        .collection('backups')
        .where('familyId', isEqualTo: familyId)
        .orderBy('completedAt', descending: true)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return null;
    return (snap.docs.first.data()['completedAt'] as Timestamp).toDate();
  }
}
