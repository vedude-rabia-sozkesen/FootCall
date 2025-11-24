class PlayerModel {
  const PlayerModel({
    required this.id,
    required this.name,
    required this.position,
    required this.age,
    required this.photoUrl,
    required this.previousMatches,
    required this.likes,
    required this.dislikes,
  });

  final String id;
  final String name;
  final String position;
  final int age;
  final String photoUrl;
  final List<MatchScore> previousMatches;
  final int likes;
  final int dislikes;

  PlayerModel copyWith({
    String? id,
    String? name,
    String? position,
    int? age,
    String? photoUrl,
    List<MatchScore>? previousMatches,
    int? likes,
    int? dislikes,
  }) {
    return PlayerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      position: position ?? this.position,
      age: age ?? this.age,
      photoUrl: photoUrl ?? this.photoUrl,
      previousMatches: previousMatches ?? this.previousMatches,
      likes: likes ?? this.likes,
      dislikes: dislikes ?? this.dislikes,
    );
  }
}

class MatchScore {
  const MatchScore({
    required this.homeScore,
    required this.awayScore,
    required this.isWin,
  });

  final int homeScore;
  final int awayScore;
  final bool isWin;

  String get scoreDisplay => '$homeScore-$awayScore';
}
