import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get userStream => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Stream<QuerySnapshot> getPlayersStream() {
    return _firestore.collection('players').snapshots();
  }

  Stream<DocumentSnapshot> getPlayerStream(String uid) {
    return _firestore.collection('players').doc(uid).snapshots();
  }

  Future<UserCredential?> signUp({
    required String email,
    required String password,
    required String name,
    required String position,
    required int age,
  }) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final String uid = credential.user!.uid;
        await _firestore.collection('players').doc(uid).set({
          'id': uid,
          'uid': uid,
          'createdBy': uid,
          'createdAt': FieldValue.serverTimestamp(),
          'name': name,
          'email': email,
          'position': position,
          'age': age,
          'photoUrl': '',
          'matchesPlayed': 0,
          'wins': 0,
          'losses': 0,
          'likes': 0,
          'dislikes': 0,
          'voters': {}, // Tracks who voted for what
          'phone': '',
          'location': '',
          'previousMatches': [],
          'currentTeamId': null,
          'status': 'active',
        });
      }
      return credential;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> likeDislikePlayer(String likedPlayerId, {required bool isLike}) async {
    final voterId = _auth.currentUser?.uid;
    if (voterId == null) {
      throw Exception("You must be logged in to vote.");
    }
    if (voterId == likedPlayerId) {
      throw Exception("You cannot vote for yourself.");
    }

    final playerRef = _firestore.collection('players').doc(likedPlayerId);

    return _firestore.runTransaction((transaction) async {
      final playerSnapshot = await transaction.get(playerRef);
      if (!playerSnapshot.exists) {
        throw Exception("Player not found.");
      }

      final playerData = playerSnapshot.data() as Map<String, dynamic>;
      final Map<String, dynamic> voters = Map<String, dynamic>.from(playerData['voters'] ?? {});
      
      final bool hasVoted = voters.containsKey(voterId);
      final bool? previousVote = hasVoted ? voters[voterId] : null;

      Map<String, dynamic> updates = {};

      if (hasVoted) {
        // If clicking the same button again, un-vote
        if (previousVote == isLike) {
          updates[isLike ? 'likes' : 'dislikes'] = FieldValue.increment(-1);
          updates['voters.$voterId'] = FieldValue.delete();
        } else {
          // If changing vote
          updates[previousVote! ? 'likes' : 'dislikes'] = FieldValue.increment(-1);
          updates[isLike ? 'likes' : 'dislikes'] = FieldValue.increment(1);
          updates['voters.$voterId'] = isLike;
        }
      } else {
        // First time voting
        updates[isLike ? 'likes' : 'dislikes'] = FieldValue.increment(1);
        updates['voters.$voterId'] = isLike;
      }

      transaction.update(playerRef, updates);
    });
  }

  /// Delete a player account (only the player themselves can delete)
  Future<void> deletePlayer(String playerId) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        throw Exception("User not logged in");
      }

      if (user.uid != playerId) {
        throw Exception("You can only delete your own account");
      }

      // Delete player document from Firestore
      await _firestore.collection('players').doc(playerId).delete();
      
      // Delete the Firebase Auth account
      await user.delete();
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential?> login({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<DocumentSnapshot> getPlayerData(String uid) {
    return _firestore.collection('players').doc(uid).get();
  }

  Future<void> updatePlayerProfile(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('players').doc(uid).update(data);
  }
}
