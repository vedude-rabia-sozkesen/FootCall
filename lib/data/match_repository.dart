import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/match_model.dart';

class MatchRepository {
  MatchRepository._();

  static final MatchRepository instance = MatchRepository._();

  final ValueNotifier<List<MatchModel>> matchesNotifier =
      ValueNotifier<List<MatchModel>>(_initialMatches);

  /// Placeholder until profile page exposes the actual admin flag.
  bool isAdmin = true; // to be filled: admin

  void addMatch(MatchModel match) {
    final updated = List<MatchModel>.from(matchesNotifier.value)..add(match);
    matchesNotifier.value = updated;
  }

  void removeMatch(String matchId) {
    final updated = matchesNotifier.value.where((m) => m.id != matchId).toList();
    matchesNotifier.value = updated;
  }

  MatchModel? findById(String matchId) {
    return matchesNotifier.value
        .where((match) => match.id == matchId)
        .cast<MatchModel?>()
        .firstWhere((match) => match != null, orElse: () => null);
  }

  static final List<MatchModel> _initialMatches = [
    MatchModel(
      id: 'match-1',
      teamAId: 'team-lions',
      teamBId: 'team-birds',
      status: 'scheduled',
      matchDate: Timestamp.fromDate(DateTime.now().add(const Duration(days: 1))),
      location: 'Polatlı Arena, Ankara',
      createdBy: 'coach-selim',
    ),
    MatchModel(
      id: 'match-2',
      teamAId: 'team-0',
      teamBId: 'team-1',
      status: 'scheduled',
      matchDate: Timestamp.fromDate(DateTime.now().add(const Duration(days: 2))),
      location: 'Albayrak football field, Gaziosmanpaşa/İstanbul',
      createdBy: 'coach-duru',
    ),
    MatchModel(
      id: 'match-3',
      teamAId: 'team-lions',
      teamBId: 'team-birds',
      status: 'scheduled',
      matchDate: Timestamp.fromDate(DateTime.now().add(const Duration(days: 3))),
      location: 'Polatlı Arena, Ankara',
      createdBy: 'coach-onur',
    ),
  ];
}

