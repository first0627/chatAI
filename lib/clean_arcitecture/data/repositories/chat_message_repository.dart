import 'package:chatprj/clean_arcitecture/domain/entities/entities_message_model.dart';

import '../../domain/repositories/chat_messages_repository_domain.dart';
import '../data_sources/chat_message_data_source.dart';
import '../models/data_message_model.dart';

class ChatMessageRepositoryImpl implements ChatMessageRepository {
  final ChatMessageDataSource dataSource;

  ChatMessageRepositoryImpl(this.dataSource);

  @override
  Future<void> saveMessageToFirestore(MessagesEntity message) async {
    final messageTran = Messages.fromEntity(message);

    dataSource.saveMessageToFirestore(messageTran);
  }

  @override
  Future<List<MessagesEntity>> loadMessages() async {
    final messages = await dataSource.loadMessagesFromFirestore();

    return messages.map((message) => message.toEntity()).toList();
  }
}
