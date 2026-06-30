import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

class TaskService {
  final _firestore = FirebaseFirestore.instance;
  static const String _collection = 'tasks';

  Future<void> addTask({
    required String familyId,
    required String title,
    required String assignedToUid,
    required String assignedToName,
    DateTime? dueDate,
  }) async {
    final docRef = _firestore.collection(_collection).doc();
    final task = TaskModel(
      id:             docRef.id,
      familyId:       familyId,
      title:          title,
      assignedToUid:  assignedToUid,
      assignedToName: assignedToName,
      dueDate:        dueDate,
      createdAt:      DateTime.now(),
    );
    await docRef.set(task.toMap());
  }

  Stream<List<TaskModel>> tasksStream(String familyId) {
    return _firestore
        .collection(_collection)
        .where('familyId', isEqualTo: familyId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((d) => TaskModel.fromMap(d.data(), d.id))
        .toList());
  }

  Future<void> toggleComplete(String taskId, bool currentValue) async {
    await _firestore.collection(_collection).doc(taskId).update({
      'isCompleted': !currentValue,
    });
  }

  Future<void> deleteTask(String taskId) async {
    await _firestore.collection(_collection).doc(taskId).delete();
  }
}