import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../manager/history_list_provider.dart';

class MessageListView extends ConsumerWidget {
  const MessageListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(historyListProvider);
    final ScrollController scrollController = ScrollController();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: ListView.builder(
        controller: scrollController,
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          if (message.role == "user") {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  const CircleAvatar(),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(message.role == "user" ? "User" : "ChatGPT"),
                        Text(message.content),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                backgroundColor: Colors.teal,
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("ChatGPT"),
                  Text(messages[index].content)
                ],
              ))
            ],
          );
        },
      ),
    );
  }
}
