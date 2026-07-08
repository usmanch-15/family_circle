import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PresenceService {
  final _firestore = FirebaseFirestore.instance;
  final _auth      = FirebaseAuth.instance;

  Future<void> setOnline() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _firestore.collection('presence').doc(uid).set({
      'uid':      uid,
      'online':   true,
      'lastSeen': Timestamp.now(),
    });
  }

  Future<void> setOffline() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _firestore.collection('presence').doc(uid).set({
      'uid':      uid,
      'online':   false,
      'lastSeen': Timestamp.now(),
    });
  }

  Stream<bool> isOnlineStream(String uid) {
    return _firestore
        .collection('presence')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists && (doc.data()?['online'] == true));
  }

  Stream<DateTime?> lastSeenStream(String uid) {
    return _firestore
        .collection('presence')
        .doc(uid)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      final ts = doc.data()?['lastSeen'] as Timestamp?;
      return ts?.toDate();
    });
  }
}
