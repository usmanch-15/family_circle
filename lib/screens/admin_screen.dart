import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/constants.dart';
import '../providers/auth_provider.dart';
import '../providers/groups_provider.dart';
import '../widgets/loading_widget.dart';

class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final familyId  = ref.watch(currentGroupIdProvider);
    final user      = ref.watch(currentUserProvider);
    if (familyId == null) return const Scaffold(body: Center(child: Text('Family nahi mili')));

    final familyAsync = ref.watch(singleGroupStreamProvider(familyId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Admin Panel', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: familyAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (family) {
          if (family == null) return const SizedBox();
          final isAdmin = family.adminUid == user?.uid;

          if (!isAdmin) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, size: 48, color: AppColors.textMuted),
                  SizedBox(height: 12),
                  Text('Sirf admin yeh dekh sakta hai', style: TextStyle(color: AppColors.textMuted)),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(0),
            children: [
              // ── Group info ───────────────────────────
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 50, height: 50,
                      decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(14)),
                      child: const Icon(Icons.groups_rounded, color: AppColors.primary, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(family.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                          Text('${family.memberCount} members · Admin: Aap',
                              style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── Invite link ───────────────────────────
              _SectionLabel('Invite Link'),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.tag, size: 16, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(family.inviteCode,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                                    fontFamily: 'monospace', color: AppColors.primary)),
                          ),
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: family.inviteCode));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Code copy ho gaya!'),
                                    behavior: SnackBarBehavior.floating, backgroundColor: AppColors.primary),
                              );
                            },
                            child: const Icon(Icons.copy, size: 18, color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final newCode = await ref.read(familyServiceProvider)
                              .resetInviteCode(familyId: family.id, familyName: family.name);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Naya code: $newCode'),
                                behavior: SnackBarBehavior.floating, backgroundColor: AppColors.primary),
                          );
                        },
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Naya link generate karein'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── AI Mediator toggle ────────────────────
              _SectionLabel('AI Mediator'),
              Container(
                color: Colors.white,
                child: SwitchListTile(
                  secondary: Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: family.aiEnabled ? AppColors.cardBg : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.psychology_rounded,
                        color: family.aiEnabled ? AppColors.primary : AppColors.textMuted, size: 20),
                  ),
                  title: const Text('AI Mediator', style: TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text(
                    family.aiEnabled ? 'Active — family issues mein AI help karega' : 'Off — tap karke on karein',
                    style: TextStyle(fontSize: 12, color: family.aiEnabled ? AppColors.success : AppColors.textMuted),
                  ),
                  value:    family.aiEnabled,
                  activeColor: AppColors.primary,
                  onChanged: (val) async {
                    await ref.read(familyServiceProvider).updateAiEnabled(familyId: family.id, enabled: val);
                  },
                ),
              ),

              const SizedBox(height: 12),

              // ── Members manage ────────────────────────
              _SectionLabel('Members'),
              ...family.memberIds.map((memberId) {
                final isThisAdmin = memberId == family.adminUid;
                return Container(
                  color: Colors.white,
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.cardBg,
                      child: Text(
                        memberId.length > 1 ? memberId.substring(0, 1).toUpperCase() : '?',
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
                    title: Text(isThisAdmin ? 'Admin (Aap)' : 'Member',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    subtitle: Text(memberId.length > 12 ? '${memberId.substring(0, 12)}...' : memberId,
                        style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: AppColors.textMuted)),
                    trailing: isThisAdmin
                        ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(20)),
                      child: const Text('Admin', style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
                    )
                        : IconButton(
                      icon: const Icon(Icons.person_remove_outlined, color: AppColors.error, size: 20),
                      tooltip: 'Remove member',
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Member Remove karein?'),
                            content: const Text('Kya aap is member ko group se remove karna chahte hain?'),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Remove', style: TextStyle(color: AppColors.error)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await ref.read(familyServiceProvider).removeMember(
                            familyId: family.id,
                            memberUid: memberId,
                          );
                        }
                      },
                    ),
                  ),
                );
              }).toList(),

              const SizedBox(height: 30),
            ],
          );
        },
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      child: Text(text.toUpperCase(),
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
              color: AppColors.textMuted, letterSpacing: 0.8)),
    );
  }
}