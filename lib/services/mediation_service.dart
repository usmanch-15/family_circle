import 'package:cloud_firestore/cloud_firestore.dart';

/// Mediation session ko Firestore mein save/fetch karta hai taake
/// family ke past AI faisle history mein rahein, sirf ephemeral na hon.
class MediationService {
  final _firestore = FirebaseFirestore.instance;

  Future<void> saveSession({
    required String familyId,
    required String topic,
    required String partyAName,
    required String partyBName,
    required String partyAStatement,
    required String partyBStatement,
    required String decision,
    required String createdByUid,
  }) async {
    await _firestore
        .collection('families')
        .doc(familyId)
        .collection('mediation_sessions')
        .add({
      'topic':           topic,
      'partyAName':      partyAName,
      'partyBName':      partyBName,
      'partyAStatement': partyAStatement,
      'partyBStatement': partyBStatement,
      'decision':        decision,
      'createdByUid':    createdByUid,
      'createdAt':       Timestamp.now(),
    });
  }

  Stream<List<Map<String, dynamic>>> sessionsStream(String familyId) {
    return _firestore
        .collection('families')
        .doc(familyId)
        .collection('mediation_sessions')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs
        .map((d) => {...d.data(), 'id': d.id})
        .toList());
  }

  Future<void> deleteSession({
    required String familyId,
    required String sessionId,
  }) async {
    await _firestore
        .collection('families')
        .doc(familyId)
        .collection('mediation_sessions')
        .doc(sessionId)
        .delete();
  }
}