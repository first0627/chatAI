import 'package:chatprj/clean_arcitecture/domain/entities/entities_chat_data_source.dart';
import 'package:chatprj/clean_arcitecture/domain/entities/entities_message_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../manager/history_list_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with TickerProviderStateMixin {
  TextEditingController messageTextController = TextEditingController();
  //final List<MessagesEntity> _historyList = List.empty(growable: true);

  final apiKey = dotenv.env["API_KEY"];

  String? userId = FirebaseAuth.instance.currentUser!.uid;

  String streamText = "";

  static const String _kStrings = "Test Flutter ChatGPT";

  String get _currentString => _kStrings;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setupAnimations();
    Future.microtask(() {
      ref.read(historyListProvider.notifier).clearMessages();
      ref.read(historyListProvider.notifier).addAll();
    });
  }

  ScrollController scrollController = ScrollController();
  late Animation<int> _characterCount;
  late AnimationController animationController;

  void scrollDown() {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 350),
      curve: Curves.fastOutSlowIn,
    );
  }

  setupAnimations() {
    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2500));
    _characterCount = StepTween(begin: 0, end: _currentString.length).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeIn,
      ),
    );
    animationController.addListener(() {
      setState(() {});
    });
    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(seconds: 1)).then((value) {
          animationController.reverse();
        });
      } else if (status == AnimationStatus.dismissed) {
        Future.delayed(const Duration(seconds: 1)).then(
          (value) => animationController.forward(),
        );
      }
    });

    animationController.forward();
  }

  @override
  void dispose() {
    messageTextController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  Future clearChat() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("새로운 대화의 시작"),
        content: const Text("신규 대화를 생성하시겠어요?"),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  messageTextController.clear();
                  ref.read(historyListProvider.notifier).clearMessages();
                });
              },
              child: const Text("네"))
        ],
      ),
    );
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Align(
                alignment: Alignment.centerRight,
                child: Card(
                  child: PopupMenuButton(
                    itemBuilder: (context) {
                      return [
                        const PopupMenuItem(
                          child: ListTile(
                            title: Text("히스토리"),
                          ),
                        ),
                        PopupMenuItem(
                          onTap: () {
                            clearChat();
                          },
                          child: const ListTile(
                            title: Text("새로운 채팅"),
                          ),
                        ),
                        PopupMenuItem(
                          onTap: () {
                            signOut();
                          },
                          child: ListTile(
                            title: Text("로그아웃"),
                          ),
                        ),
                      ];
                    },
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: ref.watch(historyListProvider).isEmpty
                      ? Center(
                          child: AnimatedBuilder(
                            animation: _characterCount,
                            builder: (BuildContext context, Widget? child) {
                              String text = _currentString.substring(
                                  0, _characterCount.value);
                              return Row(
                                children: [
                                  Text(
                                    text,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                    ),
                                  ),
                                  CircleAvatar(
                                    radius: 8,
                                    backgroundColor: Colors.orange[200],
                                  )
                                ],
                              );
                            },
                          ),
                        )
                      : GestureDetector(
                          onTap: () => FocusScope.of(context).unfocus(),
                          child: ListView.builder(
                            controller: scrollController,
                            itemCount: ref.watch(historyListProvider).length,
                            itemBuilder: (context, index) {
                              if (ref.watch(historyListProvider)[index].role ==
                                  "user") {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  child: Row(
                                    children: [
                                      const CircleAvatar(),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text("User"),
                                            Text(ref
                                                .read(
                                                    historyListProvider)[index]
                                                .content),
                                          ],
                                        ),
                                      )
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text("ChatGPT"),
                                      Text(ref
                                          .read(historyListProvider)[index]
                                          .content)
                                    ],
                                  ))
                                ],
                              );
                            },
                          ),
                        ),
                ),
              ),
              Dismissible(
                key: const Key("chat-bar"),
                direction: DismissDirection.startToEnd,
                onDismissed: (d) {
                  if (d == DismissDirection.startToEnd) {
                    // logic
                  }
                },
                background: const Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("New Chat"),
                  ],
                ),
                confirmDismiss: (d) async {
                  if (d == DismissDirection.startToEnd) {
                    //logic
                    if (ref.watch(historyListProvider).isEmpty) return;
                    clearChat();
                  }
                  return null;
                },
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(),
                        ),
                        child: TextField(
                          controller: messageTextController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Message",
                            fillColor: Colors.transparent,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      iconSize: 42,
                      onPressed: () async {
                        if (messageTextController.text.isEmpty) {
                          return;
                        }
                        var textToSend = messageTextController.text.trim();
                        messageTextController.clear(); // 메시지 전송 후 입력 필드 초기화

                        ref.read(historyListProvider.notifier).addMessage(
                              MessagesEntity(role: "user", content: textToSend),
                            );

                        ref.read(historyListProvider.notifier).addMessage(
                              MessagesEntity(role: "assistant", content: ""),
                            );

                        // setState(() {
                        //   _historyList.add(
                        //     MessagesEntity(role: "user", content: textToSend),
                        //   );
                        //   _historyList.add(
                        //       MessagesEntity(role: "assistant", content: ""));
                        // });

                        try {
                          await ref
                              .read(historyListProvider.notifier)
                              .requestChatH(
                                ChatDataSourceEntity(
                                    model: "gpt-3.5-turbo-1106",
                                    messages: [
                                      MessagesEntity(
                                        role: "system",
                                        content: "You are a helpful assistant.",
                                      ),
                                      ...ref.read(historyListProvider),
                                    ],
                                    stream: false),
                                textToSend,
                                MessagesEntity(
                                    role: "user", content: textToSend),
                              );
                        } catch (e) {
                          print("hello");
                          debugPrint(e.toString());
                        }
                      },
                      icon: const Icon(Icons.arrow_circle_up),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
