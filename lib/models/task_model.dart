import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String familyId;
  final String title;
  final String assignedToUid;
  final String assignedToName;
  final bool isCompleted;
  final DateTime? dueDate;
  final DateTime createdAt;

  TaskModel({
    required this.id,
    required this.familyId,
    required this.title,
    required this.assignedToUid,
    required this.assignedToName,
    this.isCompleted = false,
    this.dueDate,
    required this.createdAt,
  });

  factory TaskModel.fromMap(Map<String, dynamic> map, String docId) {
    return TaskModel(
      id:             docId,
      familyId:       map['familyId'] ?? '',
      title:          map['title'] ?? '',
      assignedToUid:  map['assignedToUid'] ?? '',
      assignedToName: map['assignedToName'] ?? '',
      isCompleted:    map['isCompleted'] ?? false,
      dueDate:        map['dueDate'] != null
          ? (map['dueDate'] as Timestamp).toDate()
          : null,
      createdAt:      (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'familyId':       familyId,
      'title':          title,
      'assignedToUid':  assignedToUid,
      'assignedToName': assignedToName,
      'isCompleted':    isCompleted,
      'dueDate':        dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'createdAt':      Timestamp.fromDate(createdAt),
    };
  }
}