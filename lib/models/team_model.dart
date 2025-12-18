import 'player_info.dart';

class TeamModel {
  const TeamModel({
    required this.id,
    required this.name,
    required this.city,
    required this.district,
    required this.players,
    required this.previousMatches,
  });

  final String id;
  final String name;
  final String city;
  final String district;
  final List<PlayerInfo> players;
  final List<String> previousMatches;
}
