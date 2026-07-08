import 'package:flutter/material.dart';
import '../services/presence_service.dart';
import '../utils/helpers.dart';

class OnlineStatusBadge extends StatelessWidget {
  final String uid;
  final Widget child;

  const OnlineStatusBadge({
    super.key,
    required this.uid,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: PresenceService().isOnlineStream(uid),
      builder: (context, snapshot) {
        final isOnline = snapshot.data ?? false;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            child,
            Positioned(
              right: 0, bottom: 0,
              child: Container(
                width: 12, height: 12,
                decoration: BoxDecoration(
                  color: isOnline
                      ? const Color(0xFF22C55E)
                      : const Color(0xFF9CA3AF),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class OnlineStatusText extends StatelessWidget {
  final String uid;

  const OnlineStatusText({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    final service = PresenceService();
    return StreamBuilder<bool>(
      stream: service.isOnlineStream(uid),
      builder: (context, onlineSnap) {
        final isOnline = onlineSnap.data ?? false;
        if (isOnline) {
          return const Text('Active now',
              style: TextStyle(fontSize: 12, color: Color(0xFF22C55E)));
        }
        return StreamBuilder<DateTime?>(
          stream: service.lastSeenStream(uid),
          builder: (context, lastSeenSnap) {
            final lastSeen = lastSeenSnap.data;
            if (lastSeen == null) {
              return const Text('Offline',
                  style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)));
            }
            return Text(
              'Last seen ${Helpers.timeAgo(lastSeen)}',
              style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
            );
          },
        );
      },
    );
  }
}
