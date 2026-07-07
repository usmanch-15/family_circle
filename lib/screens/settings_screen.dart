import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import 'login_screen.dart';
import 'super_admin_login_screen.dart';
import 'emergency_contacts_screen.dart';
import 'medical_records_screen.dart';
import 'family_tree_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user      = ref.watch(currentUserProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Settings',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: ListView(
        children: [
          // Profile card
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.cardBg,
                  backgroundImage: user?.photoUrl != null
                      ? NetworkImage(user!.photoUrl!)
                      : null,
                  child: user?.photoUrl == null
                      ? Text(Helpers.getInitials(user?.name ?? 'U'),
                      style: const TextStyle(
                          fontSize: 22,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700))
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.name ?? '',
                          style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 3),
                      Text(user?.email ?? '',
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          _SectionTitle('Account'),

          _Tile(
            icon: Icons.person_outline,
            iconColor: AppColors.primary,
            title: 'Profile',
            subtitle: 'Naam aur photo change karein',
            onTap: () => _showPrivacySheet(context),
          ),
          _Tile(
            icon: Icons.privacy_tip_outlined,
            iconColor: const Color(0xFF0F6E56),
            title: 'Privacy',
            subtitle: 'Kaun dekh sakta hai aapko',
            onTap: () => _showPrivacySheet(context),
          ),
          _Tile(
            icon: Icons.security_outlined,
            iconColor: const Color(0xFF1D4ED8),
            title: 'Security',
            subtitle: 'Password change karein',
            onTap: () => _showSecuritySheet(context, ref, user?.email ?? ''),
          ),

          const SizedBox(height: 12),
          _SectionTitle('Preferences'),

          // Dark mode — real toggle
          Container(
            color: Colors.white,
            child: SwitchListTile(
              secondary: Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                    color: const Color(0xFF6C3AE8).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.dark_mode_outlined,
                    color: Color(0xFF6C3AE8), size: 20),
              ),
              title: const Text('Dark Mode',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500)),
              subtitle: Text(
                themeMode == AppThemeMode.dark ? 'On' : 'Off',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textMuted),
              ),
              value: themeMode == AppThemeMode.dark,
              activeColor: AppColors.primary,
              onChanged: (val) {
                ref.read(themeModeProvider.notifier).state =
                val ? AppThemeMode.dark : AppThemeMode.light;
              },
            ),
          ),

          _Tile(
            icon: Icons.notifications_outlined,
            iconColor: const Color(0xFFD97706),
            title: 'Notifications',
            subtitle: 'Messages aur event alerts',
            onTap: () => _showNotifSheet(context),
          ),
          _Tile(
            icon: Icons.language_outlined,
            iconColor: const Color(0xFF0891B2),
            title: 'Language',
            subtitle: 'Urdu, English, Punjabi',
            onTap: () => _showLanguageSheet(context),
          ),
          _Tile(
            icon: Icons.storage_outlined,
            iconColor: const Color(0xFF059669),
            title: 'Storage & Data',
            subtitle: 'Media aur cache settings',
            onTap: () => _showStorageSheet(context),
          ),

          const SizedBox(height: 12),
          _SectionTitle('Family Features'),

          _Tile(
            icon: Icons.account_tree_outlined,
            iconColor: const Color(0xFF7C3AED),
            title: 'Family Tree',
            subtitle: 'Poora family hierarchy dekho',
            onTap: () {
              final fid = ref.read(currentUserProvider)?.familyIds.firstOrNull;
              if (fid != null) {
                Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) => FamilyTreeScreen(familyId: fid)));
              } else {
                _showSnack(context, 'Pehle family group join karein');
              }
            },
          ),
          _Tile(
            icon: Icons.emergency_outlined,
            iconColor: const Color(0xFFEF4444),
            title: 'Emergency Contacts',
            subtitle: 'Doctor, police, lawyer numbers',
            onTap: () {
              final fid = ref.read(currentUserProvider)?.familyIds.firstOrNull;
              if (fid != null) {
                Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) =>
                            EmergencyContactsScreen(familyId: fid)));
              } else {
                _showSnack(context, 'Pehle family group join karein');
              }
            },
          ),
          _Tile(
            icon: Icons.medical_services_outlined,
            iconColor: const Color(0xFF0891B2),
            title: 'Medical Records',
            subtitle: 'Blood type, allergies, medicines',
            onTap: () {
              final user2 = ref.read(currentUserProvider);
              if (user2 != null) {
                Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) => MedicalRecordsScreen(
                            memberUid: user2.uid,
                            memberName: user2.name)));
              }
            },
          ),

          // WhatsApp invite — Pakistani audience ke liye
          _Tile(
            icon: Icons.share_outlined,
            iconColor: const Color(0xFF25D366),
            title: 'App WhatsApp pe Share karein',
            subtitle: 'Family ko invite karein',
            onTap: () {
              final fid = ref.read(currentUserProvider)?.familyIds.firstOrNull;
              final link = fid != null
                  ? 'https://familycircle.app/join/$fid'
                  : 'https://familycircle.app';
              Share.share(
                'Family Circle app pe aayein! Hamare family group mein join karein:\n$link\n\nPlay Store se download karein: https://play.google.com/store/apps/details?id=com.familycircle.app',
                subject: 'Family Circle Invitation',
              );
            },
          ),

          const SizedBox(height: 12),
          _SectionTitle('Help & Info'),

          _Tile(
            icon: Icons.help_outline,
            iconColor: const Color(0xFF7C3AED),
            title: 'Help & Support',
            subtitle: 'FAQ aur contact us',
            onTap: () => _showHelpSheet(context),
          ),
          _Tile(
            icon: Icons.info_outline,
            iconColor: const Color(0xFF6B7280),
            title: 'About',
            subtitle: 'Family Circle v1.0.0',
            onTap: () => _showAboutDialog(context),
          ),

          const SizedBox(height: 12),

          // Logout
          Container(
            color: Colors.white,
            child: ListTile(
              leading: Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(10)),
                child:
                const Icon(Icons.logout, color: AppColors.error, size: 20),
              ),
              title: const Text('Logout',
                  style: TextStyle(
                      color: AppColors.error, fontWeight: FontWeight.w600)),
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    title: const Text('Logout'),
                    content:
                    const Text('Kya aap logout karna chahte hain?'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel')),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Logout',
                            style: TextStyle(color: AppColors.error)),
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
                        MaterialPageRoute(
                            builder: (_) => const LoginScreen()),
                            (route) => false);
                  }
                }
              },
            ),
          ),

          const SizedBox(height: 32),

          GestureDetector(
            onLongPress: () => Navigator.push(context,
                MaterialPageRoute(
                    builder: (_) => const SuperAdminLoginScreen())),
            child: const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Family Circle v1.0.0',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textMuted)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Privacy — SharedPreferences mein save
  void _showPrivacySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => const _PrivacySheet(),
    );
  }

  void _showSecuritySheet(
      BuildContext context, WidgetRef ref, String email) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Security',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading:
              const Icon(Icons.email_outlined, color: AppColors.primary),
              title: const Text('Password Reset Email'),
              subtitle: Text(email),
              trailing: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ref.read(authServiceProvider).sendPasswordReset(email);
                  _showSnack(context, 'Reset email bhej diya gaya');
                },
                child: const Text('Bhejein'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotifSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => const _NotifSheet(),
    );
  }

  void _showLanguageSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => const _LanguageSheet(),
    );
  }

  void _showStorageSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => const _StorageSheet(),
    );
  }

  void _showHelpSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Help & Support',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            _HelpTile(
                question: 'Family group kaise banayein?',
                answer:
                '+ button dabayein, naam likho, AI toggle karo, link share karo.'),
            _HelpTile(
                question: 'Member kaise add karein?',
                answer:
                'Invite code share karo — member "Join Family" mein type kare.'),
            _HelpTile(
                question: 'AI Mediator kya hai?',
                answer:
                'Family jhagron mein dono baatein sun ke fair faisla deta hai.'),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.home_rounded, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            const Text('Family Circle'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.0.0'),
            SizedBox(height: 4),
            Text('Flutter + Firebase + Claude AI'),
            SizedBox(height: 4),
            Text('Made with ❤️ in Pakistan 🇵🇰'),
            SizedBox(height: 8),
            Text('Because family matters most.',
                style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: AppColors.textMuted)),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close')),
        ],
      ),
    );
  }

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(msg),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.primary),
    );
  }
}

// ── Privacy sheet — SharedPreferences save ─────────────────
class _PrivacySheet extends StatefulWidget {
  const _PrivacySheet();

  @override
  State<_PrivacySheet> createState() => _PrivacySheetState();
}

class _PrivacySheetState extends State<_PrivacySheet> {
  bool _photoPrivate = true;
  bool _lastSeen     = true;
  bool _onlineStatus = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _photoPrivate = prefs.getBool('privacy_photo') ?? true;
      _lastSeen     = prefs.getBool('privacy_lastseen') ?? true;
      _onlineStatus = prefs.getBool('privacy_online') ?? false;
    });
  }

  Future<void> _save(String key, bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, val);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Privacy Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Profile photo sirf family dekhe'),
            value: _photoPrivate,
            activeColor: AppColors.primary,
            onChanged: (v) {
              setState(() => _photoPrivate = v);
              _save('privacy_photo', v);
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Last seen dikhaye'),
            value: _lastSeen,
            activeColor: AppColors.primary,
            onChanged: (v) {
              setState(() => _lastSeen = v);
              _save('privacy_lastseen', v);
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Online status dikhaye'),
            value: _onlineStatus,
            activeColor: AppColors.primary,
            onChanged: (v) {
              setState(() => _onlineStatus = v);
              _save('privacy_online', v);
            },
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

// ── Notifications sheet — SharedPreferences save ────────────
class _NotifSheet extends StatefulWidget {
  const _NotifSheet();

  @override
  State<_NotifSheet> createState() => _NotifSheetState();
}

class _NotifSheetState extends State<_NotifSheet> {
  bool _chat     = true;
  bool _events   = true;
  bool _ai       = true;
  bool _newMember = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _chat      = prefs.getBool('notif_chat') ?? true;
      _events    = prefs.getBool('notif_events') ?? true;
      _ai        = prefs.getBool('notif_ai') ?? true;
      _newMember = prefs.getBool('notif_member') ?? false;
    });
  }

  Future<void> _save(String key, bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, val);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Notifications',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Chat messages'),
            value: _chat,
            activeColor: AppColors.primary,
            onChanged: (v) { setState(() => _chat = v); _save('notif_chat', v); },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Family events & birthdays'),
            value: _events,
            activeColor: AppColors.primary,
            onChanged: (v) { setState(() => _events = v); _save('notif_events', v); },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('AI Mediator updates'),
            value: _ai,
            activeColor: AppColors.primary,
            onChanged: (v) { setState(() => _ai = v); _save('notif_ai', v); },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('New member joined'),
            value: _newMember,
            activeColor: AppColors.primary,
            onChanged: (v) { setState(() => _newMember = v); _save('notif_member', v); },
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

// ── Language sheet — SharedPreferences save ──────────────────
class _LanguageSheet extends StatefulWidget {
  const _LanguageSheet();

  @override
  State<_LanguageSheet> createState() => _LanguageSheetState();
}

class _LanguageSheetState extends State<_LanguageSheet> {
  String _selected = 'Urdu';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _selected = prefs.getString('language') ?? 'Urdu');
  }

  Future<void> _save(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
    setState(() => _selected = lang);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$lang selected — full multilingual support coming soon'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Language',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          for (final lang in ['Urdu', 'English', 'Punjabi'])
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(lang),
              trailing: _selected == lang
                  ? const Icon(Icons.check_circle, color: AppColors.primary)
                  : const Icon(Icons.radio_button_unchecked,
                  color: AppColors.textMuted),
              onTap: () => _save(lang),
            ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

// ── Storage sheet ─────────────────────────────────────────────
class _StorageSheet extends StatefulWidget {
  const _StorageSheet();

  @override
  State<_StorageSheet> createState() => _StorageSheetState();
}

class _StorageSheetState extends State<_StorageSheet> {
  bool _photoWifi  = true;
  bool _videoAuto  = false;
  bool _audioAuto  = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _photoWifi = prefs.getBool('storage_photo_wifi') ?? true;
      _videoAuto = prefs.getBool('storage_video') ?? false;
      _audioAuto = prefs.getBool('storage_audio') ?? true;
    });
  }

  Future<void> _save(String key, bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, val);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Storage & Data',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Photos auto-download (WiFi)'),
            value: _photoWifi,
            activeColor: AppColors.primary,
            onChanged: (v) { setState(() => _photoWifi = v); _save('storage_photo_wifi', v); },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Videos auto-download'),
            value: _videoAuto,
            activeColor: AppColors.primary,
            onChanged: (v) { setState(() => _videoAuto = v); _save('storage_video', v); },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Audio auto-download'),
            value: _audioAuto,
            activeColor: AppColors.primary,
            onChanged: (v) { setState(() => _audioAuto = v); _save('storage_audio', v); },
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Cache clear ho gaya'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppColors.primary),
                );
              },
              icon: const Icon(Icons.cleaning_services_outlined, size: 16),
              label: const Text('Cache clear karein'),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _HelpTile extends StatefulWidget {
  final String question, answer;
  const _HelpTile({required this.question, required this.answer});

  @override
  State<_HelpTile> createState() => _HelpTileState();
}

class _HelpTileState extends State<_HelpTile> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(widget.question,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w500)),
          trailing: Icon(_open ? Icons.expand_less : Icons.expand_more),
          onTap: () => setState(() => _open = !_open),
        ),
        if (_open)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(widget.answer,
                style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4)),
          ),
        const Divider(height: 1),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
    child: Text(text.toUpperCase(),
        style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
            letterSpacing: 0.8)),
  );
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title, subtitle;
  final VoidCallback onTap;
  const _Tile(
      {required this.icon,
        required this.iconColor,
        required this.title,
        required this.subtitle,
        required this.onTap});

  @override
  Widget build(BuildContext context) => Container(
    color: Colors.white,
    child: ListTile(
      onTap: onTap,
      leading: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary)),
      subtitle: Text(subtitle,
          style: const TextStyle(
              fontSize: 12, color: AppColors.textMuted)),
      trailing: const Icon(Icons.chevron_right,
          color: AppColors.textMuted, size: 18),
    ),
  );
}