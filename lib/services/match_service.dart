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
