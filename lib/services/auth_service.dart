import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get userStream => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

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
          'phone': '', // Initially empty, can be updated from profile
          'location': '', // Initially empty, can be updated from profile
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