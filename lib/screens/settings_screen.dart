import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'super_admin_login_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: ListView(
        children: [
          // ── Profile card ──────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: AppColors.cardBg,
                      backgroundImage: user?.photoUrl != null ? NetworkImage(user!.photoUrl!) : null,
                      child: user?.photoUrl == null
                          ? Text(Helpers.getInitials(user?.name ?? 'U'),
                          style: const TextStyle(fontSize: 22, color: AppColors.primary, fontWeight: FontWeight.w700))
                          : null,
                    ),
                    Positioned(
                      right: 0, bottom: 0,
                      child: Container(
                        width: 20, height: 20,
                        decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                        child: const Icon(Icons.edit, size: 10, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.name ?? '', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      const SizedBox(height: 3),
                      Text(user?.email ?? '', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          user?.isAdmin == true ? 'Admin' : 'Member',
                          style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textMuted),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Account section ───────────────────────────
          _SectionTitle(title: 'Account'),
          _SettingsTile(icon: Icons.person_outline, iconColor: AppColors.primary,
              title: 'Profile', subtitle: 'Naam aur photo change karein', onTap: () {}),
          _SettingsTile(icon: Icons.privacy_tip_outlined, iconColor: const Color(0xFF0F6E56),
              title: 'Privacy', subtitle: 'Kaun dekh sakta hai aapko', onTap: () {}),
          _SettingsTile(icon: Icons.security_outlined, iconColor: const Color(0xFF1D4ED8),
              title: 'Security', subtitle: 'Password aur two-step', onTap: () {}),

          const SizedBox(height: 12),

          // ── Preferences section ───────────────────────
          _SectionTitle(title: 'Preferences'),
          _SettingsTile(icon: Icons.notifications_outlined, iconColor: const Color(0xFFD97706),
              title: 'Notifications', subtitle: 'Messages, events aur alerts', onTap: () {}),
          _SettingsTile(icon: Icons.dark_mode_outlined, iconColor: const Color(0xFF6C3AE8),
              title: 'Theme', subtitle: 'Light ya dark mode', onTap: () {}),
          _SettingsTile(icon: Icons.language_outlined, iconColor: const Color(0xFF0891B2),
              title: 'Language', subtitle: 'Urdu, English, Punjabi', onTap: () {}),
          _SettingsTile(icon: Icons.data_usage_outlined, iconColor: const Color(0xFF059669),
              title: 'Storage & Data', subtitle: 'Media auto-download settings', onTap: () {}),

          const SizedBox(height: 12),

          // ── Support section ───────────────────────────
          _SectionTitle(title: 'Help'),
          _SettingsTile(icon: Icons.help_outline, iconColor: const Color(0xFF7C3AED),
              title: 'Help & Support', subtitle: 'FAQ aur contact us', onTap: () {}),
          _SettingsTile(icon: Icons.info_outline, iconColor: const Color(0xFF6B7280),
              title: 'About', subtitle: 'Version, licenses', onTap: () {}),

          const SizedBox(height: 12),

          // ── Logout ────────────────────────────────────
          Container(
            color: Colors.white,
            child: ListTile(
              leading: Container(
                width: 38, height: 38,
                decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.logout, color: AppColors.error, size: 20),
              ),
              title: const Text('Logout', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Kya aap logout karna chahte hain?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Logout', style: TextStyle(color: AppColors.error)),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await ref.read(authServiceProvider).logout();
                  ref.read(currentUserProvider.notifier).state = null;
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (route) => false,
                    );
                  }
                }
              },
            ),
          ),

          const SizedBox(height: 32),

          // Hidden super admin
          GestureDetector(
            onLongPress: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SuperAdminLoginScreen()),
            ),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text('Family Circle v1.0.0',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(title.toUpperCase(),
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 0.8)),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({required this.icon, required this.iconColor, required this.title,
    required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 38, height: 38,
          decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18),
      ),
    );
  }
}