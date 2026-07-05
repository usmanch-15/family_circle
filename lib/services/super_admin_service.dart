import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_settings_model.dart';
import '../utils/constants.dart';

class SuperAdminService {
  final _firestore = FirebaseFirestore.instance;
  final _auth      = FirebaseAuth.instance;

  Future<bool> verifySuperAdmin(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email, password: password,
      );
      final doc = await _firestore
          .collection('super_admins')
          .doc(cred.user!.uid)
          .get();
      return doc.exists && doc.data()?['isActive'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isCurrentUserSuperAdmin() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    final doc = await _firestore
        .collection('super_admins')
        .doc(user.uid)
        .get();
    return doc.exists && doc.data()?['isActive'] == true;
  }

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
      final data    = doc.data() as Map<String, dynamic>;
      final created = (data['createdAt'] as Timestamp?)?.toDate();
      if (created == null) return false;
      return created.year == today.year &&
          created.month == today.month &&
          created.day == today.day;
    }).length;
  }

  Future<List<Map<String, dynamic>>> weeklyGrowth() async {
    final result = <Map<String, dynamic>>[];
    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final date  = now.subtract(Duration(days: i));
      final start = DateTime(date.year, date.month, date.day);
      final end   = start.add(const Duration(days: 1));
      final usersSnap = await _firestore
          .collection(Collections.users)
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('createdAt', isLessThan: Timestamp.fromDate(end))
          .get();
      final groupsSnap = await _firestore
          .collection(Collections.families)
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('createdAt', isLessThan: Timestamp.fromDate(end))
          .get();
      result.add({
        'day':    '${date.day}/${date.month}',
        'users':  usersSnap.docs.length,
        'groups': groupsSnap.docs.length,
      });
    }
    return result;
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

  Stream<List<Map<String, dynamic>>> allUsersStream() {
    return _firestore
        .collection(Collections.users)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((d) => {...d.data(), 'id': d.id})
        .toList());
  }

  Future<void> forceDeleteGroup(String familyId) async {
    final family = await _firestore
        .collection(Collections.families)
        .doc(familyId)
        .get();
    if (family.exists) {
      final memberIds = List<String>.from(family.data()?['memberIds'] ?? []);
      for (final uid in memberIds) {
        await _firestore.collection(Collections.users).doc(uid).update({
          'familyIds': FieldValue.arrayRemove([familyId]),
        });
      }
    }
    await _firestore.collection(Collections.families).doc(familyId).delete();
  }

  Future<void> suspendUser(String uid, bool suspend) async {
    await _firestore.collection(Collections.users).doc(uid).update({
      'isSuspended': suspend,
      'suspendedAt': suspend ? Timestamp.now() : null,
    });
  }

  Future<void> sendBroadcast(String title, String message) async {
    final families = await _firestore.collection(Collections.families).get();
    final batch = _firestore.batch();
    for (final family in families.docs) {
      final ref = _firestore
          .collection(Collections.families)
          .doc(family.id)
          .collection('announcements')
          .doc();
      batch.set(ref, {
        'title':     title,
        'message':   message,
        'createdAt': Timestamp.now(),
        'type':      'broadcast',
      });
    }
    await batch.commit();
  }

  Future<void> setupSuperAdmin(String uid) async {
    await _firestore.collection('super_admins').doc(uid).set({
      'uid':       uid,
      'isActive':  true,
      'createdAt': Timestamp.now(),
    });
  }
}