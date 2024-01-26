// lib/domain/repositories/chat_repository.dart

import 'package:chatprj/clean_arcitecture/domain/entities/entities_message_model.dart';

abstract class ChatMessageRepository {
  Future<void> saveMessageToFirestore(MessagesEntity message, String? userId);

  Future<void> loadMessages(String? userId);
}
