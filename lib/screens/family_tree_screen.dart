import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../widgets/loading_widget.dart';

class FamilyTreeScreen extends StatelessWidget {
  final String familyId;

  const FamilyTreeScreen({super.key, required this.familyId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Family Tree',
            style: TextStyle(color: AppColors.textPrimary)),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('familyIds', arrayContains: familyId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const LoadingWidget();
          final members = snapshot.data!.docs;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Wrap(
                spacing: 24,
                runSpacing: 24,
                alignment: WrapAlignment.center,
                children: members.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = data['name'] ?? '';
                  return Column(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: AppColors.cardBg,
                        backgroundImage: data['photoUrl'] != null
                            ? NetworkImage(data['photoUrl'])
                            : null,
                        child: data['photoUrl'] == null
                            ? Text(Helpers.getInitials(name),
                            style: const TextStyle(
                                fontSize: 18, color: AppColors.primary))
                            : null,
                      ),
                      const SizedBox(height: 8),
                      Text(name,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                      Text(data['role'] == 'admin' ? 'Admin' : 'Member',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textMuted)),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}
