import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MatchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<QuerySnapshot> getMatches() {
    return _firestore.collection('matches').snapshots();
  }

  Stream<DocumentSnapshot> getMatchStream(String matchId) {
    return _firestore.collection('matches').doc(matchId).snapshots();
  }

  Stream<QuerySnapshot> getNextMatchStream(List<String> playerTeamIds) {
    if (playerTeamIds.isEmpty) return Stream.empty();
    return _firestore
        .collection('matches')
        .where(Filter.or(Filter('teamA_id', whereIn: playerTeamIds), Filter('teamB_id', whereIn: playerTeamIds)))
        .where('status', isEqualTo: 'scheduled')
        .orderBy('matchDate')
        .limit(1)
        .snapshots();
  }

  Stream<QuerySnapshot> getPreviousMatchesStream(List<String> playerTeamIds, {int limit = 3}) {
    if (playerTeamIds.isEmpty) return Stream.empty();
    return _firestore
        .collection('matches')
        .where(Filter.or(Filter('teamA_id', whereIn: playerTeamIds), Filter('teamB_id', whereIn: playerTeamIds)))
        .where('status', isEqualTo: 'played')
        .orderBy('matchDate', descending: true)
        .limit(limit)
        .snapshots();
  }


  Future<void> updateMatchResult({
    required String matchId,
    required int scoreA,
    required int scoreB,
  }) async {
    DocumentReference matchRef = _firestore.collection('matches').doc(matchId);

    return _firestore.runTransaction((transaction) async {
      DocumentSnapshot matchSnapshot = await transaction.get(matchRef);
      if (!matchSnapshot.exists) {
        throw Exception("Match does not exist!");
      }
      final matchData = matchSnapshot.data() as Map<String, dynamic>;

      final String currentStatus = matchData['status'] ?? 'scheduled';
      final bool wasCompleted = currentStatus == 'completed' || currentStatus == 'played';
      final int oldScoreA = matchData['scoreA'] ?? 0;
      final int oldScoreB = matchData['scoreB'] ?? 0;

      final String teamAId = matchData['teamA_id'];
      final String teamBId = matchData['teamB_id'];

      DocumentSnapshot teamASnapshot = await transaction.get(_firestore.collection('teams').doc(teamAId));
      DocumentSnapshot teamBSnapshot = await transaction.get(_firestore.collection('teams').doc(teamBId));
      
      if (!teamASnapshot.exists || !teamBSnapshot.exists) {
        throw Exception("One or both teams not found!");
      }

      List<String> teamAPlayerIds = List<String>.from((teamASnapshot.data() as Map<String, dynamic>)['memberIds'] ?? []);
      List<String> teamBPlayerIds = List<String>.from((teamBSnapshot.data() as Map<String, dynamic>)['memberIds'] ?? []);
      List<String> allPlayerIds = [...teamAPlayerIds, ...teamBPlayerIds];

      // If the match was already completed, revert the old stats first.
      if (wasCompleted) {
        String? oldWinnerTeamId;
        if (oldScoreA > oldScoreB) oldWinnerTeamId = teamAId;
        else if (oldScoreB > oldScoreA) oldWinnerTeamId = teamBId;

        for (String playerId in allPlayerIds) {
          DocumentReference playerRef = _firestore.collection('players').doc(playerId);
          
          bool wasWinner = oldWinnerTeamId != null && 
                          ((teamAPlayerIds.contains(playerId) && oldWinnerTeamId == teamAId) || 
                           (teamBPlayerIds.contains(playerId) && oldWinnerTeamId == teamBId));
          
          bool wasLoser = oldWinnerTeamId != null && !wasWinner;

          transaction.update(playerRef, {
            'matchesPlayed': FieldValue.increment(-1),
            if (wasWinner) 'wins': FieldValue.increment(-1),
            if (wasLoser) 'losses': FieldValue.increment(-1),
          });
        }
      }

      // Now, update the match with the new score
      transaction.update(matchRef, {
        'scoreA': scoreA,
        'scoreB': scoreB,
        'status': 'played',
      });
      
      // And apply the new stats
      String? newWinnerTeamId;
      if (scoreA > scoreB) newWinnerTeamId = teamAId;
      else if (scoreB > scoreA) newWinnerTeamId = teamBId;

      for (String playerId in allPlayerIds) {
        DocumentReference playerRef = _firestore.collection('players').doc(playerId);
        
        bool isWinner = newWinnerTeamId != null && 
                        ((teamAPlayerIds.contains(playerId) && newWinnerTeamId == teamAId) || 
                         (teamBPlayerIds.contains(playerId) && newWinnerTeamId == teamBId));
        
        bool isLoser = newWinnerTeamId != null && !isWinner;

        transaction.update(playerRef, {
          'matchesPlayed': FieldValue.increment(1),
          if (isWinner) 'wins': FieldValue.increment(1),
          if (isLoser) 'losses': FieldValue.increment(1),
        });
      }
    });
  }

  Future<DocumentReference> createMatch({
    required String title,
    required String location,
    required DateTime matchDate,
  }) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        throw Exception("User not logged in");
      }
      final String uid = user.uid;

      DocumentReference docRef = await _firestore.collection('matches').add({
        'createdBy': uid,
        'createdAt': FieldValue.serverTimestamp(),
        'title': title,
        'location': location,
        'matchDate': Timestamp.fromDate(matchDate),
        'playerIds': [uid], 
        'status': 'pending',
      });

      await docRef.update({'id': docRef.id});
      
      return docRef;
    } catch (e) {
      rethrow;
    }
  }
}