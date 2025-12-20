import '../models/team_model.dart';

class TeamRepository {
  TeamRepository._();

  static final TeamRepository instance = TeamRepository._();

  // Emptying static data to favor dynamic Firebase data
  final List<TeamModel> _teams = [];

  List<TeamModel> get teams => List.unmodifiable(_teams);

  TeamModel? findByName(String name) {
    return null;
  }
}
