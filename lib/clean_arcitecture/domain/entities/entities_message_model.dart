import 'package:cloud_firestore/cloud_firestore.dart';

class MessagesEntity {
  late final String role;
  late final String content;
  late final Timestamp? timestamp; // Firestore 타임스탬프

  MessagesEntity({required this.role, required this.content, this.timestamp});

  MessagesEntity copyWith(
      {String? role, String? content, Timestamp? timestamp}) {
    return MessagesEntity(
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
