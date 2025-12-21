import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../services/match_service.dart';

class MatchesProvider extends ChangeNotifier {
  final MatchService _matchService;
  StreamSubscription<QuerySnapshot>? _matchesSubscription;

  List<QueryDocumentSnapshot> _matches = [];
  bool _isLoading = false;
  String? _error;

  MatchesProvider(this._matchService) {
    loadMatches();
  }

  // Getters
  List<QueryDocumentSnapshot> get matches => List.unmodifiable(_matches);
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load matches from Firestore stream
  void loadMatches() {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _matchesSubscription?.cancel();
      _matchesSubscription = _matchService.getMatches().listen(
        (snapshot) {
          _matches = snapshot.docs;
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

  // Create match
  Future<void> createMatch({
    required String title,
    required String location,
    required DateTime matchDate,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _matchService.createMatch(
        title: title,
        location: location,
        matchDate: matchDate,
      );
      
      // Matches will be updated via stream listener
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Update match result
  Future<void> updateMatchResult({
    required String matchId,
    required int scoreA,
    required int scoreB,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _matchService.updateMatchResult(
        matchId: matchId,
        scoreA: scoreA,
        scoreB: scoreB,
      );
      
      // Matches will be updated via stream listener
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Get match by ID
  QueryDocumentSnapshot? getMatchById(String matchId) {
    try {
      return _matches.firstWhere((doc) => doc.id == matchId);
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    _matchesSubscription?.cancel();
    super.dispose();
  }
}

