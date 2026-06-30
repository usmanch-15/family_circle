import 'package:cloud_firestore/cloud_firestore.dart';

class FamilyModel {
  final String id;
  final String name;
  final String adminUid;
  final String inviteCode;
  final List<String> memberIds;
  final String? photoUrl;
  final bool aiEnabled;
  final DateTime createdAt;

  FamilyModel({
    required this.id,
    required this.name,
    required this.adminUid,
    required this.inviteCode,
    required this.memberIds,
    this.photoUrl,
    this.aiEnabled = false,
    required this.createdAt,
  });

  int get memberCount => memberIds.length;

  bool isAdmin(String uid) => adminUid == uid;
  bool isMember(String uid) => memberIds.contains(uid);

  factory FamilyModel.fromMap(Map<String, dynamic> map, String docId) {
    return FamilyModel(
      id:         docId,
      name:       map['name'] ?? '',
      adminUid:   map['adminUid'] ?? '',
      inviteCode: map['inviteCode'] ?? '',
      memberIds:  List<String>.from(map['memberIds'] ?? []),
      photoUrl:   map['photoUrl'],
      aiEnabled:  map['aiEnabled'] ?? false,
      createdAt:  (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name':       name,
      'adminUid':   adminUid,
      'inviteCode': inviteCode,
      'memberIds':  memberIds,
      'photoUrl':   photoUrl,
      'aiEnabled':  aiEnabled,
      'createdAt':  Timestamp.fromDate(createdAt),
    };
  }

  FamilyModel copyWith({
    String? name,
    List<String>? memberIds,
    String? photoUrl,
    bool? aiEnabled,
  }) {
    return FamilyModel(
      id:         id,
      name:       name ?? this.name,
      adminUid:   adminUid,
      inviteCode: inviteCode,
      memberIds:  memberIds ?? this.memberIds,
      photoUrl:   photoUrl ?? this.photoUrl,
      aiEnabled:  aiEnabled ?? this.aiEnabled,
      createdAt:  createdAt,
    );
  }
}