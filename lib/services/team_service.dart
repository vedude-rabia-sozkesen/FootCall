import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/team_model.dart';

class TeamService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createTeam(TeamModel team) async {
    try {
      await _firestore.collection('teams').doc(team.id).set(team.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<TeamModel?> getTeam(String teamId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('teams').doc(teamId).get();
      if (doc.exists) {
        return TeamModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<TeamModel>> getTeamsStream() {
    return _firestore.collection('teams').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => TeamModel.fromFirestore(doc)).toList();
    });
  }

  Future<void> joinTeam(String teamId, String playerId) async {
    try {
      await _firestore.collection('teams').doc(teamId).update({
        'memberIds': FieldValue.arrayUnion([playerId])
      });
      await _firestore.collection('players').doc(playerId).update({'currentTeamId': teamId});
    } catch (e) {
      rethrow;
    }
  }

  Future<void> leaveTeam(String teamId, String playerId) async {
    final teamRef = _firestore.collection('teams').doc(teamId);

    try {
      await _firestore.runTransaction((transaction) async {
        final teamDoc = await transaction.get(teamRef);
        if (!teamDoc.exists) return;

        final teamData = teamDoc.data()!;
        List<String> memberIds = List<String>.from(teamData['memberIds'] ?? []);
        memberIds.remove(playerId);

        if (memberIds.isEmpty) {
          // No players left, destroy the team
          transaction.delete(teamRef);
        } else {
          // Check if the leaving player is the admin
          if (teamData['createdBy'] == playerId) {
            // Admin is leaving, assign a new admin
            String newAdminId = memberIds.first;
            transaction.update(teamRef, {
              'memberIds': memberIds,
              'createdBy': newAdminId,
            });
          } else {
            // A regular member is leaving
            transaction.update(teamRef, {
              'memberIds': memberIds,
            });
          }
        }

        // Update player's document
        final playerRef = _firestore.collection('players').doc(playerId);
        transaction.update(playerRef, {'currentTeamId': null});
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> makeNewAdmin(String teamId, String newAdminId) async {
    final teamRef = _firestore.collection('teams').doc(teamId);
    await teamRef.update({'createdBy': newAdminId});
  }

  /// Send a team join request to a player
  /// [teamId] The team that wants to invite the player
  /// [playerId] The player to invite
  /// [requestedBy] The user ID of the person sending the request (must be team admin)
  Future<void> sendTeamJoinRequestToPlayer({
    required String teamId,
    required String playerId,
    required String requestedBy,
  }) async {
    try {
      // Check if player is already in a team
      final playerDoc = await _firestore.collection('players').doc(playerId).get();
      if (!playerDoc.exists) {
        throw Exception("Player not found.");
      }
      
      final playerData = playerDoc.data() as Map<String, dynamic>;
      final currentTeamId = playerData['currentTeamId'] as String?;
      
      if (currentTeamId != null) {
        throw Exception("Player is already in a team.");
      }

      // Check if request already exists
      final existingRequests = await _firestore
          .collection('player_team_requests')
          .where('teamId', isEqualTo: teamId)
          .where('playerId', isEqualTo: playerId)
          .where('status', isEqualTo: 'pending')
          .get();

      if (existingRequests.docs.isNotEmpty) {
        throw Exception("Request already sent to this player.");
      }

      // Create the request
      await _firestore.collection('player_team_requests').add({
        'teamId': teamId,
        'playerId': playerId,
        'requestedBy': requestedBy,
        'status': 'pending', // 'pending', 'accepted', 'rejected'
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Check if a request has been sent to a player
  Future<bool> hasPendingRequestToPlayer({
    required String teamId,
    required String playerId,
  }) async {
    try {
      final requests = await _firestore
          .collection('player_team_requests')
          .where('teamId', isEqualTo: teamId)
          .where('playerId', isEqualTo: playerId)
          .where('status', isEqualTo: 'pending')
          .get();
      
      return requests.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
