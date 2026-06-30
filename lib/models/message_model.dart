import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageSender { partyA, partyB, ai }

class MessageModel {
  final String id;
  final String chatId;
  final MessageSender sender;
  final String text;
  final DateTime sentAt;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.sender,
    required this.text,
    required this.sentAt,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map, String docId) {
    return MessageModel(
      id:      docId,
      chatId:  map['chatId'] ?? '',
      sender:  _senderFromString(map['sender']),
      text:    map['text'] ?? '',
      sentAt:  (map['sentAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chatId':  chatId,
      'sender':  sender.name,
      'text':    text,
      'sentAt':  Timestamp.fromDate(sentAt),
    };
  }

  static MessageSender _senderFromString(String? value) {
    switch (value) {
      case 'partyA': return MessageSender.partyA;
      case 'partyB': return MessageSender.partyB;
      default:       return MessageSender.ai;
    }
  }
}