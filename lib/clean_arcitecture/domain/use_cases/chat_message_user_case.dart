// lib/domainLayer/use_cases/chat_use_case.dart

import 'package:chatprj/clean_arcitecture/domain/entities/entities_message_model.dart';

import '../repositories/chat_messages_repository_domain.dart';

class ChatUseCase {
  final ChatMessageRepository repository;

  ChatUseCase(this.repository);

  Future<void> saveMessageToFirestore(MessagesEntity message, String? userId) {
    return repository.saveMessageToFirestore(message, userId);
  }

  Future<void> loadMessages(String? userId) {
    return repository.loadMessages(userId);
  }
}
