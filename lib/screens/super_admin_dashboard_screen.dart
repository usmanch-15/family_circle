import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../services/super_admin_service.dart';
import '../widgets/super_admin_stat_card.dart';

class SuperAdminDashboardScreen extends StatelessWidget {
  const SuperAdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = SuperAdminService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Super Admin Dashboard',
            style: TextStyle(color: Colors.white)),
      ),
      body: StreamBuilder(
        stream: service.dashboardStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final stats = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  SuperAdminStatCard(
                    label: 'Total Groups',
                    value: '${stats.totalGroups}',
                    icon: Icons.groups_rounded,
                    color: AppColors.primary,
                  ),
                  SuperAdminStatCard(
                    label: 'Total Users',
                    value: '${stats.totalUsers}',
                    icon: Icons.people_rounded,
                    color: const Color(0xFF1D9E75),
                  ),
                  SuperAdminStatCard(
                    label: 'Media Uploaded',
                    value: '${stats.totalMediaUploaded}',
                    icon: Icons.photo_library_rounded,
                    color: const Color(0xFFD85A30),
                  ),
                  SuperAdminStatCard(
                    label: 'Active Today',
                    value: '${stats.activeGroupsToday}',
                    icon: Icons.bolt_rounded,
                    color: const Color(0xFFBA7517),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Saare groups',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted)),
              const SizedBox(height: 10),
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: service.allGroupsStream(),
                builder: (context, groupSnap) {
                  if (!groupSnap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final groups = groupSnap.data!;
                  return Column(
                    children: groups.map((g) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(g['name'] ?? ''),
                          subtitle: Text(
                              '${(g['memberIds'] as List?)?.length ?? 0} members'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: AppColors.error),
                            onPressed: () async {
                              await service.forceDeleteGroup(g['id']);
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}