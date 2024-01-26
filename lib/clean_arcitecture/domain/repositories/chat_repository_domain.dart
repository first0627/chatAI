// lib/domain/repositories/chat_repository.dart

import '../../data/models/chat_completion_model.dart';

abstract class ChatRepository {
  Future<void> requestChat(ChatCompletionModel model, String text);
}
