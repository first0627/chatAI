import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/chat_model.dart';
import '../models/data_message_model.dart';
import 'chat_message_data_source.dart';

class ChatDataSource {
  final apiKey = dotenv.env["API_KEY"];
  final ChatMessageDataSource chatMessageDataSource;

  ChatDataSource({required this.chatMessageDataSource});

  Future<Messages> requestChat(
      ChatCompletionModel model, String text, Messages messages) async {
    debugPrint("requestChat");

    final response = await sendApiRequest(model);

    await saveMessage(messages);
    await saveResponseAsMessage(response);

    return response;
  }

  Future<Messages> sendApiRequest(ChatCompletionModel model) async {
    final url = Uri.https("api.openai.com", "/v1/chat/completions");
    final response = await http.post(url,
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode(model.toJson()));
    print(model.toJson());
    print("sssssssssssssssssssssssssssssssssssssss");

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
      print(jsonData);
      String role = jsonData['choices'][0]['message']["role"];
      String content = jsonData['choices'][0]['message']["content"];
      print("role:$role");

      return Messages(role: role, content: content);
    } else {
      throw Exception("Failed to load chat data");
    }
  }

  Future<void> saveMessage(Messages messages) async {
    await chatMessageDataSource.saveMessageToFirestore(messages);
  }

  Future<void> saveResponseAsMessage(Messages response) async {
    await chatMessageDataSource.saveMessageToFirestore(response);
  }
}
