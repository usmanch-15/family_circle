import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/chat_model.dart';
import '../utils/constants.dart';

class ChatService {
  final _firestore = FirebaseFirestore.instance;
  final _storage   = FirebaseStorage.instance;

  // ─── Text message bhejna ──────────────────────────────
  Future<void> sendTextMessage({
    required String familyId,
    required String senderUid,
    required String senderName,
    String? senderPhotoUrl,
    required String text,
  }) async {
    final docRef = _firestore
        .collection(Collections.families)
        .doc(familyId)
        .collection(Collections.chats)
        .doc();

    final message = ChatModel(
      id:             docRef.id,
      familyId:       familyId,
      senderUid:      senderUid,
      senderName:     senderName,
      senderPhotoUrl: senderPhotoUrl,
      type:           ChatMessageType.text,
      text:           text,
      sentAt:         DateTime.now(),
    );

    await docRef.set(message.toMap());
  }

  // ─── Image message bhejna ──────────────────────────────
  Future<void> sendImageMessage({
    required String familyId,
    required String senderUid,
    required String senderName,
    String? senderPhotoUrl,
    required File imageFile,
  }) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final storageRef = _storage
        .ref()
        .child('families/$familyId/chat/$fileName');

    final uploadTask = await storageRef.putFile(imageFile);
    final url = await uploadTask.ref.getDownloadURL();

    final docRef = _firestore
        .collection(Collections.families)
        .doc(familyId)
        .collection(Collections.chats)
        .doc();

    final message = ChatModel(
      id:             docRef.id,
      familyId:       familyId,
      senderUid:      senderUid,
      senderName:     senderName,
      senderPhotoUrl: senderPhotoUrl,
      type:           ChatMessageType.image,
      mediaUrl:       url,
      sentAt:         DateTime.now(),
    );

    await docRef.set(message.toMap());
  }

  // ─── Voice message bhejna ───────────────────────────────
  Future<void> sendVoiceMessage({
    required String familyId,
    required String senderUid,
    required String senderName,
    String? senderPhotoUrl,
    required File audioFile,
    required int durationSeconds,
  }) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.m4a';
    final storageRef = _storage
        .ref()
        .child('families/$familyId/chat/$fileName');

    final uploadTask = await storageRef.putFile(audioFile);
    final url = await uploadTask.ref.getDownloadURL();

    final docRef = _firestore
        .collection(Collections.families)
        .doc(familyId)
        .collection(Collections.chats)
        .doc();

    final message = ChatModel(
      id:                   docRef.id,
      familyId:             familyId,
      senderUid:            senderUid,
      senderName:           senderName,
      senderPhotoUrl:       senderPhotoUrl,
      type:                 ChatMessageType.voice,
      mediaUrl:             url,
      voiceDurationSeconds: durationSeconds,
      sentAt:               DateTime.now(),
    );

    await docRef.set(message.toMap());
  }

  // ─── Group ke messages ka real-time stream ────────────
  Stream<List<ChatModel>> messagesStream(String familyId) {
    return _firestore
        .collection(Collections.families)
        .doc(familyId)
        .collection(Collections.chats)
        .orderBy('sentAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snap) => snap.docs
        .map((d) => ChatModel.fromMap(d.data(), d.id))
        .toList());
  }

  // ─── Message pe like/reaction lagana ya hatana ────────
  Future<void> toggleLike({
    required String familyId,
    required String messageId,
    required String userUid,
    required bool isCurrentlyLiked,
  }) async {
    final docRef = _firestore
        .collection(Collections.families)
        .doc(familyId)
        .collection(Collections.chats)
        .doc(messageId);

    await docRef.update({
      'likedBy': isCurrentlyLiked
          ? FieldValue.arrayRemove([userUid])
          : FieldValue.arrayUnion([userUid]),
    });
  }

  // ─── Messages mein text search karna ──────────────────
  Future<List<ChatModel>> searchMessages({
    required String familyId,
    required String query,
  }) async {
    final snap = await _firestore
        .collection(Collections.families)
        .doc(familyId)
        .collection(Collections.chats)
        .where('type', isEqualTo: 'text')
        .orderBy('sentAt', descending: true)
        .get();

    final lowerQuery = query.toLowerCase();
    return snap.docs
        .map((d) => ChatModel.fromMap(d.data(), d.id))
        .where((m) => m.text?.toLowerCase().contains(lowerQuery) ?? false)
        .toList();
  }

  // ─── Message delete karna ──────────────────────────────
  Future<void> deleteMessage({
    required String familyId,
    required String messageId,
  }) async {
    await _firestore
        .collection(Collections.families)
        .doc(familyId)
        .collection(Collections.chats)
        .doc(messageId)
        .delete();
  }
}
