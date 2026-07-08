import 'package:flutter/material.dart';
import '../utils/constants.dart';

class CustomBottomSheet {
  // Simple options sheet
  static Future<T?> showOptions<T>({
    required BuildContext context,
    required String title,
    required List<BottomSheetOption<T>> options,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
            ),
            const SizedBox(height: 8),
            ...options.map((opt) => ListTile(
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 20),
              leading: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                    color: opt.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(opt.icon, color: opt.color, size: 20),
              ),
              title: Text(opt.label,
                  style: TextStyle(
                      fontSize: 15,
                      color: opt.isDestructive
                          ? AppColors.error
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w500)),
              onTap: () => Navigator.pop(context, opt.value),
            )),
          ],
        ),
      ),
    );
  }

  // Message actions sheet
  static Future<String?> showMessageActions(BuildContext context,
      {required bool isMe, required bool isLiked}) {
    return showOptions<String>(
      context: context,
      title: 'Message Options',
      options: [
        BottomSheetOption(
            value: 'like',
            label: isLiked ? 'Unlike' : 'Like ❤️',
            icon: Icons.favorite_outline,
            color: Colors.red),
        BottomSheetOption(
            value: 'copy',
            label: 'Copy',
            icon: Icons.copy_outlined,
            color: AppColors.primary),
        BottomSheetOption(
            value: 'pin',
            label: 'Pin Message 📌',
            icon: Icons.push_pin_outlined,
            color: const Color(0xFFD97706)),
        if (isMe)
          BottomSheetOption(
              value: 'delete',
              label: 'Delete',
              icon: Icons.delete_outline,
              color: AppColors.error,
              isDestructive: true),
      ],
    );
  }
}

class BottomSheetOption<T> {
  final T value;
  final String label;
  final IconData icon;
  final Color color;
  final bool isDestructive;

  const BottomSheetOption({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    this.isDestructive = false,
  });
}