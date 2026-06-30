import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';

import '../providers/family_provider.dart';

class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final familyId = user?.familyId;

    if (familyId == null) {
      return const Scaffold(body: Center(child: Text('Family nahi mili')));
    }

    final familyAsync = ref.watch(familyStreamProvider(familyId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Admin Controls',
            style: TextStyle(color: AppColors.textPrimary)),
      ),
      body: familyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (family) {
          if (family == null) return const SizedBox();
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  border: Border.all(color: const Color(0xFF86EFAC)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Invite Link',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF166534))),
                    const SizedBox(height: 8),
                    Text(family.inviteCode,
                        style: const TextStyle(fontFamily: 'monospace')),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        final newCode = await ref
                            .read(familyServiceProvider)
                            .resetInviteCode(
                            familyId: family.id,
                            familyName: family.name);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Naya code: $newCode')),
                        );
                      },
                      child: const Text('Naya Link Banayein'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('Members manage karein',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted)),
              const SizedBox(height: 10),
              ...family.memberIds
                  .where((id) => id != family.adminUid)
                  .map((memberId) => Card(
                child: ListTile(
                  title: Text(memberId),
                  trailing: IconButton(
                    icon: const Icon(Icons.close,
                        color: AppColors.error),
                    onPressed: () async {
                      await ref
                          .read(familyServiceProvider)
                          .removeMember(
                          familyId: family.id,
                          memberUid: memberId);
                    },
                  ),
                ),
              )),
            ],
          );
        },
      ),
    );
  }
}