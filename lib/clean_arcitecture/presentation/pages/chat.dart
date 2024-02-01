import 'package:chatprj/clean_arcitecture/presentation/widgets/chat/message_list_gesture_detector.dart';
import 'package:chatprj/clean_arcitecture/presentation/widgets/chat/popup_menu_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../manager/history_list_provider.dart';
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

  String get _currentString => _kStrings;
  late Future<void> loadMessagesFuture;

  bool isFirstLoadComplete = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setupAnimations();

    Future.microtask(() async {
      ref.read(historyListProvider.notifier).clearMessages();

      await ref.read(historyListProvider.notifier).addAll();
    });

    loadMessagesFuture = ref.read(historyListProvider.notifier).addAll();
    loadMessagesFuture.then((_) {
      setState(() {
        isFirstLoadComplete = true; // 첫 로딩이 완료되면 상태 업데이트
      });
    });
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
      body: SafeArea(
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
                child: FutureBuilder(
                  future: loadMessagesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (isFirstLoadComplete && scrollController.hasClients) {
                        // 처음 로드될 때 한 번만 스크롤 이동
                        scrollController
                            .jumpTo(scrollController.position.maxScrollExtent);
                        isFirstLoadComplete = false; // 다음 로드 때 스크롤 이동 방지
                      }
                      return MessageListView(
                          scrollController: scrollController);
                    } else {
                      return CircularProgressIndicator();
                    }
                  },
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
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
