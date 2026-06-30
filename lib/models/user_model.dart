import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { admin, member }

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final UserRole role;
  final List<String> familyIds;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.role = UserRole.member,
    this.familyIds = const [],
    required this.createdAt,
  });

  bool get isAdmin => role == UserRole.admin;
  bool isMemberOf(String familyId) => familyIds.contains(familyId);

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid:        map['uid'] ?? '',
      name:       map['name'] ?? '',
      email:      map['email'] ?? '',
      photoUrl:   map['photoUrl'],
      role:       map['role'] == 'admin'
          ? UserRole.admin
          : UserRole.member,
      familyIds:  List<String>.from(map['familyIds'] ?? []),
      createdAt:  (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid':        uid,
      'name':       name,
      'email':      email,
      'photoUrl':   photoUrl,
      'role':       role == UserRole.admin ? 'admin' : 'member',
      'familyIds':  familyIds,
      'createdAt':  Timestamp.fromDate(createdAt),
    };
  }

  UserModel copyWith({
    String? name,
    String? photoUrl,
    UserRole? role,
    List<String>? familyIds,
  }) {
    return UserModel(
      uid:        uid,
      name:       name ?? this.name,
      email:      email,
      photoUrl:   photoUrl ?? this.photoUrl,
      role:       role ?? this.role,
      familyIds:  familyIds ?? this.familyIds,
      createdAt:  createdAt,
    );
  }
}