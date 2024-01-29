import 'package:chatprj/clean_arcitecture/domain/entities/entities_message_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../manager/history_list_provider.dart';

class SendButton extends ConsumerWidget {
  final TextEditingController messageController;

  const SendButton({
    super.key,
    required this.messageController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      iconSize: 42,
      icon: const Icon(Icons.arrow_circle_up),
      onPressed: () async {
        if (messageController.text.isEmpty) {
          return;
        }
        final textToSend = messageController.text.trim();
        messageController.clear(); // 메시지 전송 후 입력 필드 초기화

        // 메시지 엔티티 추가
        ref.read(historyListProvider.notifier).addMessage(
              MessagesEntity(role: "user", content: textToSend),
            );

        // 서버에 메시지 전송하는 추가 로직
        try {
          // 예시: 서버 API 호출
          // await sendMessageToServer(textToSend);
        } catch (e) {
          // 오류 처리
          print("Error sending message: $e");
        }
      },
    );
  }
}
