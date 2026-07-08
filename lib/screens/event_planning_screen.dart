import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../providers/auth_provider.dart';
import '../widgets/loading_widget.dart';

class EventPlanningScreen extends ConsumerStatefulWidget {
  final String familyId;
  const EventPlanningScreen({super.key, required this.familyId});

  @override
  ConsumerState<EventPlanningScreen> createState() => _EventPlanningScreenState();
}

class _EventPlanningScreenState extends ConsumerState<EventPlanningScreen> {
  final _titleCtrl  = TextEditingController();
  final _budgetCtrl = TextEditingController();
  String _type      = 'Wedding';
  DateTime _date    = DateTime.now().add(const Duration(days: 30));

  final List<String> _eventTypes = [
    'Wedding', 'Mehndi', 'Birthday', 'Eid', 'Graduation', 'Other'
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _budgetCtrl.dispose();
    super.dispose();
  }

  Future<void> _createEvent() async {
    if (_titleCtrl.text.trim().isEmpty) return;
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('families')
        .doc(widget.familyId)
        .collection('event_plans')
        .add({
      'title':      _titleCtrl.text.trim(),
      'type':       _type,
      'date':       Timestamp.fromDate(_date),
      'budget':     double.tryParse(_budgetCtrl.text) ?? 0,
      'createdBy':  user.uid,
      'creatorName': user.name,
      'createdAt':  Timestamp.now(),
      'todos':      [],
      'guests':     [],
    });

    _titleCtrl.clear();
    _budgetCtrl.clear();
    if (mounted) Navigator.pop(context);
  }

  void _showCreateSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Naya Event Plan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              TextField(controller: _titleCtrl,
                  decoration: const InputDecoration(hintText: 'maslan: Ali ki Shadi')),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: _eventTypes.map((t) {
                  final sel = _type == t;
                  return ChoiceChip(
                    label: Text(t),
                    selected: sel,
                    onSelected: (_) => setSheet(() => _type = t),
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                        color: sel ? Colors.white : AppColors.textPrimary),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                    builder: (ctx, child) => Theme(
                      data: Theme.of(ctx).copyWith(
                          colorScheme: const ColorScheme.light(
                              primary: AppColors.primary)),
                      child: child!,
                    ),
                  );
                  if (picked != null) setSheet(() => _date = picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(children: [
                    const Icon(Icons.calendar_today, color: AppColors.primary, size: 18),
                    const SizedBox(width: 10),
                    Text(Helpers.formatDate(_date)),
                  ]),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _budgetCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: 'Budget (Rs) - optional'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _createEvent, child: const Text('Event Banayein')),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Event Planning 🎉',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('families')
            .doc(widget.familyId)
            .collection('event_plans')
            .orderBy('date')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const LoadingWidget();
          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🎉', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 14),
                  const Text('Koi event plan nahi',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 15)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _showCreateSheet,
                    icon: const Icon(Icons.add),
                    label: const Text('Event Plan Banayein'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final data   = docs[i].data() as Map<String, dynamic>;
              final date   = (data['date'] as Timestamp).toDate();
              final budget = (data['budget'] ?? 0).toDouble();
              final todos  = List.from(data['todos'] ?? []);
              final guests = List.from(data['guests'] ?? []);
              final daysLeft = date.difference(DateTime.now()).inDays;

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [Color(0xFF6C3AE8), Color(0xFF8B5CF6)]),
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16)),
                      ),
                      child: Row(children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(data['title'] ?? '',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 16,
                                      fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text('${data['type']} · ${Helpers.formatDate(date)}',
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 12)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            daysLeft <= 0 ? 'Aaj!' : '$daysLeft din',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ]),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          _InfoChip(Icons.people_outline, '${guests.length} guests'),
                          const SizedBox(width: 8),
                          _InfoChip(Icons.checklist_outlined,
                              '${todos.where((t) => t['done'] == true).length}/${todos.length} tasks'),
                          if (budget > 0) ...[
                            const SizedBox(width: 8),
                            _InfoChip(Icons.attach_money, 'Rs ${budget.toStringAsFixed(0)}'),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: _showCreateSheet,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip(this.icon, this.label);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
        color: AppColors.cardBg, borderRadius: BorderRadius.circular(20)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 12, color: AppColors.primary),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textPrimary)),
    ]),
  );
}