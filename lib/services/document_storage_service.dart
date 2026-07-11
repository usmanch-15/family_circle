import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cloudinary_service.dart';

class DocumentStorageService {
  final _firestore = FirebaseFirestore.instance;
  final _cloudinary = CloudinaryService();
  static const String _collection = 'documents';

  // Document upload karna - sirf admin access
  Future<void> uploadDocument({
    required String familyId,
    required String uploaderUid,
    required String title,
    required File file,
  }) async {
    final url = await _cloudinary.uploadFile(
      file: file,
      folder: 'families/$familyId/documents',
      resourceType: 'raw',
    );

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
    // Cloudinary se unsigned delete possible nahi — sirf Firestore record hataya jata hai
    await _firestore.collection(_collection).doc(docId).delete();
  }
}