import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart'; // AuthService'i kullanarak oyuncu verilerine erişeceğiz.

class MatchRequestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  /// Bir takıma maç teklifi gönderir.
  /// 
  /// [receivingTeamId] Teklifi alan takımın ID'si.
  /// [matchDate] Teklif edilen maçın tarihi ve saati.
  /// [location] Teklif edilen maçın mekanı.
  Future<void> createMatchRequest({
    required String receivingTeamId,
    required DateTime matchDate,
    required String location,
  }) async {
    try {
      final User? currentUser = _authService.currentUser;
      if (currentUser == null) {
        throw Exception("User not logged in.");
      }

      // Teklifi gönderen oyuncunun takımını bul
      final DocumentSnapshot playerData = await _authService.getPlayerData(currentUser.uid);
      final String? sendingTeamId = (playerData.data() as Map<String, dynamic>)['currentTeamId'];

      if (sendingTeamId == null) {
        throw Exception("You are not part of a team. You cannot send a match request.");
      }
      
      if (sendingTeamId == receivingTeamId) {
        throw Exception("You cannot send a match request to your own team.");
      }

      // Yeni bir maç teklifi dokümanı oluştur
      await _firestore.collection('match_requests').add({
        'sendingTeamId': sendingTeamId,
        'receivingTeamId': receivingTeamId,
        'requestedBy': currentUser.uid,
        'status': 'pending', // 'pending', 'accepted', 'rejected'
        'proposedMatchDate': Timestamp.fromDate(matchDate),
        'proposedLocation': location,
        'createdAt': FieldValue.serverTimestamp(),
      });

    } catch (e) {
      rethrow;
    }
  }

  /// Gelen bir maç teklifini kabul eder.
  /// 
  /// Bu işlem, `match_requests` koleksiyonundan teklifi siler
  /// ve `matches` koleksiyonuna yeni bir maç ekler.
  Future<void> acceptMatchRequest(String requestId) async {
    final DocumentReference requestRef = _firestore.collection('match_requests').doc(requestId);

    return _firestore.runTransaction((transaction) async {
      // 1. Teklifin güncel durumunu al
      final DocumentSnapshot requestSnapshot = await transaction.get(requestRef);

      if (!requestSnapshot.exists) {
        throw Exception("Match request does not exist.");
      }

      final requestData = requestSnapshot.data() as Map<String, dynamic>;
      
      // 2. `matches` koleksiyonuna yeni maçı ekle
      final DocumentReference newMatchRef = _firestore.collection('matches').doc();
      transaction.set(newMatchRef, {
        'id': newMatchRef.id,
        'teamA_id': requestData['sendingTeamId'],
        'teamB_id': requestData['receivingTeamId'],
        'matchDate': requestData['proposedMatchDate'],
        'location': requestData['proposedLocation'],
        'status': 'scheduled', // Maç planlandı
        'createdAt': FieldValue.serverTimestamp(),
        'scoreA': null,
        'scoreB': null,
      });

      // 3. Orijinal teklifi `match_requests` koleksiyonundan sil
      transaction.delete(requestRef);
    });
  }

  /// Gelen bir maç teklifini reddeder.
  /// 
  /// Bu işlem, teklifi `match_requests` koleksiyonundan siler.
  Future<void> rejectMatchRequest(String requestId) async {
    try {
      await _firestore.collection('match_requests').doc(requestId).delete();
    } catch (e) {
      rethrow;
    }
  }

  /// Bir takımın aldığı beklemedeki maç tekliflerini dinler.
  /// 
  /// [teamId] Teklifleri alan takımın ID'si.
  Stream<QuerySnapshot> getPendingMatchRequestsForTeam(String teamId) {
    return _firestore
        .collection('match_requests')
        .where('receivingTeamId', isEqualTo: teamId)
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }
}
