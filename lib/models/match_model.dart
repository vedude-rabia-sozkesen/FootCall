import 'package:cloud_firestore/cloud_firestore.dart';

class MatchModel {
  const MatchModel({
    required this.id,
    required this.teamAId,
    required this.teamBId,
    required this.status,
    required this.matchDate,
    this.scoreA,
    this.scoreB,
    required this.location,
    this.createdBy,
    this.createdAt,
  });

  final String id;
  final String teamAId;
  final String teamBId;
  final String status;
  final Timestamp matchDate;
  final int? scoreA;
  final int? scoreB;
  final String location;
  final String? createdBy;
  final Timestamp? createdAt;

  factory MatchModel.fromMap(Map<String, dynamic> map, String id) {
    return MatchModel(
      id: id,
      teamAId: map['teamA_id'] as String? ?? '',
      teamBId: map['teamB_id'] as String? ?? '',
      status: map['status'] as String? ?? 'scheduled',
      matchDate: map['matchDate'] as Timestamp? ?? Timestamp.now(),
      scoreA: map['scoreA'] as int?,
      scoreB: map['scoreB'] as int?,
      location: map['location'] as String? ?? '',
      createdBy: map['createdBy'] as String?,
      createdAt: map['createdAt'] as Timestamp?,
    );
  }

  factory MatchModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    return MatchModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  MatchModel copyWith({
    String? id,
    String? teamAId,
    String? teamBId,
    String? status,
    Timestamp? matchDate,
    int? scoreA,
    int? scoreB,
    String? location,
    String? createdBy,
    Timestamp? createdAt,
  }) {
    return MatchModel(
      id: id ?? this.id,
      teamAId: teamAId ?? this.teamAId,
      teamBId: teamBId ?? this.teamBId,
      status: status ?? this.status,
      matchDate: matchDate ?? this.matchDate,
      scoreA: scoreA ?? this.scoreA,
      scoreB: scoreB ?? this.scoreB,
      location: location ?? this.location,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

