import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of messages for a specific team
  Stream<QuerySnapshot> getMessages(String teamId) {
    return _firestore
        .collection('teams')
        .doc(teamId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Send a message
  Future<void> sendMessage({
    required String teamId,
    required String senderId,
    required String senderName,
    required String text,
  }) async {
    try {
      await _firestore
          .collection('teams')
          .doc(teamId)
          .collection('messages')
          .add({
        'senderId': senderId,
        'senderName': senderName,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }
}
