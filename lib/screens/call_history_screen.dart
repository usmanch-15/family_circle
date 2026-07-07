import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../widgets/loading_widget.dart';

class CallHistoryScreen extends StatelessWidget {
  final String familyId;
  const CallHistoryScreen({super.key, required this.familyId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Call History 📞',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('call_logs')
            .where('familyId', isEqualTo: familyId)
            .orderBy('callTime', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const LoadingWidget();
          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                        color: AppColors.cardBg,
                        shape: BoxShape.circle),
                    child: const Icon(Icons.call_outlined,
                        size: 44, color: AppColors.primary),
                  ),
                  const SizedBox(height: 14),
                  const Text('Koi call history nahi hai',
                      style: TextStyle(
                          color: AppColors.textMuted, fontSize: 15)),
                  const SizedBox(height: 8),
                  const Text(
                      'Voice/video calling feature Android app mein aayega',
                      style: TextStyle(
                          color: AppColors.textMuted, fontSize: 13),
                      textAlign: TextAlign.center),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) =>
            const Divider(height: 1, color: AppColors.border),
            itemBuilder: (context, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              final isVideo    = data['type'] == 'video';
              final callTime   = (data['callTime'] as Timestamp).toDate();
              final isMissed   = data['status'] == 'missed';
              final duration   = data['durationMinutes'] ?? 0;

              return Container(
                color: Colors.white,
                child: ListTile(
                  leading: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: isMissed
                          ? const Color(0xFFFEE2E2)
                          : AppColors.cardBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isVideo
                          ? Icons.videocam_outlined
                          : Icons.call_outlined,
                      color: isMissed
                          ? AppColors.error
                          : AppColors.primary,
                      size: 22,
                    ),
                  ),
                  title: Text(
                    data['callerName'] ?? 'Unknown',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isMissed
                            ? AppColors.error
                            : AppColors.textPrimary),
                  ),
                  subtitle: Text(
                    isMissed
                        ? 'Missed call'
                        : '${duration} min · ${isVideo ? "Video" : "Voice"}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textMuted),
                  ),
                  trailing: Text(
                    Helpers.timeAgo(callTime),
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textMuted),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}