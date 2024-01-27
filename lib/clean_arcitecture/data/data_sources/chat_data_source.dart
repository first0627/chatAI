// lib/data/data_sources/chat_data_source.dart
import 'dart:convert';

import 'package:chatprj/clean_arcitecture/data/data_sources/chat_message_data_source.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/chat_model.dart';
import '../models/data_message_model.dart';

class ChatDataSource {
  final apiKey = dotenv.env["API_KEY"];
  final ChatMessageDataSource chatMessageDataSource;

  ChatDataSource({required this.chatMessageDataSource});

  Future<void> requestChat(
      ChatCompletionModel model, String text, Messages messages) async {
    debugPrint("requestChat");
    final url = Uri.https("api.openai.com", "/v1/chat/completions");

    final response = await http.post(url,
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode(model.toJson()));

    await chatMessageDataSource.saveMessageToFirestore(messages);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
      String role = jsonData['choices'][0]['message']["role"];
      String content = jsonData['choices'][0]['message']["content"];
      print("role:" + role);

      await chatMessageDataSource
          .saveMessageToFirestore(Messages(role: role, content: content));
    } else {
      throw Exception("Failed to load chat data");
    }
  }
}
