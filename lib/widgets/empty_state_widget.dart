import 'package:flutter/material.dart';
import '../utils/constants.dart';

class EmptyStateWidget extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final String? buttonText;
  final VoidCallback? onButtonTap;

  const EmptyStateWidget({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    this.buttonText,
    this.onButtonTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90, height: 90,
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(emoji,
                    style: const TextStyle(fontSize: 40)),
              ),
            ),
            const SizedBox(height: 20),
            Text(title,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(subtitle,
                style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5),
                textAlign: TextAlign.center),
            if (buttonText != null && onButtonTap != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onButtonTap,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(160, 46),
                ),
                child: Text(buttonText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Pre-built empty states
class EmptyChat extends StatelessWidget {
  const EmptyChat({super.key});
  @override
  Widget build(BuildContext context) => const EmptyStateWidget(
    emoji: '💬',
    title: 'Koi message nahi',
    subtitle: 'Pehla message bhej ke conversation shuru karein!',
  );
}

class EmptyMedia extends StatelessWidget {
  const EmptyMedia({super.key});
  @override
  Widget build(BuildContext context) => const EmptyStateWidget(
    emoji: '🖼️',
    title: 'Koi media nahi',
    subtitle: 'Photos aur videos share karein family ke sath',
  );
}

class EmptyEvents extends StatelessWidget {
  const EmptyEvents({super.key});
  @override
  Widget build(BuildContext context) => const EmptyStateWidget(
    emoji: '📅',
    title: 'Koi event nahi',
    subtitle: 'Birthday, anniversary aur events add karein',
  );
}

class EmptyTasks extends StatelessWidget {
  const EmptyTasks({super.key});
  @override
  Widget build(BuildContext context) => const EmptyStateWidget(
    emoji: '✅',
    title: 'Sab kaam ho gaya!',
    subtitle: 'Family tasks add karein aur assign karein',
  );
}

class EmptyExpenses extends StatelessWidget {
  const EmptyExpenses({super.key});
  @override
  Widget build(BuildContext context) => const EmptyStateWidget(
    emoji: '💰',
    title: 'Koi kharcha nahi',
    subtitle: 'Family kharche track karein aur split karein',
  );
}