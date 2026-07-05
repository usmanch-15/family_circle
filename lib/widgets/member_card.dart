import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../models/user_model.dart';

class MemberCard extends StatelessWidget {
  final UserModel member;
  final bool isOnline;
  final bool showAdminControls;
  final VoidCallback? onRemove;

  const MemberCard({
    super.key,
    required this.member,
    this.isOnline = false,
    this.showAdminControls = false,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.cardBg,
                backgroundImage: member.photoUrl != null
                    ? NetworkImage(member.photoUrl!) : null,
                child: member.photoUrl == null
                    ? Text(Helpers.getInitials(member.name),
                    style: const TextStyle(
                        color: AppColors.primary, fontWeight: FontWeight.w600))
                    : null,
              ),
              if (isOnline)
                Positioned(
                  right: 0, bottom: 0,
                  child: Container(
                    width: 10, height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.success, shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(member.name,
                        style: const TextStyle(fontSize: 14,
                            fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    if (member.isAdmin) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                            color: AppColors.cardBg,
                            borderRadius: BorderRadius.circular(20)),
                        child: const Text('Admin',
                            style: TextStyle(fontSize: 10,
                                color: AppColors.primary, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(member.email,
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ),
          if (showAdminControls && !member.isAdmin)
            IconButton(
              icon: const Icon(Icons.person_remove_outlined,
                  color: AppColors.error, size: 20),
              onPressed: onRemove,
            ),
        ],
      ),
    );
  }
}