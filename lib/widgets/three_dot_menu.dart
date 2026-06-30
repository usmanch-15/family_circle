import 'package:flutter/material.dart';
import '../utils/constants.dart';

class ThreeDotMenu extends StatelessWidget {
  final VoidCallback onNewFamily;
  final VoidCallback onSettings;

  const ThreeDotMenu({
    super.key,
    required this.onNewFamily,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        if (value == 'new_family') onNewFamily();
        if (value == 'settings') onSettings();
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'new_family',
          child: Row(
            children: [
              Icon(Icons.group_add_outlined,
                  size: 18, color: AppColors.textPrimary),
              SizedBox(width: 10),
              Text('New family'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'settings',
          child: Row(
            children: [
              Icon(Icons.settings_outlined,
                  size: 18, color: AppColors.textPrimary),
              SizedBox(width: 10),
              Text('Settings'),
            ],
          ),
        ),
      ],
    );
  }
}