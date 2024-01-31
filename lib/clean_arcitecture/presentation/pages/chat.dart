import 'package:chatprj/clean_arcitecture/presentation/widgets/chat/message_list_gesture_detector.dart';
import 'package:chatprj/clean_arcitecture/presentation/widgets/chat/popup_menu_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../manager/history_list_provider.dart';
import '../manager/scroll_controller.dart';
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

  static const String _kStrings = "Test Flutter ChatGPT";

  String get _currentString => _kStrings;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setupAnimations();
    final scrollController = ref.read(scrollControllerProvider);
    Future.microtask(() {
      ref.read(historyListProvider.notifier).clearMessages();
      ref.read(historyListProvider.notifier).addAll();
      Future.delayed(Duration(milliseconds: 3000), () {
        ref.read(scrollControllerProvider.notifier).scrollToBottom();
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
    final scrollController = ref.watch(scrollControllerProvider);
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: ref.watch(historyListProvider).isEmpty
                      ? Center(
                          child: AnimatedTextBuilder(
                            characterCount: _characterCount,
                            text: _currentString,
                          ),
                        )
                      : MessageListView(
                          scrollController: scrollController,
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
