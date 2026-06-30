import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import 'login_screen.dart';
import 'admin_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Profile',
            style: TextStyle(color: AppColors.textPrimary)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 44,
              backgroundColor: AppColors.cardBg,
              backgroundImage: user?.photoUrl != null
                  ? NetworkImage(user!.photoUrl!)
                  : null,
              child: user?.photoUrl == null
                  ? Text(
                Helpers.getInitials(user?.name ?? 'U'),
                style: const TextStyle(
                    fontSize: 28,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600),
              )
                  : null,
            ),
            const SizedBox(height: 14),
            Text(user?.name ?? '',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            Text(user?.email ?? '',
                style: const TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 24),
            if (user?.isAdmin == true)
              ListTile(
                leading: const Icon(Icons.admin_panel_settings,
                    color: AppColors.primary),
                title: const Text('Admin Controls'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminScreen()),
                ),
              ),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text('Logout',
                  style: TextStyle(color: AppColors.error)),
              onTap: () async {
                await ref.read(authServiceProvider).logout();
                ref.read(currentUserProvider.notifier).state = null;
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}