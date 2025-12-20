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
}
