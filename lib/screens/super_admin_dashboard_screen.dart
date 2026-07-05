import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../services/super_admin_service.dart';
import '../models/app_settings_model.dart';

class SuperAdminDashboardScreen extends StatefulWidget {
  const SuperAdminDashboardScreen({super.key});

  @override
  State<SuperAdminDashboardScreen> createState() => _SuperAdminDashboardScreenState();
}

class _SuperAdminDashboardScreenState extends State<SuperAdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  final _service = SuperAdminService();
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  void _showBroadcastDialog() {
    final titleCtrl = TextEditingController();
    final msgCtrl   = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.campaign, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 10),
          const Text('Broadcast', style: TextStyle(color: Colors.white, fontSize: 16)),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Title',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.07),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: msgCtrl,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Message — sab families tak jayega',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.07),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: TextStyle(color: Colors.white.withOpacity(0.5)))),
          ElevatedButton.icon(
            onPressed: () async {
              if (titleCtrl.text.isNotEmpty && msgCtrl.text.isNotEmpty) {
                await _service.sendBroadcast(titleCtrl.text.trim(), msgCtrl.text.trim());
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Broadcast bhej diya gaya!'), backgroundColor: AppColors.primary),
                );
              }
            },
            icon: const Icon(Icons.send, size: 16),
            label: const Text('Send'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(children: [
          Container(
            width: 30, height: 30,
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.shield_rounded, size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          const Text('Super Admin', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.campaign_outlined, color: Colors.white),
            onPressed: _showBroadcastDialog,
          ),
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.green.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
            child: Row(children: [
              Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
              const SizedBox(width: 5),
              const Text('Live', style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.w600)),
            ]),
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.white38,
          tabs: const [Tab(text: 'Overview'), Tab(text: 'Groups'), Tab(text: 'Users')],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _OverviewTab(service: _service),
          _GroupsTab(service: _service),
          _UsersTab(service: _service),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final SuperAdminService service;
  const _OverviewTab({required this.service});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppSettingsModel>(
      stream: service.dashboardStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        final stats = snapshot.data!;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionLabel('OVERVIEW'),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2, shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.5,
              children: [
                _StatCard(label: 'Total Groups',  value: '${stats.totalGroups}',        icon: Icons.groups_rounded,         color: AppColors.primary),
                _StatCard(label: 'Total Users',   value: '${stats.totalUsers}',         icon: Icons.people_rounded,         color: const Color(0xFF10B981)),
                _StatCard(label: 'Media Files',   value: '${stats.totalMediaUploaded}', icon: Icons.photo_library_rounded,  color: const Color(0xFFF59E0B)),
                _StatCard(label: 'Active Today',  value: '${stats.activeGroupsToday}',  icon: Icons.bolt_rounded,           color: const Color(0xFFEF4444)),
              ],
            ),
            const SizedBox(height: 20),
            _sectionLabel('WEEKLY GROWTH (7 days)'),
            const SizedBox(height: 10),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: service.weeklyGrowth(),
              builder: (context, snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                final data = snap.data!;
                return Container(
                  height: 160,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(14)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: data.map((d) {
                      final users  = d['users'] as int;
                      final groups = d['groups'] as int;
                      final maxVal = [users, groups, 1].reduce((a, b) => a > b ? a : b);
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text('$users', style: const TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 2),
                              Container(
                                height: users == 0 ? 4 : (users / maxVal * 80).clamp(4.0, 80.0),
                                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(4)),
                              ),
                              const SizedBox(height: 2),
                              Container(
                                height: groups == 0 ? 4 : (groups / maxVal * 50).clamp(4.0, 50.0),
                                decoration: BoxDecoration(color: const Color(0xFF10B981), borderRadius: BorderRadius.circular(4)),
                              ),
                              const SizedBox(height: 5),
                              Text(d['day'] as String, style: TextStyle(fontSize: 8, color: Colors.white.withOpacity(0.4))),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            Row(children: [
              _legend(AppColors.primary, 'Users'),
              const SizedBox(width: 16),
              _legend(const Color(0xFF10B981), 'Groups'),
            ]),
            const SizedBox(height: 16),
            Text(Helpers.timeAgo(stats.lastUpdated),
                style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.4))),
          ],
        );
      },
    );
  }

  Widget _sectionLabel(String t) => Text(t, style: TextStyle(fontSize: 11,
      fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.4), letterSpacing: 0.8));

  Widget _legend(Color color, String label) => Row(children: [
    Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
    const SizedBox(width: 5),
    Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
  ]);
}

class _GroupsTab extends StatelessWidget {
  final SuperAdminService service;
  const _GroupsTab({required this.service});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: service.allGroupsStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        final groups = snapshot.data!;
        if (groups.isEmpty) return Center(child: Text('Koi group nahi', style: TextStyle(color: Colors.white.withOpacity(0.4))));
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: groups.length,
          itemBuilder: (context, i) {
            final g           = groups[i];
            final memberCount = (g['memberIds'] as List?)?.length ?? 0;
            final aiEnabled   = g['aiEnabled'] == true;
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
                        Row(children: [
                          Expanded(child: Text(g['name'] ?? 'Unknown',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14))),
                          if (aiEnabled)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                              child: const Text('AI', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w700)),
                            ),
                        ]),
                        const SizedBox(height: 3),
                        Text('$memberCount members', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.copy, color: Colors.white.withOpacity(0.3), size: 18),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: g['id'] ?? ''));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('ID copied'), backgroundColor: AppColors.primary),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 20),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: const Color(0xFF1A1A1A),
                          title: const Text('Group Delete?', style: TextStyle(color: Colors.white)),
                          content: Text('Kya "${g['name']}" delete karna chahte hain?',
                              style: TextStyle(color: Colors.white.withOpacity(0.7))),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                            TextButton(onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Delete', style: TextStyle(color: Color(0xFFEF4444)))),
                          ],
                        ),
                      );
                      if (confirm == true) await service.forceDeleteGroup(g['id']);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _UsersTab extends StatelessWidget {
  final SuperAdminService service;
  const _UsersTab({required this.service});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: service.allUsersStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        final users = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, i) {
            final u           = users[i];
            final isSuspended = u['isSuspended'] == true;
            final name        = u['name'] ?? 'Unknown';
            final email       = u['email'] ?? '';
            final familyCount = (u['familyIds'] as List?)?.length ?? 0;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isSuspended ? const Color(0xFF2A1A1A) : const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSuspended ? Colors.red.withOpacity(0.3) : Colors.white.withOpacity(0.06)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: isSuspended ? Colors.red.withOpacity(0.2) : AppColors.primary.withOpacity(0.15),
                    child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: TextStyle(color: isSuspended ? Colors.red : AppColors.primary, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Text(name, style: TextStyle(
                              color: isSuspended ? Colors.red.withOpacity(0.7) : Colors.white,
                              fontWeight: FontWeight.w600, fontSize: 14)),
                          if (isSuspended) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: Colors.red.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                              child: const Text('Suspended', style: TextStyle(color: Colors.red, fontSize: 9, fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ]),
                        const SizedBox(height: 2),
                        Text('$email · $familyCount groups',
                            style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(isSuspended ? Icons.lock_open_outlined : Icons.block_outlined,
                        color: isSuspended ? Colors.green : Colors.orange, size: 20),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: const Color(0xFF1A1A1A),
                          title: Text(isSuspended ? 'Unsuspend?' : 'Suspend?',
                              style: const TextStyle(color: Colors.white)),
                          content: Text(isSuspended
                              ? '$name ka account wapas active ho jayega.'
                              : '$name ka account suspend ho jayega.',
                              style: TextStyle(color: Colors.white.withOpacity(0.7))),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              style: ElevatedButton.styleFrom(backgroundColor: isSuspended ? Colors.green : Colors.orange),
                              child: Text(isSuspended ? 'Unsuspend' : 'Suspend'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) await service.suspendUser(u['id'] ?? u['uid'], !isSuspended);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
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
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: color)),
            Text(label, style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.4))),
          ]),
        ],
      ),
    );
  }
}