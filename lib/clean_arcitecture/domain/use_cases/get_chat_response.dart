// lib/domain/use_cases/request_chat.dart

import '../../data/models/chat_completion_model.dart';
import '../repositories/chat_repository_domain.dart';

class RequestChat {
  final ChatRepository repository;

  RequestChat(this.repository);

  Future<void> requestChat(ChatCompletionModel model, String text) {
    return repository.requestChat(model, text);
  }
}
