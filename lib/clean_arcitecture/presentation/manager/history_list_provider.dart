import 'package:chatprj/clean_arcitecture/presentation/manager/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/entities_chat_data_source.dart';
import '../../domain/entities/entities_message_model.dart';
import '../../domain/use_cases/chat_message_user_case.dart';
import '../../domain/use_cases/chat_use_case.dart';

final historyListProvider =
    StateNotifierProvider<HistoryListNotifier, List<MessagesEntity>>((ref) {
  final chatUseCase = ref.watch(chatUseCaseProvider);
  final requestChat = ref.watch(requestChatProvider);

  return HistoryListNotifier(
    chatUseCase: chatUseCase,
    requestChat: requestChat,
  );
});

class HistoryListNotifier extends StateNotifier<List<MessagesEntity>> {
  final ChatUseCase chatUseCase;

  final RequestChat requestChat;

  HistoryListNotifier({
    required this.chatUseCase,
    required this.requestChat,
  }) : super(List.empty(growable: true));

  Future<void> addAll() async {
    try {
      final messages = await chatUseCase.loadMessages();
      state.addAll(messages);
    } catch (e) {
      print("add all error");
      print(e.toString());
    }
  }

  Future<void> requestChatH(
    ChatDataSourceEntity model,
    String text,
    MessagesEntity messagesEntity,
  ) async {
    try {
      final messages =
          await requestChat.requestChat(model, text, messagesEntity);
      state.last = state.last.copyWith(
        role: messages.role,
        content: messages.content,
      );
    } catch (e) {
      print("add all error");
      print(e.toString());
    }
  }

  void addMessage(MessagesEntity message) {
    state = [
      ...state,
      message,
    ];
  }

  void clearMessages() {
    state = List.empty(growable: true);
  }
}
