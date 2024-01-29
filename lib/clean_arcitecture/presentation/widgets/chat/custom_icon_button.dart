import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/entities_chat_data_source.dart';
import '../../../domain/entities/entities_message_model.dart';
import '../../manager/history_list_provider.dart';

class CustomIconButton extends ConsumerStatefulWidget {
  final TextEditingController messageTextController;

  const CustomIconButton({
    Key? key,
    required this.messageTextController,
  }) : super(key: key);

  @override
  _CustomIconButtonState createState() => _CustomIconButtonState();
}

class _CustomIconButtonState extends ConsumerState<CustomIconButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: 42,
      onPressed: () async {
        if (widget.messageTextController.text.isEmpty) {
          return;
        }
        var textToSend = widget.messageTextController.text.trim();
        widget.messageTextController.clear(); // 메시지 전송 후 입력 필드 초기화

        ref.read(historyListProvider.notifier).addMessage(
              MessagesEntity(role: "user", content: textToSend),
            );

        ref.read(historyListProvider.notifier).addMessage(
              MessagesEntity(role: "assistant", content: ""),
            );

        try {
          await ref.read(historyListProvider.notifier).requestChatH(
                ChatDataSourceEntity(messages: [
                  MessagesEntity(
                    role: "system",
                    content: "You are a helpful assistant.",
                  ),
                  ...ref.read(historyListProvider),
                ], stream: false),
                textToSend,
                MessagesEntity(role: "user", content: textToSend),
              );
        } catch (e) {
          print("hello");
          debugPrint(e.toString());
        }
      },
      icon: const Icon(Icons.arrow_circle_up),
    );
  }
}
