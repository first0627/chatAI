import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../manager/history_list_provider.dart';

class MessageListView extends ConsumerStatefulWidget {
  final ScrollController scrollController;

  MessageListView({required this.scrollController, Key? key}) : super(key: key);

  @override
  _MessageListViewState createState() => _MessageListViewState();
}

class _MessageListViewState extends ConsumerState<MessageListView> {
  @override
  void initState() {
    super.initState();
    //   widget.scrollController.addListener(listner);
    /*
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (widget.scrollController.hasClients) {
        widget.scrollController
            .jumpTo(widget.scrollController.position.maxScrollExtent);
      }
    });*/
  }

  void listner() {
    if (widget.scrollController.position.atEdge) {
      if (widget.scrollController.position.pixels != 0) {
        // 스크롤이 가장 아래에 도달했을 때
        // 새로운 메시지가 추가되면 스크롤을 아래로 이동
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (widget.scrollController.hasClients) {
            widget.scrollController
                .jumpTo(widget.scrollController.position.maxScrollExtent);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(historyListProvider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: ListView.builder(
        controller: widget.scrollController,
        itemCount: messages.length,
        itemBuilder: (context, index) {
          if (messages.length > 0) {
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              widget.scrollController.animateTo(
                widget.scrollController.position.maxScrollExtent,
                duration: Duration(milliseconds: 200),
                curve: Curves.easeInOut,
              );
            });
          }

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
