import 'package:chatprj/clean_arcitecture/presentation/manager/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/entities_message_model.dart';
import '../../domain/use_cases/chat_message_user_case.dart';

final historyListProvider =
    StateNotifierProvider<HistoryListNotifier, List<MessagesEntity>>((ref) {
  final chatUseCase = ref.watch(chatUseCaseProvider);
  return HistoryListNotifier(chatUseCase);
});

class HistoryListNotifier extends StateNotifier<List<MessagesEntity>> {
  final ChatUseCase chatUseCase;
  HistoryListNotifier(this.chatUseCase) : super(List.empty(growable: true));

  Future<void> addAll() async {
    try {
      final messages = await chatUseCase.loadMessages();
      state.addAll(messages);
    } catch (e) {
      print("add all error");
      print(e.toString());
    }
  }

  void addMessage(MessagesEntity message) {
    state = [...state, message];
  }

  void clearMessages() {
    state = List.empty(growable: true);
  }

// 필요한 경우 추가 메소드 구현
}
