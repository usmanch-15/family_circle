import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class ChatBubble extends StatelessWidget {
  final String senderName;
  final String message;
  final DateTime time;
  final bool isMe;
  final String? mediaUrl;

  const ChatBubble({
    super.key,
    required this.senderName,
    required this.message,
    required this.time,
    this.isMe = false,
    this.mediaUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isMe ? 14 : 3),
            bottomRight: Radius.circular(isMe ? 3 : 14),
          ),
          border: isMe ? null : Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Text(senderName,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary)),
            if (!isMe) const SizedBox(height: 2),
            Text(message,
                style: TextStyle(
                    fontSize: 14,
                    color: isMe ? Colors.white : AppColors.textPrimary)),
            const SizedBox(height: 3),
            Text(Helpers.formatTime(time),
                style: TextStyle(
                    fontSize: 10,
                    color: isMe
                        ? Colors.white.withOpacity(0.7)
                        : AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}
