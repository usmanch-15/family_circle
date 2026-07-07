import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DocumentStorageService {
  final _firestore = FirebaseFirestore.instance;
  final _storage   = FirebaseStorage.instance;
  static const String _collection = 'documents';

  // Document upload karna - sirf admin access
  Future<void> uploadDocument({
    required String familyId,
    required String uploaderUid,
    required String title,
    required File file,
  }) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
    final storageRef = _storage
        .ref()
        .child('families/$familyId/documents/$fileName');

    final uploadTask = await storageRef.putFile(file);
    final url = await uploadTask.ref.getDownloadURL();

    await _firestore.collection(_collection).add({
      'familyId': familyId,
      'uploaderUid': uploaderUid,
      'title': title,
      'url': url,
      'uploadedAt': Timestamp.now(),
    });
  }

  Stream<List<Map<String, dynamic>>> documentsStream(String familyId) {
    return _firestore
        .collection(_collection)
        .where('familyId', isEqualTo: familyId)
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((d) => {...d.data(), 'id': d.id})
        .toList());
  }
// Seedha URL se document add karna (web ke liye)
  Future<void> addDocumentByUrl({
    required String familyId,
    required String uploaderUid,
    required String title,
    required String url,
  }) async {
    await _firestore.collection(_collection).add({
      'familyId':    familyId,
      'uploaderUid': uploaderUid,
      'title':       title,
      'url':         url,
      'uploadedAt':  Timestamp.now(),
    });
  }
  Future<void> deleteDocument(String docId, String fileUrl) async {
    try {
      await _storage.refFromURL(fileUrl).delete();
    } catch (_) {}
    await _firestore.collection(_collection).doc(docId).delete();
  }
}
