import 'entities_message_model.dart';

class ChatDataSourceEntity {
  late final String model;
  late final List<MessagesEntity> messages;
  late final bool stream;

  ChatDataSourceEntity({
    required this.model,
    required this.messages,
    required this.stream,
  });
}
