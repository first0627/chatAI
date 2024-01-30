import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../manager/history_list_provider.dart';

class MessageListView extends ConsumerStatefulWidget {
  MessageListView({super.key});

  @override
  _MessageListViewState createState() => _MessageListViewState();
}

class _MessageListViewState extends ConsumerState<MessageListView> {
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(historyListProvider);

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
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // CircleAvatar(
                            //   backgroundImage:
                            //       AssetImage('assets/images/user_profile.jpeg'),
                            // ),
                            SizedBox(width: 8),
                          ],
                        )
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.yellow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //const Text("User"),
                        Text(
                          message.content,
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                        ),
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
                backgroundImage: AssetImage('assets/images/gpt_profile.png'),
                backgroundColor: Colors.teal,
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("ChatGPT"),
                      Text(message.content),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
