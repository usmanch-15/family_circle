import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../models/family_model.dart';

class GroupListTile extends StatelessWidget {
  final FamilyModel family;
  final String? lastMessage;
  final String? lastMessageTime;
  final VoidCallback onTap;

  const GroupListTile({
    super.key,
    required this.family,
    this.lastMessage,
    this.lastMessageTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.cardBg,
              backgroundImage: family.photoUrl != null
                  ? NetworkImage(family.photoUrl!)
                  : null,
              child: family.photoUrl == null
                  ? Text(
                Helpers.getInitials(family.name),
                style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600),
              )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(family.name,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary),
                            overflow: TextOverflow.ellipsis),
                      ),
                      if (family.aiEnabled)
                        const Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: Icon(Icons.psychology_rounded,
                              size: 14, color: AppColors.primary),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    lastMessage ?? '${family.memberCount} members',
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (lastMessageTime != null)
              Text(lastMessageTime!,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}