import 'package:flutter/material.dart';
import 'dart:async';
import '../services/team_service.dart';
import '../models/team_model.dart';

class TeamsProvider extends ChangeNotifier {
  final TeamService _teamService;
  StreamSubscription<List<TeamModel>>? _teamsSubscription;

  List<TeamModel> _teams = [];
  bool _isLoading = false;
  String? _error;

  TeamsProvider(this._teamService) {
    loadTeams();
  }

  // Getters
  List<TeamModel> get teams => List.unmodifiable(_teams);
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load teams from Firestore stream
  void loadTeams() {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _teamsSubscription?.cancel();
      _teamsSubscription = _teamService.getTeamsStream().listen(
        (teams) {
          _teams = teams;
          _isLoading = false;
          _error = null;
          notifyListeners();
        },
        onError: (error) {
          _error = error.toString();
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create team
  Future<void> createTeam(TeamModel team) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _teamService.createTeam(team);
      
      // Teams will be updated via stream listener
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Get team by ID
  Future<TeamModel?> getTeam(String teamId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final team = await _teamService.getTeam(teamId);
      
      _isLoading = false;
      notifyListeners();
      return team;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Join team
  Future<void> joinTeam(String teamId, String playerId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _teamService.joinTeam(teamId, playerId);
      
      // Teams will be updated via stream listener
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Leave team
  Future<void> leaveTeam(String teamId, String playerId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _teamService.leaveTeam(teamId, playerId);
      
      // Teams will be updated via stream listener
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Make new admin
  Future<void> makeNewAdmin(String teamId, String newAdminId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _teamService.makeNewAdmin(teamId, newAdminId);
      
      // Teams will be updated via stream listener
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Get team by ID from cached list
  TeamModel? getTeamById(String teamId) {
    try {
      return _teams.firstWhere((team) => team.id == teamId);
    } catch (e) {
      return null;
    }
  }

  // Send team join request to player
  Future<void> sendTeamJoinRequestToPlayer({
    required String teamId,
    required String playerId,
    required String requestedBy,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _teamService.sendTeamJoinRequestToPlayer(
        teamId: teamId,
        playerId: playerId,
        requestedBy: requestedBy,
      );
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Check if request has been sent to player
  Future<bool> hasPendingRequestToPlayer({
    required String teamId,
    required String playerId,
  }) async {
    try {
      return await _teamService.hasPendingRequestToPlayer(
        teamId: teamId,
        playerId: playerId,
      );
    } catch (e) {
      return false;
    }
  }

  @override
  void dispose() {
    _teamsSubscription?.cancel();
    super.dispose();
  }
}

