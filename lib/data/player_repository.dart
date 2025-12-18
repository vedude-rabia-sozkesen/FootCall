import 'package:flutter/material.dart';

import '../models/player_model.dart';

class PlayerRepository {
  PlayerRepository._();

  static final PlayerRepository instance = PlayerRepository._();

  final ValueNotifier<List<PlayerModel>> playersNotifier =
      ValueNotifier<List<PlayerModel>>(_initialPlayers);

  void addPlayer(PlayerModel player) {
    final updated = List<PlayerModel>.from(playersNotifier.value)..add(player);
    playersNotifier.value = updated;
  }

  void removePlayer(String playerId) {
    final updated =
        playersNotifier.value.where((p) => p.id != playerId).toList();
    playersNotifier.value = updated;
  }

  PlayerModel? findById(String playerId) {
    return playersNotifier.value
        .where((player) => player.id == playerId)
        .cast<PlayerModel?>()
        .firstWhere((player) => player != null, orElse: () => null);
  }

  void likePlayer(String playerId) {
    final player = findById(playerId);
    if (player != null) {
      final updated = player.copyWith(likes: player.likes + 1);
      _updatePlayer(updated);
    }
  }

  void dislikePlayer(String playerId) {
    final player = findById(playerId);
    if (player != null) {
      final updated = player.copyWith(dislikes: player.dislikes + 1);
      _updatePlayer(updated);
    }
  }

  void _updatePlayer(PlayerModel updatedPlayer) {
    final updated = playersNotifier.value.map((player) {
      return player.id == updatedPlayer.id ? updatedPlayer : player;
    }).toList();
    playersNotifier.value = updated;
  }

  static final List<PlayerModel> _initialPlayers = [
    PlayerModel(
      id: '34731',
      name: 'Fernando Muslera',
      position: 'Goalkeeper',
      age: 23,
      photoUrl:
          'https://images.unsplash.com/photo-1633332755192-727a05c4013d?w=400',
      previousMatches: const [
        MatchScore(homeScore: 3, awayScore: 1, isWin: true),
        MatchScore(homeScore: 0, awayScore: 0, isWin: false),
        MatchScore(homeScore: 1, awayScore: 2, isWin: false),
      ],
      likes: 17,
      dislikes: 23,
    ),
    PlayerModel(
      id: '34732',
      name: 'Mehmet Yılmaz',
      position: 'Defender',
      age: 25,
      photoUrl:
          'https://images.unsplash.com/photo-1552346154-21d32810aba3?w=400',
      previousMatches: const [
        MatchScore(homeScore: 2, awayScore: 1, isWin: true),
        MatchScore(homeScore: 3, awayScore: 2, isWin: true),
        MatchScore(homeScore: 1, awayScore: 1, isWin: false),
      ],
      likes: 45,
      dislikes: 12,
    ),
    PlayerModel(
      id: '34733',
      name: 'Ali Koç',
      position: 'Midfielder',
      age: 27,
      photoUrl:
          'https://images.unsplash.com/photo-1628157588553-5eeea00af15c?w=400',
      previousMatches: const [
        MatchScore(homeScore: 4, awayScore: 0, isWin: true),
        MatchScore(homeScore: 2, awayScore: 2, isWin: false),
        MatchScore(homeScore: 3, awayScore: 1, isWin: true),
      ],
      likes: 62,
      dislikes: 8,
    ),
    PlayerModel(
      id: '34734',
      name: 'Burak Demir',
      position: 'Striker',
      age: 24,
      photoUrl:
          'https://images.unsplash.com/photo-1552374196-1ab2a1c593e8?w=400',
      previousMatches: const [
        MatchScore(homeScore: 5, awayScore: 2, isWin: true),
        MatchScore(homeScore: 1, awayScore: 3, isWin: false),
        MatchScore(homeScore: 2, awayScore: 0, isWin: true),
      ],
      likes: 89,
      dislikes: 15,
    ),
  ];
}
