// lib/domain/entities/entities_chat_data_source.dart
class ChatDataSourceEntity {
  final String response;

  ChatDataSourceEntity({required this.response});

  factory ChatDataSourceEntity.fromJson(Map<String, dynamic> json) {
    return ChatDataSourceEntity(
      response: json['response'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'response': response,
    };
  }
}
