class TeamRequest {
  const TeamRequest({
    required this.id,
    required this.teamName,
    required this.matchTitle,
    required this.matchId,
    required this.createdAt,
  });

  final String id;
  final String teamName;
  final String matchTitle;
  final String matchId;
  final DateTime createdAt;
}




