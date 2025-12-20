import 'package:cloud_firestore/cloud_firestore.dart';
import 'player_info.dart';

class TeamModel {
  final String id;
  final String name;
  final String city;
  final String district;
  final String description;
  final String logoUrl;
  final String createdBy;
  final DateTime createdAt;
  final List<String> memberIds;
  final String status;
  
  final List<PlayerInfo> players;
  final List<String> previousMatches;

  TeamModel({
    required this.id,
    required this.name,
    required this.city,
    required this.district,
    this.description = '',
    this.logoUrl = '',
    this.createdBy = 'admin',
    DateTime? createdAt,
    this.memberIds = const [],
    this.status = 'active',
    this.players = const [],
    this.previousMatches = const [],
  }) : this.createdAt = createdAt ?? DateTime.now();

  factory TeamModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TeamModel(
      id: doc.id,
      name: data['name'] ?? '',
      city: data['city'] ?? '',
      district: data['district'] ?? '',
      description: data['description'] ?? '',
      logoUrl: data['logoUrl'] ?? '',
      createdBy: data['createdBy'] ?? '',
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
      memberIds: List<String>.from(data['memberIds'] ?? []),
      status: data['status'] ?? 'active',
      players: [],
      previousMatches: List<String>.from(data['previousMatches'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'district': district,
      'description': description,
      'logoUrl': logoUrl,
      'createdBy': createdBy,
      'createdAt': createdAt,
      'memberIds': memberIds,
      'status': status,
      'previousMatches': previousMatches,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is TeamModel &&
      other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
