import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../providers/auth_provider.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';
import '../widgets/loading_widget.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  final String familyId;
  const CalendarScreen({super.key, required this.familyId});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  final _service  = EventService();
  final _titleCtrl = TextEditingController();
  EventType _selectedType = EventType.general;
  DateTime  _selectedDate = DateTime.now();

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _addEvent() async {
    if (_titleCtrl.text.trim().isEmpty) return;
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    await _service.addEvent(
      familyId:     widget.familyId,
      title:        _titleCtrl.text.trim(),
      type:         _selectedType,
      date:         _selectedDate,
      createdByUid: user.uid,
    );
    _titleCtrl.clear();
    if (mounted) Navigator.pop(context);
  }

  void _showAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Naya Event',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(
              controller: _titleCtrl,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'maslan: Ali ki Birthday',
                prefixIcon: Icon(Icons.event_outlined, color: AppColors.textMuted),
              ),
            ),
            const SizedBox(height: 12),
            // Type chips
            Wrap(
              spacing: 8,
              children: EventType.values.map((type) {
                final selected = _selectedType == type;
                final label = type == EventType.birthday ? '🎂 Birthday'
                    : type == EventType.anniversary ? '❤️ Anniversary' : '📅 General';
                return ChoiceChip(
                  label: Text(label),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedType = type),
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                      color: selected ? Colors.white : AppColors.textPrimary,
                      fontSize: 13),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            // Date picker
            InkWell(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: AppColors.primary, size: 18),
                    const SizedBox(width: 10),
                    Text(Helpers.formatDate(_selectedDate),
                        style: const TextStyle(fontSize: 14)),
                    const Spacer(),
                    const Icon(Icons.chevron_right, color: AppColors.textMuted),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addEvent,
              child: const Text('Event Add Karein'),
            ),
          ],
        ),
      ),
    );
  }

  IconData _eventIcon(EventType type) {
    switch (type) {
      case EventType.birthday:    return Icons.cake_rounded;
      case EventType.anniversary: return Icons.favorite_rounded;
      default:                    return Icons.event_rounded;
    }
  }

  Color _eventColor(EventType type) {
    switch (type) {
      case EventType.birthday:    return const Color(0xFF7C3AED);
      case EventType.anniversary: return const Color(0xFFEF4444);
      default:                    return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Family Calendar',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: StreamBuilder<List<EventModel>>(
        stream: _service.eventsStream(widget.familyId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const LoadingWidget();
          final events = snapshot.data!;

          if (events.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: AppColors.cardBg, shape: BoxShape.circle),
                    child: const Icon(Icons.calendar_today_outlined,
                        size: 40, color: AppColors.primary),
                  ),
                  const SizedBox(height: 14),
                  const Text('Koi event nahi hai',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 15)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _showAddSheet,
                    icon: const Icon(Icons.add),
                    label: const Text('Event Add Karein'),
                  ),
                ],
              ),
            );
          }

          // Upcoming events
          final upcoming = events.where((e) => e.daysUntil <= 7).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Upcoming banner
              if (upcoming.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C3AE8), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Jaldi Aane Wale',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700,
                              fontSize: 15)),
                      const SizedBox(height: 8),
                      ...upcoming.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Icon(_eventIcon(e.type), color: Colors.white70, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(e.title,
                                  style: const TextStyle(color: Colors.white, fontSize: 13)),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20)),
                              child: Text(
                                e.daysUntil == 0 ? 'Aaj!' : '${e.daysUntil} din',
                                style: const TextStyle(color: Colors.white,
                                    fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              const Text('TAMAM EVENTS',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                      color: AppColors.textMuted, letterSpacing: 0.8)),
              const SizedBox(height: 10),

              ...events.map((event) {
                final color = _eventColor(event.type);
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12)),
                      child: Icon(_eventIcon(event.type), color: color),
                    ),
                    title: Text(event.title,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text(Helpers.formatDate(event.date),
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          event.daysUntil == 0 ? 'Aaj!' : '${event.daysUntil} din',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w700,
                              color: event.daysUntil <= 3 ? AppColors.error : color),
                        ),
                      ],
                    ),
                    onLongPress: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Event delete?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancel')),
                            TextButton(onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Delete',
                                    style: TextStyle(color: AppColors.error))),
                          ],
                        ),
                      );
                      if (confirm == true) await _service.deleteEvent(event.id);
                    },
                  ),
                );
              }),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: _showAddSheet,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}