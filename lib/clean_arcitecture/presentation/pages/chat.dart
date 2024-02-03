import 'package:chatprj/clean_arcitecture/presentation/widgets/chat/popup_menu_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../manager/history_list_provider.dart';
import '../widgets/chat/animated_text_builder.dart';
import '../widgets/chat/custom_icon_button.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with TickerProviderStateMixin {
  TextEditingController messageTextController = TextEditingController();
  ScrollController scrollController = ScrollController();
  static const String _kStrings = "Test Flutter ChatGPT";
  bool isLoading = true;
  String get _currentString => _kStrings;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setupAnimations();
    Future.microtask(() => loadMessages());
  }

  void loadMessages() async {
    ref.read(historyListProvider.notifier).clearMessages();
    await ref.read(historyListProvider.notifier).addAll();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => scrollToBottom()); // 프레임이 렌더링된 후에 스크롤을 내림
  }

  void scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController
          .animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          )
          .then((_) => setState(() {
                isLoading = false; // 스크롤 완료 후 로딩 상태 업데이트
              }));
    } else {
      setState(() => isLoading = false); // 스크롤 대상이 없는 경우 바로 로딩 상태 업데이트
    }
  }

  late Animation<int> _characterCount;
  late AnimationController animationController;

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
    // scrollController.dispose();
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

                messageTextController.clear();
                ref.read(historyListProvider.notifier).clearMessages();
              },
              child: const Text("네"))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(historyListProvider);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // 로딩 인디케이터
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.centerRight,
                      child: PopupMenuCard(
                        onClearChat: clearChat,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: messages.isEmpty
                            ? Center(
                                child: AnimatedTextBuilder(
                                  characterCount: _characterCount,
                                  text: _currentString,
                                ),
                              )
                            : GestureDetector(
                                onTap: () {
                                  FocusScope.of(context).unfocus();
                                },
                                child: ListView.builder(
                                  reverse: true,
                                  controller: scrollController,
                                  itemCount: messages.length,
                                  itemBuilder: (context, index) {
                                    final message = messages[index];

                                    if (message.role == "user") {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            ConstrainedBox(
                                              constraints: BoxConstraints(
                                                // 화면 너비의 최대 80%까지만 메시지가 차지하도록 제한
                                                maxWidth: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.7,
                                              ),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                  color: Colors.yellow,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  message.content,
                                                  softWrap: true, // 자동 줄바꿈 활성화
                                                  style: const TextStyle(
                                                      color: Colors.black),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                    return Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const CircleAvatar(
                                          backgroundImage: AssetImage(
                                              'assets/images/gpt_profile.png'),
                                          backgroundColor: Colors.teal,
                                        ),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        ConstrainedBox(
                                          constraints: BoxConstraints(
                                            // 화면 너비의 최대 80%까지만 메시지가 차지하도록 제한
                                            maxWidth: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.7,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: Colors.white10,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
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
                          if (messages.isEmpty) return;
                          clearChat();
                        }
                        return null;
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white10,
                                  borderRadius: BorderRadius.circular(32),
                                  border: Border.all(),
                                ),
                                child: TextField(
                                  cursorColor: Colors.white,
                                  controller: messageTextController,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "상담 내용을 입력하세요.",
                                    hintStyle: TextStyle(color: Colors.grey),
                                    fillColor: Colors.transparent,
                                  ),
                                ),
                              ),
                            ),
                            CustomIconButton(
                              scrollController: scrollController,
                              messageTextController: messageTextController,
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
