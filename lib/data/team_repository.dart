import '../models/player_info.dart';
import '../models/team_model.dart';

class TeamRepository {
  TeamRepository._();

  static final TeamRepository instance = TeamRepository._();

  final List<TeamModel> _teams = [
    TeamModel(
      id: 'team-gs',
      name: 'Galatasaray',
      city: 'Istanbul',
      district: 'Sarıyer',
      previousMatches: ['3-1', '0-0', '1-2'],
      players: const [
        PlayerInfo(
          name: 'Fernando Muslera',
          age: '28',
          position: 'GK',
          title: 'Captain',
        ),
        PlayerInfo(
          name: 'Felipe Melo',
          age: '31',
          position: 'CDM',
          title: 'Player',
        ),
      ],
    ),
    TeamModel(
      id: 'team-fb',
      name: 'Fenerbahçe',
      city: 'Istanbul',
      district: 'Gaziosmanpaşa',
      previousMatches: ['1-1', '2-0', '0-2'],
      players: const [
        PlayerInfo(
          name: 'Altay Bayındır',
          age: '24',
          position: 'GK',
          title: 'Captain',
        ),
        PlayerInfo(
          name: 'Enner Valencia',
          age: '30',
          position: 'ST',
          title: 'Player',
        ),
      ],
    ),
    TeamModel(
      id: 'team-kec',
      name: 'Keçiören FC',
      city: 'Ankara',
      district: 'Keçiören',
      previousMatches: ['0-1', '2-2', '1-0'],
      players: const [
        PlayerInfo(
          name: 'John Doe',
          age: '26',
          position: 'CM',
          title: 'Player',
        ),
      ],
    ),
    TeamModel(
      id: 'team-team0',
      name: 'Team0',
      city: 'İstanbul',
      district: 'Gaziosmanpaşa',
      previousMatches: ['1-2', '2-1', '3-1'],
      players: const [
        PlayerInfo(
          name: 'Sample Forward',
          age: '25',
          position: 'ST',
          title: 'Player',
        ),
      ],
    ),
    TeamModel(
      id: 'team-lions',
      name: 'Lions vs Birds',
      city: 'Ankara',
      district: 'Polatlı',
      previousMatches: ['2-2', '1-0', '1-3'],
      players: const [
        PlayerInfo(
          name: 'Captain Lion',
          age: '29',
          position: 'CB',
          title: 'Captain',
        ),
        PlayerInfo(
          name: 'Swift Bird',
          age: '23',
          position: 'RW',
          title: 'Player',
        ),
      ],
    ),
  ];

  List<TeamModel> get teams => List.unmodifiable(_teams);

  TeamModel? findByName(String name) {
    try {
      return _teams.firstWhere(
        (team) => team.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }
}
