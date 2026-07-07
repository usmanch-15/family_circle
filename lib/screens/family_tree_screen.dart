import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../models/user_model.dart';
import '../widgets/loading_widget.dart';
import 'medical_records_screen.dart';

class FamilyTreeScreen extends StatelessWidget {
  final String familyId;
  const FamilyTreeScreen({super.key, required this.familyId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Family Tree 👨‍👩‍👧‍👦',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('familyIds', arrayContains: familyId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const LoadingWidget();
          final members = snapshot.data!.docs
              .map((d) => UserModel.fromMap(d.data() as Map<String, dynamic>))
              .toList();

          if (members.isEmpty) {
            return const Center(
              child: Text('Koi member nahi mila',
                  style: TextStyle(color: AppColors.textMuted)),
            );
          }

          final admin = members.where((m) => m.isAdmin).toList();
          final others = members.where((m) => !m.isAdmin).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Tree header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF6C3AE8), Color(0xFF8B5CF6)]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Text('👨‍👩‍👧‍👦',
                          style: TextStyle(fontSize: 32)),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Family Tree',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700)),
                          Text('${members.length} members',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Admin (root)
                if (admin.isNotEmpty) ...[
                  const Text('👑 Admin / Head of Family',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                          letterSpacing: 0.6)),
                  const SizedBox(height: 10),
                  ...admin.map((m) => _MemberCard(
                    member: m,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MedicalRecordsScreen(
                            memberUid: m.uid,
                            memberName: m.name),
                      ),
                    ),
                  )),
                  const SizedBox(height: 8),
                  // Connector line
                  if (others.isNotEmpty)
                    Container(
                      width: 2,
                      height: 24,
                      color: AppColors.border,
                    ),
                  const SizedBox(height: 8),
                ],

                // Members
                if (others.isNotEmpty) ...[
                  const Text('👥 Family Members',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                          letterSpacing: 0.6)),
                  const SizedBox(height: 10),
                  ...others.map((m) => _MemberCard(
                    member: m,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MedicalRecordsScreen(
                            memberUid: m.uid,
                            memberName: m.name),
                      ),
                    ),
                  )),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  final UserModel member;
  final VoidCallback onTap;
  const _MemberCard({required this.member, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: member.isAdmin
                  ? AppColors.primary.withOpacity(0.4)
                  : AppColors.border),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.cardBg,
              backgroundImage: member.photoUrl != null
                  ? NetworkImage(member.photoUrl!)
                  : null,
              child: member.photoUrl == null
                  ? Text(Helpers.getInitials(member.name),
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15))
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(member.name,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                      if (member.isAdmin) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                              color: AppColors.cardBg,
                              borderRadius: BorderRadius.circular(20)),
                          child: const Text('Admin',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(member.email,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
            ),
            const Icon(Icons.medical_services_outlined,
                color: AppColors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}