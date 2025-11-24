import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/match_model.dart';
import '../models/player_join_request.dart';
import '../models/team_request.dart';

class RequestRepository {
  RequestRepository._();

  static final RequestRepository instance = RequestRepository._();

  final ValueNotifier<List<TeamRequest>> teamRequestsNotifier =
      ValueNotifier<List<TeamRequest>>([]);

  final ValueNotifier<List<PlayerJoinRequest>> playerRequestsNotifier =
      ValueNotifier<List<PlayerJoinRequest>>([]);

  /// Placeholder while profile data is not available.
  String placeholderTeamName = 'Jaguars'; // to be filled: team name from profile
  String placeholderPlayerName = 'Guest Player'; // to be filled: player name

  final _uuid = const Uuid();

  void addTeamRequest(MatchModel match) {
    final request = TeamRequest(
      id: _uuid.v4(),
      teamName: placeholderTeamName,
      matchTitle: match.matchTitle,
      matchId: match.id,
      createdAt: DateTime.now(),
    );
    final updated = List<TeamRequest>.from(teamRequestsNotifier.value)
      ..insert(0, request);
    teamRequestsNotifier.value = updated;
  }

  void addPlayerRequest(MatchModel match) {
    final request = PlayerJoinRequest(
      id: _uuid.v4(),
      playerName: placeholderPlayerName,
      matchTitle: match.matchTitle,
      matchId: match.id,
      createdAt: DateTime.now(),
    );
    final updated = List<PlayerJoinRequest>.from(playerRequestsNotifier.value)
      ..insert(0, request);
    playerRequestsNotifier.value = updated;
  }

  /// Add team request for a specific match creator (admin)
  void addTeamRequestForCreator(MatchModel match, String creatorName) {
    final request = TeamRequest(
      id: _uuid.v4(),
      teamName: placeholderTeamName,
      matchTitle: match.matchTitle,
      matchId: match.id,
      createdAt: DateTime.now(),
    );
    // Note: In a real implementation, this would send to the creator's request list
    // For now, we add it to the general team requests list
    // The creator name is stored in match.creatorName for reference
    final updated = List<TeamRequest>.from(teamRequestsNotifier.value)
      ..insert(0, request);
    teamRequestsNotifier.value = updated;
  }

  /// Add player request for a specific match creator (admin)
  void addPlayerRequestForCreator(MatchModel match, String creatorName) {
    final request = PlayerJoinRequest(
      id: _uuid.v4(),
      playerName: placeholderPlayerName,
      matchTitle: match.matchTitle,
      matchId: match.id,
      createdAt: DateTime.now(),
    );
    // Note: In a real implementation, this would send to the creator's admin panel
    // For now, we add it to the general player requests list
    // The creator name is stored in match.creatorName for reference
    final updated = List<PlayerJoinRequest>.from(playerRequestsNotifier.value)
      ..insert(0, request);
    playerRequestsNotifier.value = updated;
  }
}




