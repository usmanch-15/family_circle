import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/family_service.dart';
import '../models/family_model.dart';

final familyServiceProvider = Provider<FamilyService>((ref) {
  return FamilyService();
});

final currentFamilyIdProvider = StateProvider<String?>((ref) => null);

final familyStreamProvider = StreamProvider.family<FamilyModel?, String>(
      (ref, familyId) {
    return ref.read(familyServiceProvider).familyStream(familyId);
  },
);

final familyLoadingProvider = StateProvider<bool>((ref) => false);
final familyErrorProvider   = StateProvider<String?>((ref) => null);