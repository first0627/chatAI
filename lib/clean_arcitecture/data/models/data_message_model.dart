import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/entities_message_model.dart';

class Messages {
  late final String role;
  late final String content;
  late final Timestamp? timestamp; // Firestore 타임스탬프

  Messages({required this.role, required this.content, this.timestamp});

  MessagesEntity toEntity() {
    return MessagesEntity(
      role: role,
      content: content,
      timestamp: timestamp,
    );
  }

  static Messages fromEntity(MessagesEntity entity) {
    return Messages(
      role: entity.role,
      content: entity.content,
      timestamp: entity.timestamp,
    );
  }

  Messages.fromJson(Map<String, dynamic> json) {
    role = json['role'];
    content = json['content'];
    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['role'] = role;
    data['content'] = content;
    data['timestamp'] = timestamp;
    return data;
  }

  Messages copyWith({String? role, String? content, Timestamp? timestamp}) {
    return Messages(
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}