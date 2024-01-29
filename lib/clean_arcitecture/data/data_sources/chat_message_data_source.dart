import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/data_message_model.dart';

class ChatMessageDataSource {
  final _userId = FirebaseAuth.instance.currentUser?.uid;
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Firestore 인스턴스를 속성으로 추가

  Future<List<Messages>> loadMessagesFromFirestore() async {
    if (_userId == null) {
      throw FirebaseAuthException(
        code: 'no-user',
        message: 'No user logged in',
      );
    }

    try {
      var userDoc =
          _firestore.collection('chats').doc(_userId); // _firestore 인스턴스 사용
      var collection = userDoc.collection('messages');
      var querySnapshot =
          await collection.orderBy('timestamp', descending: true).get();

      return querySnapshot.docs.map((doc) {
        return Messages(
          role: doc['role'],
          content: doc['content'],
        );
      }).toList();
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code}, ${e.message}');
      rethrow;
    } catch (e) {
      print('General Exception: $e');
      rethrow;
    }
  }

  Future<void> saveMessageToFirestore(Messages message) async {
    if (_userId == null) {
      throw FirebaseAuthException(
        code: 'no-user',
        message: 'No user logged in',
      );
    }

    try {
      var docRef = _firestore
          .collection('chats')
          .doc(_userId)
          .collection('messages'); // _firestore 인스턴스 사용
      await docRef.add({
        'role': message.role,
        'content': message.content,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code}, ${e.message}');
      rethrow;
    } catch (e) {
      print('General Exception: $e');
      rethrow;
    }
  }
}
