import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../models/event_model.dart';

class BirthdayCard extends StatelessWidget {
  final EventModel event;
  const BirthdayCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final isToday = event.daysUntil == 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryLight]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.cake_rounded, color: Colors.white, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title,
                    style: const TextStyle(color: Colors.white,
                        fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                Text(
                  isToday ? 'Aaj hai! Mubarak ho 🎉'
                      : '${event.daysUntil} din baqi hain',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.85), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}