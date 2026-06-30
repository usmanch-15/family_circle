import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { admin, member }

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final UserRole role;
  final String? familyId;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.role = UserRole.member,
    this.familyId,
    required this.createdAt,
  });

  bool get isAdmin => role == UserRole.admin;

  // Firestore se UserModel banana
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid:       map['uid'] ?? '',
      name:      map['name'] ?? '',
      email:     map['email'] ?? '',
      photoUrl:  map['photoUrl'],
      role:      map['role'] == 'admin'
          ? UserRole.admin
          : UserRole.member,
      familyId:  map['familyId'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  // Firestore mein save karne ke liye Map
  Map<String, dynamic> toMap() {
    return {
      'uid':       uid,
      'name':      name,
      'email':     email,
      'photoUrl':  photoUrl,
      'role':      role == UserRole.admin ? 'admin' : 'member',
      'familyId':  familyId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Copy with updated fields
  UserModel copyWith({
    String? name,
    String? photoUrl,
    UserRole? role,
    String? familyId,
  }) {
    return UserModel(
      uid:       uid,
      name:      name ?? this.name,
      email:     email,
      photoUrl:  photoUrl ?? this.photoUrl,
      role:      role ?? this.role,
      familyId:  familyId ?? this.familyId,
      createdAt: createdAt,
    );
  }
}