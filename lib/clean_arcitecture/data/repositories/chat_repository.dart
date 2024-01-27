import 'package:chatprj/clean_arcitecture/domain/entities/entities_chat_data_source.dart';
import 'package:chatprj/clean_arcitecture/domain/entities/entities_message_model.dart';

import '../../domain/repositories/chat_repository_domain.dart';
import '../data_sources/chat_data_source.dart';
import '../models/chat_model.dart';
import '../models/data_message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatDataSource dataSource;

  ChatRepositoryImpl(this.dataSource);

  @override
  Future<void> requestChat(
      ChatDataSourceEntity model, String text, MessagesEntity messagesEntity) {
    final modelTran = ChatCompletionModel.fromEntity(model);
    final messagesTran = Messages.fromEntity(messagesEntity);

    return dataSource.requestChat(modelTran, text, messagesTran);
  }
}
