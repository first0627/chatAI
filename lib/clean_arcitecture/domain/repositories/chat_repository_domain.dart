// lib/domain/repositories/chat_repository.dart

import 'package:chatprj/clean_arcitecture/domain/entities/entities_message_model.dart';

import '../entities/entities_chat_data_source.dart';

abstract class ChatRepository {
  Future<MessagesEntity> requestChat(
      ChatDataSourceEntity model, String text, MessagesEntity messagesEntity);
}
