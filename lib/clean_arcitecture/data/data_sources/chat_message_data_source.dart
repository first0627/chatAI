import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/data_message_model.dart';

class ChatMessageDataSource {
  final _userId = FirebaseAuth.instance.currentUser!.uid;

  Future<List<Messages>> loadMessagesFromFirestore() async {
    var userDoc = FirebaseFirestore.instance.collection('chats').doc(_userId);
    var collection = userDoc.collection('messages');
    var querySnapshot =
        await collection.orderBy('timestamp', descending: true).get();

    final List<Messages> loadlist = querySnapshot.docs.map((doc) {
      return Messages(
        role: doc['role'],
        content: doc['content'],
      );
    }).toList();

    return loadlist;
  }

  Future<void> saveMessageToFirestore(Messages message) async {
    var docRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(_userId)
        .collection('messages');

    await docRef.add({
      'role': message.role,
      'content': message.content,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
