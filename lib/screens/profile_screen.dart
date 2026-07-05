import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../providers/auth_provider.dart';
import '../providers/groups_provider.dart';
import 'login_screen.dart';
import 'admin_screen.dart';

import 'emergency_contacts_screen.dart';
import 'medical_records_screen.dart';
import 'family_tree_screen.dart';
import 'call_history_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user      = ref.watch(currentUserProvider);
    final familyIds = user?.familyIds ?? [];
    final groupsAsync = ref.watch(myGroupsStreamProvider(familyIds));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF6C3AE8), Color(0xFF5028C8)],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 46,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            backgroundImage: user?.photoUrl != null
                                ? NetworkImage(user!.photoUrl!) : null,
                            child: user?.photoUrl == null
                                ? Text(Helpers.getInitials(user?.name ?? 'U'),
                                style: const TextStyle(fontSize: 30,
                                    color: Colors.white, fontWeight: FontWeight.w700))
                                : null,
                          ),
                          Positioned(
                            right: 0, bottom: 0,
                            child: Container(
                              width: 28, height: 28,
                              decoration: BoxDecoration(
                                color: Colors.white, shape: BoxShape.circle,
                                border: Border.all(color: AppColors.primary, width: 2),
                              ),
                              child: const Icon(Icons.camera_alt, size: 14, color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(user?.name ?? '',
                          style: const TextStyle(fontSize: 18,
                              fontWeight: FontWeight.w700, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(user?.email ?? '',
                          style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.8))),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 12),

                // Stats
                groupsAsync.when(
                  loading: () => const SizedBox(),
                  error:   (e, _) => const SizedBox(),
                  data:    (groups) => Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      children: [
                        _StatItem(value: '${groups.length}', label: 'Groups'),
                        _Divider(),
                        _StatItem(
                          value: user?.isAdmin == true ? 'Admin' : 'Member',
                          label: 'Role',
                        ),
                        _Divider(),
                        _StatItem(
                          value: Helpers.formatDate(user?.createdAt ?? DateTime.now()),
                          label: 'Joined',
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Profile actions
                _SectionLabel('Profile'),
                _Tile(
                  icon: Icons.person_outline, iconColor: AppColors.primary,
                  title: 'Naam change karein', subtitle: user?.name ?? '',
                  onTap: () => _editName(context, ref, user?.name ?? ''),
                ),
                _Tile(
                  icon: Icons.photo_camera_outlined, iconColor: const Color(0xFF0891B2),
                  title: 'Profile photo', subtitle: 'Photo update karein',
                  onTap: () => _showSnack(context, 'Photo upload Android app mein available hoga'),
                ),

                const SizedBox(height: 12),

                // Family groups
                _SectionLabel('Meri Family Groups'),
                groupsAsync.when(
                  loading: () => const Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator()),
                  error: (e, _) => const SizedBox(),
                  data: (groups) {
                    if (groups.isEmpty) {
                      return Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(20),
                        child: const Text('Koi group nahi hai',
                            style: TextStyle(color: AppColors.textMuted)),
                      );
                    }
                    return Column(
                      children: groups.map((g) => Container(
                        color: Colors.white,
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.cardBg,
                            child: Text(Helpers.getInitials(g.name),
                                style: const TextStyle(color: AppColors.primary,
                                    fontWeight: FontWeight.w700, fontSize: 13)),
                          ),
                          title: Text(g.name,
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('${g.memberCount} members'),
                          trailing: g.isAdmin(user?.uid ?? '')
                              ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                                color: AppColors.cardBg,
                                borderRadius: BorderRadius.circular(20)),
                            child: const Text('Admin',
                                style: TextStyle(fontSize: 11,
                                    color: AppColors.primary, fontWeight: FontWeight.w600)),
                          )
                              : null,
                        ),
                      )).toList(),
                    );
                  },
                ),

                const SizedBox(height: 12),

                // Family features
                _SectionLabel('Family Features'),
                _Tile(
                  icon: Icons.account_tree_outlined, iconColor: const Color(0xFF7C3AED),
                  title: 'Family Tree', subtitle: 'Poora family hierarchy',
                  onTap: () {
                    final fid = user?.familyIds.firstOrNull;
                    if (fid != null) {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => FamilyTreeScreen(familyId: fid)));
                    } else {
                      _showSnack(context, 'Pehle family join karein');
                    }
                  },
                ),
                _Tile(
                  icon: Icons.emergency_outlined, iconColor: const Color(0xFFEF4444),
                  title: 'Emergency Contacts', subtitle: 'Doctor, police numbers',
                  onTap: () {
                    final fid = user?.familyIds.firstOrNull;
                    if (fid != null) {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => EmergencyContactsScreen(familyId: fid)));
                    } else {
                      _showSnack(context, 'Pehle family join karein');
                    }
                  },
                ),
                _Tile(
                  icon: Icons.medical_services_outlined, iconColor: const Color(0xFF0891B2),
                  title: 'Medical Records', subtitle: 'Blood type, allergies',
                  onTap: () {
                    if (user != null) {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (_) => MedicalRecordsScreen(
                              memberUid: user.uid, memberName: user.name)));
                    }
                  },
                ),
                _Tile(
                  icon: Icons.call_outlined, iconColor: const Color(0xFF059669),
                  title: 'Call History', subtitle: 'Purani calls ki list',
                  onTap: () {
                    final fid = user?.familyIds.firstOrNull;
                    if (fid != null) {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => CallHistoryScreen(familyId: fid)));
                    } else {
                      _showSnack(context, 'Pehle family join karein');
                    }
                  },
                ),

                const SizedBox(height: 12),

                // Admin
                if (user?.isAdmin == true) ...[
                  _SectionLabel('Admin'),
                  _Tile(
                    icon: Icons.admin_panel_settings_outlined,
                    iconColor: const Color(0xFF6C3AE8),
                    title: 'Admin Controls', subtitle: 'Members manage karein',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const AdminScreen())),
                  ),
                  const SizedBox(height: 12),
                ],

                // Logout
                Container(
                  color: Colors.white,
                  child: ListTile(
                    leading: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.logout, color: AppColors.error, size: 20),
                    ),
                    title: const Text('Logout',
                        style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          title: const Text('Logout'),
                          content: const Text('Kya aap logout karna chahte hain?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false),
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
                          Navigator.pushAndRemoveUntil(context,
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                                  (route) => false);
                        }
                      }
                    },
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _editName(BuildContext context, WidgetRef ref, String currentName) {
    final ctrl = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Naam change karein'),
        content: TextField(controller: ctrl, autofocus: true,
            decoration: const InputDecoration(hintText: 'Naya naam')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final user = ref.read(currentUserProvider);
              if (user != null && ctrl.text.trim().isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('users').doc(user.uid)
                    .update({'name': ctrl.text.trim()});
                ref.read(currentUserProvider.notifier).state =
                    user.copyWith(name: ctrl.text.trim());
              }
              Navigator.pop(ctx);
              _showSnack(context, 'Naam update ho gaya!');
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.primary),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value, label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(children: [
      Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
          color: AppColors.textPrimary)),
      const SizedBox(height: 3),
      Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
    ]),
  );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 32, color: AppColors.border);
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(text.toUpperCase(),
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
              color: AppColors.textMuted, letterSpacing: 0.8)),
    ),
  );
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title, subtitle;
  final VoidCallback onTap;
  const _Tile({required this.icon, required this.iconColor,
    required this.title, required this.subtitle, required this.onTap});

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
      title: Text(title, style: const TextStyle(fontSize: 14,
          fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
      subtitle: Text(subtitle,
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18),
    ),
  );
}