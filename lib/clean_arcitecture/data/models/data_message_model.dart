import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/entities_message_model.dart';
import 'converter/converter.dart';

part 'data_message_model.g.dart';

@JsonSerializable()
class Messages {
  late final String role;
  late final String content;
  @TimestampConverter()
  late final DateTime? timestamp; // Firestore 타임스탬프

  Messages({required this.role, required this.content, this.timestamp});

  factory Messages.fromJson(Map<String, dynamic> json) =>
      _$MessagesFromJson(json);

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
        timestamp: entity.timestamp);
  }
}
