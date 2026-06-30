import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';
import '../providers/auth_provider.dart';
import '../providers/groups_provider.dart';
import '../models/user_model.dart';
import '../widgets/member_card.dart';
import '../widgets/loading_widget.dart';

class MembersScreen extends ConsumerWidget {
  const MembersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final familyId = ref.watch(currentGroupIdProvider);

    if (familyId == null) {
      return const Scaffold(body: Center(child: Text('Family nahi mili')));
    }

    final familyAsync = ref.watch(singleGroupStreamProvider(familyId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text('Family Circle',
            style: TextStyle(color: Colors.white)),
      ),
      body: familyAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (family) {
          if (family == null) {
            return const Center(child: Text('Family nahi mili'));
          }
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('familyIds', arrayContains: family.id)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const LoadingWidget();
              final members = snapshot.data!.docs
                  .map((d) => UserModel.fromMap(
                  d.data() as Map<String, dynamic>))
                  .toList();

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(family.name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('${family.memberCount} Members',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.8))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Family Members',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted)),
                  const SizedBox(height: 10),
                  ...members.map((m) => MemberCard(member: m)),
                ],
              );
            },
          );
        },
      ),
    );
  }
}