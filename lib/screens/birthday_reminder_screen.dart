import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';

class BirthdayReminderScreen extends StatelessWidget {
  final String familyId;
  const BirthdayReminderScreen({super.key, required this.familyId});

  @override
  Widget build(BuildContext context) {
    final service = EventService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Birthdays & Anniversaries 🎂',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: StreamBuilder<List<EventModel>>(
        stream: service.eventsStream(familyId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final all = snapshot.data!;
          final birthdays = all
              .where((e) => e.type == EventType.birthday)
              .toList()
            ..sort((a, b) => a.daysUntil.compareTo(b.daysUntil));
          final anniversaries = all
              .where((e) => e.type == EventType.anniversary)
              .toList()
            ..sort((a, b) => a.daysUntil.compareTo(b.daysUntil));

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Upcoming this week
              if (all.any((e) => e.daysUntil <= 7)) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C3AE8), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('🔔 Is Hafte Aane Wale',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 10),
                      ...all
                          .where((e) => e.daysUntil <= 7)
                          .map((e) => Padding(
                        padding:
                        const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Text(
                                e.type == EventType.birthday
                                    ? '🎂'
                                    : '❤️',
                                style: const TextStyle(
                                    fontSize: 18)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(e.title,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight:
                                      FontWeight.w500)),
                            ),
                            Container(
                              padding:
                              const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white
                                    .withOpacity(0.2),
                                borderRadius:
                                BorderRadius.circular(20),
                              ),
                              child: Text(
                                e.daysUntil == 0
                                    ? 'Aaj!'
                                    : '${e.daysUntil} din',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight:
                                    FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Birthdays
              if (birthdays.isNotEmpty) ...[
                const Text('🎂 Birthdays',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 10),
                ...birthdays.map((e) => _EventCard(event: e)),
                const SizedBox(height: 20),
              ],

              // Anniversaries
              if (anniversaries.isNotEmpty) ...[
                const Text('❤️ Anniversaries',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 10),
                ...anniversaries.map((e) => _EventCard(event: e)),
              ],

              if (birthdays.isEmpty && anniversaries.isEmpty)
                Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      const Text('🎂',
                          style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 14),
                      const Text('Koi birthday ya anniversary nahi hai',
                          style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 15)),
                      const SizedBox(height: 8),
                      const Text(
                          'Calendar mein jaa ke birthday/anniversary events add karein',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 13)),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final EventModel event;
  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final isToday   = event.daysUntil == 0;
    final isSoon    = event.daysUntil <= 3;
    final isBirthday = event.type == EventType.birthday;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isToday
            ? (isBirthday
            ? const Color(0xFFF5F0FF)
            : const Color(0xFFFFF0F3))
            : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isToday
              ? AppColors.primary
              : isSoon
              ? AppColors.primary.withOpacity(0.3)
              : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Text(isBirthday ? '🎂' : '❤️',
              style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 3),
                Text(Helpers.formatDate(event.date),
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isToday
                      ? AppColors.primary
                      : isSoon
                      ? AppColors.primary.withOpacity(0.1)
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isToday
                      ? 'Aaj! 🎉'
                      : '${event.daysUntil} din baqi',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isToday
                          ? Colors.white
                          : isSoon
                          ? AppColors.primary
                          : AppColors.textMuted),
                ),
              ),
              if (isToday) ...[
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => Share.share(
                      '${event.title} ko birthday mubarak! 🎂🎉\nFamily Circle ki taraf se dher saari duayen!'),
                  child: const Text('Mubarak bhejein 🎁',
                      style: TextStyle(
                          fontSize: 11,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}