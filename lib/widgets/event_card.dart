import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../models/event_model.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback? onDelete;

  const EventCard({super.key, required this.event, this.onDelete});

  IconData get _icon {
    switch (event.type) {
      case EventType.birthday:    return Icons.cake_rounded;
      case EventType.anniversary: return Icons.favorite_rounded;
      default:                    return Icons.event_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isToday = event.daysUntil == 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isToday ? AppColors.cardBg : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isToday ? AppColors.primary : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_icon, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(Helpers.formatDate(event.date),
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ),
          Text(
            isToday ? 'Aaj!' : '${event.daysUntil} din',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isToday ? AppColors.primary : AppColors.textMuted),
          ),
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.close, size: 18, color: AppColors.error),
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }
}
