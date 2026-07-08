import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../services/message_pinning_service.dart';

class PinnedMessagesWidget extends StatelessWidget {
  final String familyId;

  const PinnedMessagesWidget({super.key, required this.familyId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: MessagePinningService().pinnedMessagesStream(familyId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }
        final pinned = snapshot.data!;

        return Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.push_pin, size: 14, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Pinned Message',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary)),
                    Text(
                      pinned.first['text'] ?? '',
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (pinned.length > 1)
                Text('+${pinned.length - 1}',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textMuted)),
            ],
          ),
        );
      },
    );
  }
}