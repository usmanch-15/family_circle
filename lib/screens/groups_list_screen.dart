import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../providers/auth_provider.dart';
import '../providers/groups_provider.dart';
import '../models/family_model.dart';
import 'chat_screen.dart';
import 'new_family_setup_screen.dart';
import 'settings_screen.dart';
import 'camera_screen.dart';
import 'join_family_screen.dart';
import '../widgets/loading_widget.dart';

class GroupsListScreen extends ConsumerWidget {
  const GroupsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user      = ref.watch(currentUserProvider);
    final familyIds = user?.familyIds ?? [];
    final groupsAsync = ref.watch(myGroupsStreamProvider(familyIds));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text('Family Circle',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined, color: Colors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CameraScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () => _showSearch(context, ref),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (value) {
              if (value == 'new') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const NewFamilySetupScreen()));
              } else if (value == 'join') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const JoinFamilyScreen()));
              } else if (value == 'settings') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'new',
                  child: Row(children: [Icon(Icons.group_add_outlined, size: 18), SizedBox(width: 10), Text('New family')])),
              const PopupMenuItem(value: 'join',
                  child: Row(children: [Icon(Icons.link, size: 18), SizedBox(width: 10), Text('Join family')])),
              const PopupMenuItem(value: 'settings',
                  child: Row(children: [Icon(Icons.settings_outlined, size: 18), SizedBox(width: 10), Text('Settings')])),
            ],
          ),
        ],
      ),
      body: groupsAsync.when(
        loading: () => const LoadingWidget(),
        error:   (e, _) => Center(child: Text('Error: $e')),
        data:    (groups) {
          if (groups.isEmpty) return _EmptyState();
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: groups.length,
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 74, endIndent: 0, color: Color(0xFFEEEEEE)),
            itemBuilder: (context, i) {
              final group = groups[i];
              return _GroupTile(
                family: group,
                onTap: () {
                  ref.read(currentGroupIdProvider.notifier).state = group.id;
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(family: group)));
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        elevation: 4,
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewFamilySetupScreen())),
        child: const Icon(Icons.add, color: Colors.white, size: 26),
      ),
    );
  }

  void _showSearch(BuildContext context, WidgetRef ref) {
    showSearch(context: context, delegate: _GroupSearchDelegate(ref));
  }
}

// ─── Group Tile ───────────────────────────────────────────
class _GroupTile extends StatelessWidget {
  final FamilyModel family;
  final VoidCallback onTap;
  const _GroupTile({required this.family, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.cardBg,
                  backgroundImage: family.photoUrl != null ? NetworkImage(family.photoUrl!) : null,
                  child: family.photoUrl == null
                      ? Text(Helpers.getInitials(family.name),
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 16))
                      : null,
                ),
                if (family.aiEnabled)
                  Positioned(
                    right: 0, bottom: 0,
                    child: Container(
                      width: 16, height: 16,
                      decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5)),
                      child: const Icon(Icons.psychology_rounded, size: 10, color: Colors.white),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(family.name,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                            overflow: TextOverflow.ellipsis),
                      ),
                      Text(Helpers.formatDate(family.createdAt),
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(Icons.people_outline, size: 13, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text('${family.memberCount} members',
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      if (family.aiEnabled) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(10)),
                          child: const Text('AI', style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(color: AppColors.cardBg, shape: BoxShape.circle),
              child: const Icon(Icons.groups_rounded, size: 52, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            const Text('Koi family group nahi hai',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            const Text('+ button dabakar naya family group banayein\nya invite link se join karein',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, height: 1.5)),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewFamilySetupScreen())),
              icon: const Icon(Icons.add),
              label: const Text('Family Banayein'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const JoinFamilyScreen())),
              icon: const Icon(Icons.link),
              label: const Text('Join Karein'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                side: const BorderSide(color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Search Delegate ──────────────────────────────────────
class _GroupSearchDelegate extends SearchDelegate {
  final WidgetRef ref;
  _GroupSearchDelegate(this.ref);

  @override
  List<Widget> buildActions(BuildContext context) =>
      [IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')];

  @override
  Widget buildLeading(BuildContext context) =>
      IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, null));

  @override
  Widget buildResults(BuildContext context) => _buildList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildList(context);

  Widget _buildList(BuildContext context) {
    final user      = ref.read(currentUserProvider);
    final familyIds = user?.familyIds ?? [];
    return Consumer(
      builder: (context, ref, _) {
        final groupsAsync = ref.watch(myGroupsStreamProvider(familyIds));
        return groupsAsync.when(
          loading: () => const LoadingWidget(),
          error:   (e, _) => Center(child: Text('Error: $e')),
          data:    (groups) {
            final filtered = groups.where((g) => g.name.toLowerCase().contains(query.toLowerCase())).toList();
            if (filtered.isEmpty) return const Center(child: Text('Koi group nahi mila'));
            return ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, i) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.cardBg,
                  child: Text(Helpers.getInitials(filtered[i].name),
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                ),
                title: Text(filtered[i].name),
                subtitle: Text('${filtered[i].memberCount} members'),
                onTap: () {
                  close(context, null);
                  ref.read(currentGroupIdProvider.notifier).state = filtered[i].id;
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(family: filtered[i])));
                },
              ),
            );
          },
        );
      },
    );
  }
}