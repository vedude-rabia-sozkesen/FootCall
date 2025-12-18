import 'package:flutter/material.dart';

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
      cityDistrict: 'Ankara/Polatlı',
      matchTitle: 'Lions vs Birds',
      timeRange: '12.00-14.00',
      location: 'Polatlı Arena, Ankara',
      playingTeam: 'Lions',
      creatorName: 'Coach Selim',
      assetLogoPath: 'lib/images/team_logo.png',
      coverImageUrl:
          'https://images.unsplash.com/photo-1461896836934-ffe607ba8211',
    ),
    MatchModel(
      id: 'match-2',
      cityDistrict: 'İstanbul/Gaziosmanpaşa',
      matchTitle: 'Team0',
      timeRange: '11.00-13.00',
      location: 'Albayrak football field, Gaziosmanpaşa/İstanbul',
      playingTeam: 'Team0',
      creatorName: 'Coach Duru',
      assetLogoPath: 'lib/images/team_logo.png',
      coverImageUrl:
          'https://images.unsplash.com/photo-1508804185872-d7badad00f7d',
    ),
    MatchModel(
      id: 'match-3',
      cityDistrict: 'Ankara/Polatlı',
      matchTitle: 'Lions vs Birds',
      timeRange: '12.00-14.00',
      location: 'Polatlı Arena, Ankara',
      playingTeam: 'Birds',
      creatorName: 'Coach Onur',
      assetLogoPath: 'lib/images/team_logo.png',
      coverImageUrl:
          'https://images.unsplash.com/photo-1508609349937-5ec4ae374ebf',
    ),
  ];
}

