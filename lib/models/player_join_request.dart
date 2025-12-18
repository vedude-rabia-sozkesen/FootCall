class PlayerJoinRequest {
  const PlayerJoinRequest({
    required this.id,
    required this.playerName,
    required this.matchTitle,
    required this.matchId,
    required this.createdAt,
  });

  final String id;
  final String playerName;
  final String matchTitle;
  final String matchId;
  final DateTime createdAt;
}




