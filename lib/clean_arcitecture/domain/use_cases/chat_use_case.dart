import '../entities/entities_chat_data_source.dart';
import '../entities/entities_message_model.dart';
import '../repositories/chat_repository_domain.dart';

class RequestChat {
  final ChatRepository repository;

  RequestChat(this.repository);

  Future<void> requestChat(
      ChatDataSourceEntity model, String text, MessagesEntity messagesEntity) {
    return repository.requestChat(model, text, messagesEntity);
  }
}
