import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense_model.dart';

class ExpenseService {
  final _firestore = FirebaseFirestore.instance;
  static const String _collection = 'expenses';

  Future<void> addExpense({
    required String familyId,
    required String title,
    required double amount,
    required String paidByUid,
    required String paidByName,
    required List<String> splitBetween,
    String category = 'General',
  }) async {
    final docRef = _firestore.collection(_collection).doc();
    final expense = ExpenseModel(
      id:           docRef.id,
      familyId:     familyId,
      title:        title,
      amount:       amount,
      paidByUid:    paidByUid,
      paidByName:   paidByName,
      splitBetween: splitBetween,
      category:     category,
      date:         DateTime.now(),
    );
    await docRef.set(expense.toMap());
  }

  Stream<List<ExpenseModel>> expensesStream(String familyId) {
    return _firestore
        .collection(_collection)
        .where('familyId', isEqualTo: familyId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((d) => ExpenseModel.fromMap(d.data(), d.id))
        .toList());
  }

  // Har member ka total kitna dena/lena hai (simple balance calculation)
  Map<String, double> calculateBalances(List<ExpenseModel> expenses) {
    final balances = <String, double>{};

    for (final expense in expenses) {
      // Paying member ko credit
      balances[expense.paidByUid] =
          (balances[expense.paidByUid] ?? 0) + expense.amount;

      // Har sharing member ka share minus karo
      for (final uid in expense.splitBetween) {
        balances[uid] = (balances[uid] ?? 0) - expense.perPersonShare;
      }
    }
    return balances;
  }

  Future<void> deleteExpense(String expenseId) async {
    await _firestore.collection(_collection).doc(expenseId).delete();
  }
}
