import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cloudinary_service.dart';
import '../models/media_model.dart';
import '../utils/constants.dart';

class MediaService {
  final _cloudinary = CloudinaryService();
  final _firestore = FirebaseFirestore.instance;

  Future<MediaModel> uploadMedia({
    required File file,
    required String familyId,
    required String uploaderUid,
    required String uploaderName,
    required MediaType type,
    String? caption,
  }) async {
    final resourceType = switch (type) {
      MediaType.photo => 'image',
      MediaType.video => 'video',
      MediaType.audio => 'video',
      MediaType.file  => 'raw',
    };

    final url = await _cloudinary.uploadFile(
      file: file,
      folder: 'families/$familyId/media',
      resourceType: resourceType,
    );
    final sizeInBytes = await file.length();

    final docRef = _firestore.collection(Collections.media).doc();

    final media = MediaModel(
      id:           docRef.id,
      familyId:     familyId,
      uploaderUid:  uploaderUid,
      uploaderName: uploaderName,
      url:          url,
      type:         type,
      caption:      caption,
      sizeInBytes:  sizeInBytes,
      uploadedAt:   DateTime.now(),
    );

    await docRef.set(media.toMap());
    return media;
  }

  Stream<List<MediaModel>> mediaStream(String familyId) {
    return _firestore
        .collection(Collections.media)
        .where('familyId', isEqualTo: familyId)
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => MediaModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  Stream<List<MediaModel>> mediaByType(String familyId, MediaType type) {
    return _firestore
        .collection(Collections.media)
        .where('familyId', isEqualTo: familyId)
        .where('type', isEqualTo: type.name)
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => MediaModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  Future<void> deleteMedia(MediaModel media) async {
    // Cloudinary se unsigned delete possible nahi — sirf Firestore record hataya jata hai
    await _firestore.collection(Collections.media).doc(media.id).delete();
  }
}