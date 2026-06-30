import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/constants.dart';
import '../providers/auth_provider.dart';
import '../providers/groups_provider.dart';
import '../widgets/group_list_tile.dart';
import '../widgets/three_dot_menu.dart';
import '../widgets/loading_widget.dart';
import 'chat_screen.dart';
import 'new_family_setup_screen.dart';
import 'settings_screen.dart';
import 'camera_screen.dart';

class GroupsListScreen extends ConsumerWidget {
  const GroupsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final familyIds = user?.familyIds ?? [];

    final groupsAsync = ref.watch(myGroupsStreamProvider(familyIds));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text('Family Circle',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CameraScreen()),
            ),
          ),
          ThreeDotMenu(
            onNewFamily: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NewFamilySetupScreen()),
            ),
            onSettings: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: groupsAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (groups) {
          if (groups.isEmpty) {
            return _EmptyState();
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: groups.length,
            separatorBuilder: (_, __) =>
            const Divider(height: 1, indent: 78, color: AppColors.border),
            itemBuilder: (context, i) {
              final group = groups[i];
              return GroupListTile(
                family: group,
                onTap: () {
                  ref.read(currentGroupIdProvider.notifier).state = group.id;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(family: group),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NewFamilySetupScreen()),
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.groups_rounded,
                  size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            const Text('Koi family group nahi hai',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            const Text(
              '+ button dabakar naya family group banayein',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}