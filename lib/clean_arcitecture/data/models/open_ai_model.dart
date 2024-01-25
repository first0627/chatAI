import 'package:cloud_firestore/cloud_firestore.dart';

class Messages {
  late final String role;
  late final String content;
  late final Timestamp? timestamp; // Firestore 타임스탬프

  Messages({required this.role, required this.content, this.timestamp});

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

// ChetCompletionModel

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
