import 'package:cloud_firestore/cloud_firestore.dart';

enum ChatMessageType { text, image, voice }

class ChatModel {
  final String id;
  final String familyId;
  final String senderUid;
  final String senderName;
  final String? senderPhotoUrl;
  final ChatMessageType type;
  final String? text;
  final String? mediaUrl;
  final int? voiceDurationSeconds;
  final List<String> likedBy;
  final DateTime sentAt;

  ChatModel({
    required this.id,
    required this.familyId,
    required this.senderUid,
    required this.senderName,
    this.senderPhotoUrl,
    required this.type,
    this.text,
    this.mediaUrl,
    this.voiceDurationSeconds,
    this.likedBy = const [],
    required this.sentAt,
  });

  bool isLikedBy(String uid) => likedBy.contains(uid);
  int get likeCount => likedBy.length;

  factory ChatModel.fromMap(Map<String, dynamic> map, String docId) {
    return ChatModel(
      id:                   docId,
      familyId:             map['familyId'] ?? '',
      senderUid:            map['senderUid'] ?? '',
      senderName:           map['senderName'] ?? '',
      senderPhotoUrl:       map['senderPhotoUrl'],
      type:                 _typeFromString(map['type']),
      text:                 map['text'],
      mediaUrl:             map['mediaUrl'],
      voiceDurationSeconds: map['voiceDurationSeconds'],
      likedBy:              List<String>.from(map['likedBy'] ?? []),
      sentAt:               (map['sentAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'familyId':             familyId,
      'senderUid':            senderUid,
      'senderName':           senderName,
      'senderPhotoUrl':       senderPhotoUrl,
      'type':                 type.name,
      'text':                 text,
      'mediaUrl':             mediaUrl,
      'voiceDurationSeconds': voiceDurationSeconds,
      'likedBy':              likedBy,
      'sentAt':               Timestamp.fromDate(sentAt),
    };
  }

  static ChatMessageType _typeFromString(String? value) {
    switch (value) {
      case 'image': return ChatMessageType.image;
      case 'voice': return ChatMessageType.voice;
      default:      return ChatMessageType.text;
    }
  }
}