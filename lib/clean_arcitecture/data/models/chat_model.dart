import '../../../const/const.dart';
import '../../domain/entities/entities_chat_data_source.dart';
import 'data_message_model.dart';

class ChatCompletionModel {
  late final List<Messages> messages;
  late final bool stream;

  ChatCompletionModel({
    required this.messages,
    required this.stream,
  });

  static ChatCompletionModel fromEntity(ChatDataSourceEntity entity) {
    return ChatCompletionModel(
      messages: entity.messages.map((e) => Messages.fromEntity(e)).toList(),
      stream: entity.stream,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['model'] = gpt_model_version4_turbo;
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
