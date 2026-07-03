import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../providers/auth_provider.dart';
import '../providers/groups_provider.dart';
import '../models/user_model.dart';
import '../widgets/loading_widget.dart';

class MembersScreen extends ConsumerWidget {
  const MembersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final familyId  = ref.watch(currentGroupIdProvider);
    final user      = ref.watch(currentUserProvider);
    if (familyId == null) return const Scaffold(body: Center(child: Text('Family nahi mili')));

    final familyAsync = ref.watch(singleGroupStreamProvider(familyId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: familyAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (family) {
          if (family == null) return const Center(child: Text('Family nahi mili'));
          return CustomScrollView(
            slivers: [
              // ── Purple header ──────────────────────────
              SliverAppBar(
                pinned: true,
                expandedHeight: 160,
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
                          CircleAvatar(
                            radius: 34,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            child: Text(Helpers.getInitials(family.name),
                                style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.w700)),
                          ),
                          const SizedBox(height: 10),
                          Text(family.name,
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.people_outline, size: 14, color: Colors.white.withOpacity(0.8)),
                              const SizedBox(width: 4),
                              Text('${family.memberCount} members',
                                  style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.8))),
                              if (family.aiEnabled) ...[
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.psychology_rounded, size: 12, color: Colors.yellow.shade300),
                                      const SizedBox(width: 3),
                                      Text('AI Active', style: TextStyle(fontSize: 11, color: Colors.yellow.shade300)),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Invite link ────────────────────────────
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Text('INVITE LINK',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                              color: AppColors.textMuted, letterSpacing: 0.8)),
                    ),
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 38, height: 38,
                            decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.link, color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Family invite code', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                                Text(family.inviteCode,
                                    style: const TextStyle(fontSize: 13, color: AppColors.primary,
                                        fontFamily: 'monospace', fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy, color: AppColors.primary, size: 20),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Code copy ho gaya!'),
                                    behavior: SnackBarBehavior.floating, backgroundColor: AppColors.primary),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Text('MEMBERS (${family.memberCount})',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                              color: AppColors.textMuted, letterSpacing: 0.8)),
                    ),
                  ],
                ),
              ),

              // ── Members list ───────────────────────────
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('familyIds', arrayContains: family.id)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SliverToBoxAdapter(child: LoadingWidget());
                  final members = snapshot.data!.docs
                      .map((d) => UserModel.fromMap(d.data() as Map<String, dynamic>))
                      .toList();

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, i) {
                        final m = members[i];
                        final isAdmin = family.adminUid == m.uid;
                        final isMe    = m.uid == user?.uid;
                        return Container(
                          color: Colors.white,
                          child: Column(
                            children: [
                              ListTile(
                                leading: CircleAvatar(
                                  radius: 22,
                                  backgroundColor: AppColors.cardBg,
                                  backgroundImage: m.photoUrl != null ? NetworkImage(m.photoUrl!) : null,
                                  child: m.photoUrl == null
                                      ? Text(Helpers.getInitials(m.name),
                                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700))
                                      : null,
                                ),
                                title: Row(
                                  children: [
                                    Text(m.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                    if (isMe) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                        decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(10)),
                                        child: const Text('Aap', style: TextStyle(fontSize: 10, color: AppColors.primary)),
                                      ),
                                    ],
                                  ],
                                ),
                                subtitle: Text(m.email, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                trailing: isAdmin
                                    ? Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(20)),
                                  child: const Text('Admin',
                                      style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
                                )
                                    : null,
                              ),
                              if (i < members.length - 1)
                                const Divider(height: 1, indent: 70, color: Color(0xFFEEEEEE)),
                            ],
                          ),
                        );
                      },
                      childCount: members.length,
                    ),
                  );
                },
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 30)),
            ],
          );
        },
      ),
    );
  }
}