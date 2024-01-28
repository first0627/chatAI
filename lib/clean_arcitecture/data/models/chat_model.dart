import '../../domain/entities/entities_chat_data_source.dart';
import 'data_message_model.dart';

class ChatCompletionModel {
  late final String model;
  late final List<Messages> messages;
  late final bool stream;

  ChatCompletionModel({
    required this.model,
    required this.messages,
    required this.stream,
  });

  static ChatCompletionModel fromEntity(ChatDataSourceEntity entity) {
    return ChatCompletionModel(
      model: entity.model,
      messages: entity.messages.map((e) => Messages.fromEntity(e)).toList(),
      stream: entity.stream,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['model'] = model;
    data['messages'] = messages
        .map((e) => {
              'role': e.role,
              'content': e.content
              // 'timestamp' 필드는 제외합니다.
            })
        .toList();
    data['stream'] = stream;
    return data;
  }
}
