import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/data_message_model.dart';

class ChatMessageDataSource {
  Future<List<Messages>> loadMessagesFromFirestore(String? userId) async {
    if (userId == null) return [];

    var userDoc = FirebaseFirestore.instance.collection('chats').doc(userId);
    var collection = userDoc.collection('messages');
    var querySnapshot =
        await collection.orderBy('timestamp', descending: true).get();

    return querySnapshot.docs.map((doc) {
      return Messages(
        role: doc['role'],
        content: doc['content'],
      );
    }).toList();
  }

  Future<void> saveMessageToFirestore(Messages message, String? userId) async {
    if (userId != null) {
      var docRef = FirebaseFirestore.instance
          .collection('chats')
          .doc(userId)
          .collection('messages');

      await docRef.add({
        'role': message.role,
        'content': message.content,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } else {
      print("유저 ID가 null입니다.");
    }
  }
}
