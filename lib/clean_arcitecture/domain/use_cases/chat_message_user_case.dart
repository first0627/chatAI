// lib/domainLayer/use_cases/chat_use_case.dart

import 'package:chatprj/clean_arcitecture/domain/entities/entities_message_model.dart';

import '../repositories/chat_messages_repository_domain.dart';

class ChatUseCase {
  final ChatMessageRepository repository;

  ChatUseCase(this.repository);

  Future<void> saveMessageToFirestore(MessagesEntity message) {
    return repository.saveMessageToFirestore(message);
  }

  Future<List<MessagesEntity>> loadMessages() {
    return repository.loadMessages();
  }
}
