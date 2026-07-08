import 'package:cloud_firestore/cloud_firestore.dart';

class TypingService {
  final _firestore = FirebaseFirestore.instance;

  Future<void> setTyping({
    required String familyId,
    required String uid,
    required String name,
    required bool isTyping,
  }) async {
    final ref = _firestore
        .collection('families')
        .doc(familyId)
        .collection('typing')
        .doc(uid);

    if (isTyping) {
      await ref.set({
        'uid':       uid,
        'name':      name,
        'isTyping':  true,
        'updatedAt': Timestamp.now(),
      });
    } else {
      await ref.delete().catchError((_) {});
    }
  }

  Stream<List<String>> typingUsersStream(String familyId, String myUid) {
    return _firestore
        .collection('families')
        .doc(familyId)
        .collection('typing')
        .snapshots()
        .map((snap) => snap.docs
        .where((d) => d.id != myUid)
        .map((d) => d.data()['name'] as String)
        .toList());
  }
}