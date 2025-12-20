import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream for auth state changes
  Stream<User?> get userStream => _auth.authStateChanges();

  // Current user
  User? get currentUser => _auth.currentUser;

  // Sign Up
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

      // Create player document in Firestore
      if (credential.user != null) {
        final String uid = credential.user!.uid;
        
        await _firestore.collection('players').doc(uid).set({
          'id': uid,                // Unique ID
          'uid': uid,               // User ID reference
          'createdBy': uid,         // Linked to user ID (required)
          'createdAt': FieldValue.serverTimestamp(), // Timestamp (required)
          'name': name,             // App-specific
          'email': email,           // App-specific
          'position': position,     // App-specific
          'age': age,               // App-specific
          'photoUrl': '',           // App-specific
          'likes': 0,
          'dislikes': 0,
          'previousMatches': [], 
          'currentTeamId': null,
          'status': 'active',       // App-specific status
        });
      }
      return credential;
    } catch (e) {
      rethrow;
    }
  }

  // Login
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

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get Player Data
  Future<DocumentSnapshot> getPlayerData(String uid) {
    return _firestore.collection('players').doc(uid).get();
  }
}
