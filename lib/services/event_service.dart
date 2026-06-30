import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';
import '../utils/constants.dart';

class EventService {
  final _firestore = FirebaseFirestore.instance;
  static const String _collection = 'events';

  Future<void> addEvent({
    required String familyId,
    required String title,
    required EventType type,
    required DateTime date,
    required String createdByUid,
    String? notes,
  }) async {
    final docRef = _firestore.collection(_collection).doc();
    final event = EventModel(
      id:           docRef.id,
      familyId:     familyId,
      title:        title,
      type:         type,
      date:         date,
      createdByUid: createdByUid,
      notes:        notes,
      createdAt:    DateTime.now(),
    );
    await docRef.set(event.toMap());
  }

  Stream<List<EventModel>> eventsStream(String familyId) {
    return _firestore
        .collection(_collection)
        .where('familyId', isEqualTo: familyId)
        .orderBy('date')
        .snapshots()
        .map((snap) => snap.docs
        .map((d) => EventModel.fromMap(d.data(), d.id))
        .toList());
  }

  // Aane wale 7 din ke events - reminder ke liye
  Future<List<EventModel>> upcomingEvents(String familyId) async {
    final snap = await _firestore
        .collection(_collection)
        .where('familyId', isEqualTo: familyId)
        .get();

    final events = snap.docs
        .map((d) => EventModel.fromMap(d.data(), d.id))
        .toList();

    return events.where((e) => e.daysUntil <= 7).toList()
      ..sort((a, b) => a.daysUntil.compareTo(b.daysUntil));
  }

  Future<void> deleteEvent(String eventId) async {
    await _firestore.collection(_collection).doc(eventId).delete();
  }
}
