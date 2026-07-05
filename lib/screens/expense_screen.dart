import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../providers/auth_provider.dart';
import '../models/expense_model.dart';
import '../models/family_model.dart';
import '../services/expense_service.dart';
import '../widgets/loading_widget.dart';

class ExpenseScreen extends ConsumerStatefulWidget {
  final FamilyModel family;
  const ExpenseScreen({super.key, required this.family});

  @override
  ConsumerState<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends ConsumerState<ExpenseScreen> {
  final _service    = ExpenseService();
  final _titleCtrl  = TextEditingController();
  final _amountCtrl = TextEditingController();
  String _category  = 'General';

  final List<Map<String, dynamic>> _categories = [
    {'name': 'General',     'icon': Icons.receipt_outlined,          'color': AppColors.primary},
    {'name': 'Bijli/Gas',   'icon': Icons.electric_bolt_outlined,    'color': const Color(0xFFD97706)},
    {'name': 'Khaana',      'icon': Icons.restaurant_outlined,       'color': const Color(0xFF059669)},
    {'name': 'Transport',   'icon': Icons.directions_car_outlined,   'color': const Color(0xFF0891B2)},
    {'name': 'Medical',     'icon': Icons.medical_services_outlined, 'color': const Color(0xFFEF4444)},
    {'name': 'Education',   'icon': Icons.school_outlined,           'color': const Color(0xFF7C3AED)},
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _addExpense() async {
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (_titleCtrl.text.trim().isEmpty || amount == null) return;
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    await _service.addExpense(
      familyId:     widget.family.id,
      title:        _titleCtrl.text.trim(),
      amount:       amount,
      paidByUid:    user.uid,
      paidByName:   user.name,
      splitBetween: widget.family.memberIds,
      category:     _category,
    );

    _titleCtrl.clear();
    _amountCtrl.clear();
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
            const Text('Naya Kharcha',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(
              controller: _titleCtrl,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'maslan: Bijli ka bill',
                prefixIcon: Icon(Icons.receipt_outlined, color: AppColors.textMuted),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Amount (Rs)',
                prefixIcon: Icon(Icons.attach_money, color: AppColors.textMuted),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _categories.map((cat) {
                final sel = _category == cat['name'];
                return ChoiceChip(
                  label: Text(cat['name'] as String),
                  selected: sel,
                  onSelected: (_) => setState(() => _category = cat['name'] as String),
                  selectedColor: (cat['color'] as Color).withOpacity(0.2),
                  labelStyle: TextStyle(
                      color: sel ? cat['color'] as Color : AppColors.textSecondary,
                      fontSize: 12, fontWeight: sel ? FontWeight.w600 : FontWeight.normal),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _addExpense, child: const Text('Add Karein')),
          ],
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
        title: const Text('Kharche',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: StreamBuilder<List<ExpenseModel>>(
        stream: _service.expensesStream(widget.family.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const LoadingWidget();
          final expenses = snapshot.data!;

          if (expenses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: AppColors.cardBg, shape: BoxShape.circle),
                    child: const Icon(Icons.receipt_long_outlined,
                        size: 40, color: AppColors.primary),
                  ),
                  const SizedBox(height: 14),
                  const Text('Koi kharcha record nahi',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 15)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _showAddSheet,
                    icon: const Icon(Icons.add),
                    label: const Text('Kharcha Add Karein'),
                  ),
                ],
              ),
            );
          }

          final total = expenses.fold<double>(0, (s, e) => s + e.amount);

          return Column(
            children: [
              // Total card
              Container(
                color: AppColors.primary,
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Kharcha',
                              style: TextStyle(color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text('Rs ${total.toStringAsFixed(0)}',
                              style: const TextStyle(color: Colors.white,
                                  fontSize: 26, fontWeight: FontWeight.w700)),
                          Text('${widget.family.memberCount} members mein split',
                              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Per person',
                            style: TextStyle(color: Colors.white70, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          'Rs ${widget.family.memberCount > 0 ? (total / widget.family.memberCount).toStringAsFixed(0) : 0}',
                          style: const TextStyle(color: Colors.white,
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: expenses.length,
                  itemBuilder: (context, i) {
                    final e = expenses[i];
                    final catData = _categories.firstWhere(
                            (c) => c['name'] == e.category,
                        orElse: () => _categories[0]);
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
                              color: (catData['color'] as Color).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12)),
                          child: Icon(catData['icon'] as IconData,
                              color: catData['color'] as Color, size: 22),
                        ),
                        title: Text(e.title,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        subtitle: Text(
                          '${e.paidByName} · ${Helpers.formatDate(e.date)}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Rs ${e.amount.toStringAsFixed(0)}',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w700,
                                    color: catData['color'] as Color)),
                            Text('/${e.splitBetween.length} log',
                                style: const TextStyle(
                                    fontSize: 11, color: AppColors.textMuted)),
                          ],
                        ),
                        onLongPress: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete karein?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Cancel')),
                                TextButton(onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text('Delete',
                                        style: TextStyle(color: AppColors.error))),
                              ],
                            ),
                          );
                          if (confirm == true) await _service.deleteExpense(e.id);
                        },
                      ),
                    );
                  },
                ),
              ),
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