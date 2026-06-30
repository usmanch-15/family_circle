import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/constants.dart';
import '../providers/auth_provider.dart';
import '../models/expense_model.dart';
import '../models/family_model.dart';
import '../services/expense_service.dart';
import '../widgets/expense_tile.dart';
import '../widgets/loading_widget.dart';

class ExpenseScreen extends ConsumerStatefulWidget {
  final FamilyModel family;

  const ExpenseScreen({super.key, required this.family});

  @override
  ConsumerState<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends ConsumerState<ExpenseScreen> {
  final _service = ExpenseService();
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();

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
      familyId: widget.family.id,
      title: _titleCtrl.text.trim(),
      amount: amount,
      paidByUid: user.uid,
      paidByName: user.name,
      splitBetween: widget.family.memberIds,
    );

    _titleCtrl.clear();
    _amountCtrl.clear();
    if (mounted) Navigator.pop(context);
  }

  void _showAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            TextField(
              controller: _titleCtrl,
              decoration:
              const InputDecoration(hintText: 'maslan: Bijli ka bill'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'Amount (Rs)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addExpense,
              child: const Text('Add Karein'),
            ),
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
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Kharche',
            style: TextStyle(color: AppColors.textPrimary)),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: StreamBuilder<List<ExpenseModel>>(
        stream: _service.expensesStream(widget.family.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const LoadingWidget();
          final expenses = snapshot.data!;

          if (expenses.isEmpty) {
            return const Center(
              child: Text('Koi kharcha record nahi hai',
                  style: TextStyle(color: AppColors.textMuted)),
            );
          }

          final balances = _service.calculateBalances(expenses);

          return Column(
            children: [
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Kharcha',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Text(
                      'Rs ${expenses.fold<double>(0, (sum, e) => sum + e.amount).toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: expenses.length,
                  itemBuilder: (context, i) {
                    final expense = expenses[i];
                    return ExpenseTile(
                      expense: expense,
                      onDelete: () => _service.deleteExpense(expense.id),
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