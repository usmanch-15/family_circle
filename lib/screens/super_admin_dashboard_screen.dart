import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../services/super_admin_service.dart';
import '../models/app_settings_model.dart';
import '../utils/helpers.dart';

class SuperAdminDashboardScreen extends StatelessWidget {
  const SuperAdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SuperAdminService service = SuperAdminService();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.shield_rounded, size: 16, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            const Text('Super Admin', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
            child: Row(
              children: [
                Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                const SizedBox(width: 5),
                const Text('Live', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
      body: StreamBuilder<AppSettingsModel>(
        stream: service.dashboardStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          final stats = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Stats grid ───────────────────────────
              Text('OVERVIEW',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.4), letterSpacing: 0.8)),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.5,
                children: [
                  _StatCard(label: 'Total Groups',   value: '${stats.totalGroups}',        icon: Icons.groups_rounded,         color: AppColors.primary),
                  _StatCard(label: 'Total Users',    value: '${stats.totalUsers}',         icon: Icons.people_rounded,         color: const Color(0xFF10B981)),
                  _StatCard(label: 'Media Files',    value: '${stats.totalMediaUploaded}', icon: Icons.photo_library_rounded,  color: const Color(0xFFF59E0B)),
                  _StatCard(label: 'Active Today',   value: '${stats.activeGroupsToday}',  icon: Icons.bolt_rounded,           color: const Color(0xFFEF4444)),
                ],
              ),

              const SizedBox(height: 20),

              Text('LAST UPDATE',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.4), letterSpacing: 0.8)),
              const SizedBox(height: 6),
              Text(Helpers.timeAgo(stats.lastUpdated),
                  style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.6))),

              const SizedBox(height: 20),

              // ── All groups ────────────────────────────
              Text('ALL GROUPS',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.4), letterSpacing: 0.8)),
              const SizedBox(height: 10),

              StreamBuilder<List<Map<String, dynamic>>>(
                stream: service.allGroupsStream(),
                builder: (context, groupSnap) {
                  if (!groupSnap.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  final groups = groupSnap.data!;

                  if (groups.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(12)),
                      child: Center(child: Text('Koi group nahi', style: TextStyle(color: Colors.white.withOpacity(0.4)))),
                    );
                  }

                  return Column(
                    children: groups.map((g) {
                      final memberCount = (g['memberIds'] as List?)?.length ?? 0;
                      final aiEnabled  = g['aiEnabled'] == true;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.06)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                              child: const Icon(Icons.groups_rounded, color: AppColors.primary, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(g['name'] ?? 'Unknown',
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                                      ),
                                      if (aiEnabled)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                                          child: const Text('AI', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w700)),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text('$memberCount members',
                                      style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 20),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    backgroundColor: const Color(0xFF1A1A1A),
                                    title: const Text('Group Delete?', style: TextStyle(color: Colors.white)),
                                    content: Text('Kya aap "${g['name']}" delete karna chahte hain?',
                                        style: TextStyle(color: Colors.white.withOpacity(0.7))),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx, true),
                                        child: const Text('Delete', style: TextStyle(color: Color(0xFFEF4444))),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) await service.forceDeleteGroup(g['id']);
                              },
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: 30),
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 17),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: color)),
              Text(label, style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.4))),
            ],
          ),
        ],
      ),
    );
  }
}