import 'package:cloud_firestore/cloud_firestore.dart';

class AppSettingsModel {
  final int totalGroups;
  final int totalUsers;
  final int totalMediaUploaded;
  final int activeGroupsToday;
  final DateTime lastUpdated;

  AppSettingsModel({
    required this.totalGroups,
    required this.totalUsers,
    required this.totalMediaUploaded,
    required this.activeGroupsToday,
    required this.lastUpdated,
  });

  factory AppSettingsModel.fromMap(Map<String, dynamic> map) {
    return AppSettingsModel(
      totalGroups:        map['totalGroups'] ?? 0,
      totalUsers:         map['totalUsers'] ?? 0,
      totalMediaUploaded: map['totalMediaUploaded'] ?? 0,
      activeGroupsToday:  map['activeGroupsToday'] ?? 0,
      lastUpdated:        (map['lastUpdated'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalGroups':        totalGroups,
      'totalUsers':         totalUsers,
      'totalMediaUploaded': totalMediaUploaded,
      'activeGroupsToday':  activeGroupsToday,
      'lastUpdated':        Timestamp.fromDate(lastUpdated),
    };
  }
}