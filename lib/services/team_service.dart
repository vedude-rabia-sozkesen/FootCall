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
    try {
      final teamDoc = await _firestore.collection('teams').doc(teamId).get();
      if (!teamDoc.exists) return;

      List memberIds = List.from(teamDoc.data()?['memberIds'] ?? []);
      memberIds.remove(playerId);

      if (memberIds.isEmpty) {
        // No players left, destroy the team
        await _firestore.collection('teams').doc(teamId).delete();
      } else {
        // Players still left, update member list
        await _firestore.collection('teams').doc(teamId).update({'memberIds': memberIds});
      }

      await _firestore.collection('players').doc(playerId).update({'currentTeamId': null});
    } catch (e) {
      rethrow;
    }
  }
}
