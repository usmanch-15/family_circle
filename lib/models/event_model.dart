import 'package:cloud_firestore/cloud_firestore.dart';

enum EventType { birthday, anniversary, general }

class EventModel {
  final String id;
  final String familyId;
  final String title;
  final EventType type;
  final DateTime date;
  final String createdByUid;
  final String? notes;
  final DateTime createdAt;

  EventModel({
    required this.id,
    required this.familyId,
    required this.title,
    required this.type,
    required this.date,
    required this.createdByUid,
    this.notes,
    required this.createdAt,
  });

  int get daysUntil {
    final now = DateTime.now();
    var next = DateTime(now.year, date.month, date.day);
    if (next.isBefore(DateTime(now.year, now.month, now.day))) {
      next = DateTime(now.year + 1, date.month, date.day);
    }
    return next.difference(DateTime(now.year, now.month, now.day)).inDays;
  }

  factory EventModel.fromMap(Map<String, dynamic> map, String docId) {
    return EventModel(
      id:           docId,
      familyId:     map['familyId'] ?? '',
      title:        map['title'] ?? '',
      type:         _typeFromString(map['type']),
      date:         (map['date'] as Timestamp).toDate(),
      createdByUid: map['createdByUid'] ?? '',
      notes:        map['notes'],
      createdAt:    (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'familyId':     familyId,
      'title':        title,
      'type':         type.name,
      'date':         Timestamp.fromDate(date),
      'createdByUid': createdByUid,
      'notes':        notes,
      'createdAt':    Timestamp.fromDate(createdAt),
    };
  }

  static EventType _typeFromString(String? value) {
    switch (value) {
      case 'birthday':    return EventType.birthday;
      case 'anniversary': return EventType.anniversary;
      default:            return EventType.general;
    }
  }
}
