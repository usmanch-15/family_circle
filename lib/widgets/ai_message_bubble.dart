import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../models/message_model.dart';

class AiMessageBubble extends StatelessWidget {
  final MessageModel message;

  const AiMessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isAi     = message.sender == MessageSender.ai;
    final isPartyA = message.sender == MessageSender.partyA;

    final bgColor = isAi
        ? const Color(0xFFF0FDF4)
        : isPartyA ? AppColors.primary : AppColors.surface;

    final textColor = isAi
        ? const Color(0xFF166534)
        : isPartyA ? Colors.white : AppColors.textPrimary;

    final label = isAi ? 'AI Mediator'
        : isPartyA ? 'Party A' : 'Party B';

    return Align(
      alignment: isPartyA ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: isAi ? Border.all(color: const Color(0xFF86EFAC)) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(fontSize: 10,
                    color: textColor.withOpacity(0.7),
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 3),
            Text(message.text,
                style: TextStyle(fontSize: 13, color: textColor)),
          ],
        ),
      ),
    );
  }
}