import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppThemeMode { light, dark, system }

final themeModeProvider = StateProvider<AppThemeMode>((ref) {
  return AppThemeMode.system;
});
