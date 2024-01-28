import 'dart:convert';

import 'package:chatprj/clean_arcitecture/data/data_sources/chat_message_data_source.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/chat_model.dart';
import '../models/data_message_model.dart';

class ChatDataSource {
  final apiKey = dotenv.env["API_KEY"];
  final ChatMessageDataSource chatMessageDataSource;

  ChatDataSource({required this.chatMessageDataSource});

  Future<Messages> requestChat(
      ChatCompletionModel model, String text, Messages messages) async {
    try {
      final response = await _sendChatRequest(model);
      await _saveMessageToFirestore(messages);
      return _processResponse(response);
    } catch (e) {
      print("Chat request failed: $e");
      rethrow;
    }
  }

  Future<http.Response> _sendChatRequest(ChatCompletionModel model) async {
    try {
      final url = Uri.https("api.openai.com", "/v1/chat/completions");
      return await http.post(url,
          headers: {
            "Authorization": "Bearer $apiKey",
            "Content-Type": "application/json",
          },
          body: jsonEncode(model.toJson()));
    } catch (e) {
      if (kDebugMode) {
        print("Failed to send chat request: $e");
      }
      rethrow;
    }
  }

  Future<void> _saveMessageToFirestore(Messages messages) async {
    try {
      await chatMessageDataSource.saveMessageToFirestore(messages);
    } catch (e) {
      print("Failed to save message to Firestore: $e");
      rethrow;
    }
  }

  Messages _processResponse(http.Response response) {
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
      String role = jsonData['choices'][0]['message']["role"];
      String content = jsonData['choices'][0]['message']["content"];
      return Messages(role: role, content: content);
    } else {
      throw Exception("Failed to load chat data: ${response.statusCode}");
    }
  }
}
