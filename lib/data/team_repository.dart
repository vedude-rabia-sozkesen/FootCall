import 'package:flutter/material.dart';

import '../models/team_model.dart';

class TeamRepository {
  TeamRepository._();

  static final TeamRepository instance = TeamRepository._();

  final ValueNotifier<List<TeamModel>> teamsNotifier =
      ValueNotifier<List<TeamModel>>(_initialTeams);

  void addTeam(TeamModel team) {
    final updated = List<TeamModel>.from(teamsNotifier.value)..add(team);
    teamsNotifier.value = updated;
  }

  void removeTeam(String teamId) {
    final updated = teamsNotifier.value.where((t) => t.id != teamId).toList();
    teamsNotifier.value = updated;
  }

  TeamModel? findById(String teamId) {
    return teamsNotifier.value
        .where((team) => team.id == teamId)
        .cast<TeamModel?>()
        .firstWhere((team) => team != null, orElse: () => null);
  }

  List<TeamModel> filterByCity(String city) {
    return teamsNotifier.value
        .where((team) => team.city.toLowerCase().contains(city.toLowerCase()))
        .toList();
  }

  List<TeamModel> filterByDistrict(String district) {
    return teamsNotifier.value
        .where(
            (team) => team.district.toLowerCase().contains(district.toLowerCase()))
        .toList();
  }

  static final List<TeamModel> _initialTeams = [
    TeamModel(
      id: 'team-1',
      teamName: 'Galatasaray',
      city: 'İstanbul',
      district: 'Sarıyer',
    ),
    TeamModel(
      id: 'team-2',
      teamName: 'Gaziosmanpaşa',
      city: 'İstanbul',
      district: 'Gaziosmanpaşa',
    ),
    TeamModel(
      id: 'team-3',
      teamName: 'Gaziosmanpaşa',
      city: 'İstanbul',
      district: 'Gaziosmanpaşa',
    ),
    TeamModel(
      id: 'team-4',
      teamName: 'Gaziosmanpaşa',
      city: 'İstanbul',
      district: 'Gaziosmanpaşa',
    ),
    TeamModel(
      id: 'team-5',
      teamName: 'Gaziosmanpaşa',
      city: 'İstanbul',
      district: 'Gaziosmanpaşa',
    ),
    TeamModel(
      id: 'team-6',
      teamName: 'Beşiktaş United',
      city: 'İstanbul',
      district: 'Beşiktaş',
    ),
    TeamModel(
      id: 'team-7',
      teamName: 'Fenerbahçe Squad',
      city: 'İstanbul',
      district: 'Kadıköy',
    ),
    TeamModel(
      id: 'team-8',
      teamName: 'Ankara Gücü',
      city: 'Ankara',
      district: 'Çankaya',
    ),
  ];
}
