import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/family_service.dart';
import '../models/family_model.dart';
import '../utils/constants.dart';

final familyServiceProvider = Provider<FamilyService>((ref) {
  return FamilyService();
});

final myGroupsStreamProvider =
StreamProvider.family<List<FamilyModel>, List<String>>(
      (ref, familyIds) {
    if (familyIds.isEmpty) return Stream.value([]);
    return FirebaseFirestore.instance
        .collection(Collections.families)
        .where(FieldPath.documentId, whereIn: familyIds)
        .snapshots()
        .map((snap) => snap.docs
        .map((d) => FamilyModel.fromMap(d.data(), d.id))
        .toList());
  },
);

final currentGroupIdProvider = StateProvider<String?>((ref) => null);

final singleGroupStreamProvider =
StreamProvider.family<FamilyModel?, String>((ref, familyId) {
  return ref.read(familyServiceProvider).familyStream(familyId);
});

final groupsLoadingProvider = StateProvider<bool>((ref) => false);
final groupsErrorProvider   = StateProvider<String?>((ref) => null);