import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/family_model.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class FamilyService {
  final _firestore = FirebaseFirestore.instance;

  // ─── Naya family group banana ─────────────────────────
  Future<FamilyModel> createFamily({
    required String name,
    required String adminUid,
  }) async {
    final inviteCode = Helpers.generateInviteCode(name);

    final docRef = _firestore.collection(Collections.families).doc();

    final family = FamilyModel(
      id:         docRef.id,
      name:       name,
      adminUid:   adminUid,
      inviteCode: inviteCode,
      memberIds:  [adminUid],
      createdAt:  DateTime.now(),
    );

    await docRef.set(family.toMap());

    // User ke document mein familyIds list update karo (UserModel isi field ko padhta hai)
    await _firestore.collection(Collections.users).doc(adminUid).update({
      'familyIds': FieldValue.arrayUnion([docRef.id]),
      'role': 'admin',
    });

    return family;
  }

  // ─── Invite code se family join karna ─────────────────
  Future<FamilyModel?> joinFamily({
    required String inviteCode,
    required String userUid,
  }) async {
    final query = await _firestore
        .collection(Collections.families)
        .where('inviteCode', isEqualTo: inviteCode)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw 'Invite code sahi nahi hai.';
    }

    final doc = query.docs.first;
    final family = FamilyModel.fromMap(doc.data(), doc.id);

    if (family.isMember(userUid)) {
      throw 'Aap pehle se is family ke member hain.';
    }

    // Member list mein add karo
    await _firestore.collection(Collections.families).doc(doc.id).update({
      'memberIds': FieldValue.arrayUnion([userUid]),
    });

    // User ke document mein familyIds list update karo (UserModel isi field ko padhta hai)
    await _firestore.collection(Collections.users).doc(userUid).update({
      'familyIds': FieldValue.arrayUnion([doc.id]),
      'role': 'member',
    });

    return family.copyWith(
      memberIds: [...family.memberIds, userUid],
    );
  }

  // ─── Family ka real-time data stream ──────────────────
  Stream<FamilyModel?> familyStream(String familyId) {
    return _firestore
        .collection(Collections.families)
        .doc(familyId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return FamilyModel.fromMap(doc.data()!, doc.id);
    });
  }

  // ─── Member remove karna (sirf admin) ─────────────────
  Future<void> removeMember({
    required String familyId,
    required String memberUid,
  }) async {
    await _firestore.collection(Collections.families).doc(familyId).update({
      'memberIds': FieldValue.arrayRemove([memberUid]),
    });

    await _firestore.collection(Collections.users).doc(memberUid).update({
      'familyIds': FieldValue.arrayRemove([familyId]),
    });
  }

  // ─── Invite code reset karna (sirf admin) ─────────────
  Future<String> resetInviteCode({
    required String familyId,
    required String familyName,
  }) async {
    final newCode = Helpers.generateInviteCode(familyName);
    await _firestore.collection(Collections.families).doc(familyId).update({
      'inviteCode': newCode,
    });
    return newCode;
  }

  // ─── AI enabled update karna (admin panel se) ─────────
  Future<void> updateAiEnabled({
    required String familyId,
    required bool enabled,
  }) async {
    await _firestore.collection(Collections.families).doc(familyId).update({
      'aiEnabled': enabled,
    });
  }
}