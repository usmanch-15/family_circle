import 'package:cloud_firestore/cloud_firestore.dart';

enum MediaType { photo, video, audio, file }

class MediaModel {
  final String id;
  final String familyId;
  final String uploaderUid;
  final String uploaderName;
  final String url;
  final MediaType type;
  final String? caption;
  final int sizeInBytes;
  final DateTime uploadedAt;

  MediaModel({
    required this.id,
    required this.familyId,
    required this.uploaderUid,
    required this.uploaderName,
    required this.url,
    required this.type,
    this.caption,
    required this.sizeInBytes,
    required this.uploadedAt,
  });

  factory MediaModel.fromMap(Map<String, dynamic> map, String docId) {
    return MediaModel(
      id:           docId,
      familyId:     map['familyId'] ?? '',
      uploaderUid:  map['uploaderUid'] ?? '',
      uploaderName: map['uploaderName'] ?? '',
      url:          map['url'] ?? '',
      type:         _typeFromString(map['type']),
      caption:      map['caption'],
      sizeInBytes:  map['sizeInBytes'] ?? 0,
      uploadedAt:   (map['uploadedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'familyId':     familyId,
      'uploaderUid':  uploaderUid,
      'uploaderName': uploaderName,
      'url':          url,
      'type':         type.name,
      'caption':      caption,
      'sizeInBytes':  sizeInBytes,
      'uploadedAt':   Timestamp.fromDate(uploadedAt),
    };
  }

  static MediaType _typeFromString(String? value) {
    switch (value) {
      case 'photo': return MediaType.photo;
      case 'video': return MediaType.video;
      case 'audio': return MediaType.audio;
      default:      return MediaType.file;
    }
  }
}