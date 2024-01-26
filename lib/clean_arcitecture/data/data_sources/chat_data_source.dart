// lib/data/data_sources/chat_data_source.dart
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/chat_completion_model.dart';

class ChatDataSource {
  final apiKey = dotenv.env["API_KEY"];

  Future<ChatCompletionModel> requestChat(ChatCompletionModel model) async {
    final url = Uri.https("api.openai.com", "/v1/chat/completions");

    final response = await http.post(url,
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode(model.toJson()));

    if (response.statusCode == 200) {
      return ChatCompletionModel.fromJson(
        jsonDecode(utf8.decode(response.bodyBytes)),
      );
    } else {
      throw Exception("Failed to load chat data");
    }
  }
}
