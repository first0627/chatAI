import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/entities_chat_data_source.dart';
import '../../../domain/entities/entities_message_model.dart';
import '../../manager/history_list_provider.dart';

class CustomIconButton extends ConsumerStatefulWidget {
  final TextEditingController messageTextController;
  final ScrollController scrollController;

  const CustomIconButton({
    super.key,
    required this.messageTextController,
    required this.scrollController,
  });

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

        // 메시지를 추가한 후에 스크롤 위치를 업데이트
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          if (widget.scrollController.hasClients) {
            widget.scrollController.animateTo(
              widget.scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 200),
              curve: Curves.easeInOut,
            );
          }
        });

        ref.read(historyListProvider.notifier).addMessage(
              MessagesEntity(role: "assistant", content: ""),
            );

        try {
          await ref.read(historyListProvider.notifier).requestChatH(
                ChatDataSourceEntity(messages: [
                  MessagesEntity(
                    role: "system",
                    content:
                        "you role is a tour guild. you can ask me about the tour information",
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

        // 메시지를 추가한 후에 스크롤 위치를 업데이트
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          if (widget.scrollController.hasClients) {
            widget.scrollController.animateTo(
              widget.scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 200),
              curve: Curves.easeInOut,
            );
          }
        });
      },
      icon: const Icon(Icons.arrow_circle_up),
    );
  }
}
