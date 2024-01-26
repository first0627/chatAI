import 'package:chatprj/clean_arcitecture/domain/entities/entities_message_model.dart';

import '../../domain/repositories/chat_messages_repository_domain.dart';
import '../data_sources/chat_message_data_source.dart';
import '../models/data_message_model.dart';

class ChatMessageRepositoryImpl implements ChatMessageRepository {
  final ChatMessageDataSource dataSource;

  ChatMessageRepositoryImpl(this.dataSource);

  @override
  Future<void> saveMessageToFirestore(
      MessagesEntity message, String? userId) async {
    final message_tran = Messages.fromEntity(message);

    dataSource.saveMessageToFirestore(message_tran, userId);
  }

  @override
  Future<void> loadMessages(String? userid) async {
    dataSource.loadMessagesFromFirestore(userid);
  }
}
