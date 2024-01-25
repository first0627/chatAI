import 'messages.dart';

class ChatCompletionModel {
  late final String model;
  late final List<Messages> messages;
  late final bool stream;

  ChatCompletionModel({
    required this.model,
    required this.messages,
    required this.stream,
  });

  ChatCompletionModel.fromJson(Map<String, dynamic> json) {
    model = json['model'];
    messages =
        List.from(json["messages"]).map((e) => Messages.fromJson(e)).toList();
    stream = json[stream];
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
