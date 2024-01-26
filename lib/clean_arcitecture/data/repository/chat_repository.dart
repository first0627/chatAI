import '../../domain/repositories/chat_repository_domain.dart';
import '../data_sources/chat_data_source.dart';
import '../models/chat_completion_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatDataSource dataSource;

  ChatRepositoryImpl(this.dataSource);

  Future<void> requestChat(ChatCompletionModel model, String text) {
    return dataSource.requestChat(model);
  }
}
