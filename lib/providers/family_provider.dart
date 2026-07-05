import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/family_service.dart';

// Yeh purana family_provider.dart hai - groups_provider.dart use karo
// Lekin join_family_screen ke liye zaroorat hai
final familyServiceProvider = Provider<FamilyService>((ref) {
  return FamilyService();
});