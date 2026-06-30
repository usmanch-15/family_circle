import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_settings_model.dart';
import '../utils/constants.dart';

class SuperAdminService {
  final _firestore = FirebaseFirestore.instance;

  static const String superAdminPassword = 'FamilyCircle@2026';

  bool verifyPassword(String input) => input == superAdminPassword;

  Stream<AppSettingsModel> dashboardStream() {
    return _firestore
        .collection(Collections.families)
        .snapshots()
        .asyncMap((familiesSnap) async {
      final usersSnap = await _firestore.collection(Collections.users).get();
      final mediaSnap = await _firestore.collection(Collections.media).get();

      return AppSettingsModel(
        totalGroups:        familiesSnap.docs.length,
        totalUsers:         usersSnap.docs.length,
        totalMediaUploaded: mediaSnap.docs.length,
        activeGroupsToday:  _countActiveToday(familiesSnap.docs),
        lastUpdated:        DateTime.now(),
      );
    });
  }

  int _countActiveToday(List<QueryDocumentSnapshot> docs) {
    final today = DateTime.now();
    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final created = (data['createdAt'] as Timestamp?)?.toDate();
      if (created == null) return false;
      return created.year == today.year &&
          created.month == today.month &&
          created.day == today.day;
    }).length;
  }

  Stream<List<Map<String, dynamic>>> allGroupsStream() {
    return _firestore
        .collection(Collections.families)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((d) => {...d.data(), 'id': d.id})
        .toList());
  }

  Future<void> forceDeleteGroup(String familyId) async {
    await _firestore.collection(Collections.families).doc(familyId).delete();
  }
}