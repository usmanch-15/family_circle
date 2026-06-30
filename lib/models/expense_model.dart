import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseModel {
  final String id;
  final String familyId;
  final String title;
  final double amount;
  final String paidByUid;
  final String paidByName;
  final List<String> splitBetween;
  final String category;
  final DateTime date;

  ExpenseModel({
    required this.id,
    required this.familyId,
    required this.title,
    required this.amount,
    required this.paidByUid,
    required this.paidByName,
    required this.splitBetween,
    this.category = 'General',
    required this.date,
  });

  double get perPersonShare =>
      splitBetween.isEmpty ? amount : amount / splitBetween.length;

  factory ExpenseModel.fromMap(Map<String, dynamic> map, String docId) {
    return ExpenseModel(
      id:           docId,
      familyId:     map['familyId'] ?? '',
      title:        map['title'] ?? '',
      amount:       (map['amount'] ?? 0).toDouble(),
      paidByUid:    map['paidByUid'] ?? '',
      paidByName:   map['paidByName'] ?? '',
      splitBetween: List<String>.from(map['splitBetween'] ?? []),
      category:     map['category'] ?? 'General',
      date:         (map['date'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'familyId':     familyId,
      'title':        title,
      'amount':       amount,
      'paidByUid':    paidByUid,
      'paidByName':   paidByName,
      'splitBetween': splitBetween,
      'category':     category,
      'date':         Timestamp.fromDate(date),
    };
  }
}