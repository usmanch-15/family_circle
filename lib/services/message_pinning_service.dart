import 'package:cloud_firestore/cloud_firestore.dart';

class MessagePinningService {
  final _firestore = FirebaseFirestore.instance;

  Future<void> pinMessage({
    required String familyId,
    required String messageId,
    required String messageText,
    required String pinnedByName,
  }) async {
    await _firestore
        .collection('families')
        .doc(familyId)
        .collection('pinned_messages')
        .doc(messageId)
        .set({
      'messageId':    messageId,
      'text':         messageText,
      'pinnedBy':     pinnedByName,
      'pinnedAt':     Timestamp.now(),
    });
  }

  Future<void> unpinMessage({
    required String familyId,
    required String messageId,
  }) async {
    await _firestore
        .collection('families')
        .doc(familyId)
        .collection('pinned_messages')
        .doc(messageId)
        .delete();
  }

  Stream<List<Map<String, dynamic>>> pinnedMessagesStream(String familyId) {
    return _firestore
        .collection('families')
        .doc(familyId)
        .collection('pinned_messages')
        .orderBy('pinnedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((d) => {...d.data(), 'id': d.id})
        .toList());
  }
}
