import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../services/mediation_service.dart';

class MediationHistoryScreen extends StatelessWidget {
  final String familyId;
  const MediationHistoryScreen({super.key, required this.familyId});

  @override
  Widget build(BuildContext context) {
    final service = MediationService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Purane AI Faisle',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: service.sessionsStream(familyId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          final sessions = snapshot.data!;
          if (sessions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('⚖️', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 14),
                  const Text('Abhi tak koi mediation session nahi hua',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: sessions.length,
            itemBuilder: (context, i) {
              final s = sessions[i];
              final createdAt = (s['createdAt'] as dynamic)?.toDate();
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: ExpansionTile(
                  shape: const RoundedRectangleBorder(side: BorderSide.none),
                  title: Text(s['topic'] ?? '',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700)),
                  subtitle: Text(
                    '${s['partyAName']} vs ${s['partyBName']}'
                        '${createdAt != null ? ' · ${Helpers.timeAgo(createdAt)}' : ''}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF86EFAC)),
                        ),
                        child: Text(s['decision'] ?? '',
                            style: const TextStyle(
                                fontSize: 13, height: 1.5,
                                color: Color(0xFF166534))),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}