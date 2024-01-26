import 'dart:convert';

import 'package:chatprj/clean_arcitecture/domain/entities/entities_message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../data/models/chat_completion_model.dart';
import '../../data/models/data_message_model.dart';
import '../manager/provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with TickerProviderStateMixin {
  TextEditingController messageTextController = TextEditingController();
  final List<Messages> _historyList = List.empty(growable: true);

  final apiKey = dotenv.env["API_KEY"];

  String? userId;

  String streamText = "";

  static const String _kStrings = "Test Flutter ChatGPT";

  String get _currentString => _kStrings;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setupAnimations();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        setState(() {
          userId = null;
        });
      } else {
        setState(() {
          userId = user.uid;
          loadMessages();
        });
      }
    });
  }

  ScrollController scrollController = ScrollController();
  late Animation<int> _characterCount;
  late AnimationController animationController;

  void _scrollDown() {
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

  Future requestChat(String text) async {
    try {
      ChatCompletionModel openAiModel = ChatCompletionModel(
        model: "gpt-3.5-turbo-1106",
        messages: [
          Messages(
            role: "system",
            content: "You are a helpful assistant.",
          ),
          ..._historyList,
        ],
        stream: false,
      );

      final url = Uri.https("api.openai.com", "/v1/chat/completions");

      final resp = await http.post(url,
          headers: {
            "Authorization": "Bearer $apiKey",
            "Content-Type": "application/json",
          },
          body: jsonEncode(openAiModel.toJson()));

      ref.read(chatUseCaseProvider).saveMessageToFirestore(
          MessagesEntity(role: "user", content: text), userId);

      //await saveMessageToFirestore(Messages(role: "user", content: text));

      if (resp.statusCode == 200) {
        final jsonData = jsonDecode(utf8.decode(resp.bodyBytes)) as Map;
        String role = jsonData["choices"][0]["message"]["role"];
        String content = jsonData["choices"][0]["message"]["content"];

        ref.read(chatUseCaseProvider).saveMessageToFirestore(
            MessagesEntity(role: "user", content: text), userId);

        _historyList.last = _historyList.last.copyWith(
          role: role,
          content: content,
        );

        setState(() {
          _scrollDown();
        });
      } else {}
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> loadMessages() async {
    if (userId == null) {
      print("loadMessages: userId is null");
      return;
    }

    var userDoc = FirebaseFirestore.instance.collection('chats').doc(userId);
    var collection = userDoc.collection('messages');
    var querySnapshot =
        await collection.orderBy('timestamp', descending: true).get();

    setState(() {
      _historyList.clear();
      _historyList.addAll(querySnapshot.docs
          .map((doc) {
            return Messages(
              role: doc['role'],
              content: doc['content'],
            );
          })
          .toList()
          .reversed);
    });
  }

  // Firestore에서 사용자별로 메시지를 저장하는 예시
  Future<void> saveMessageToFirestore(Messages message) async {
    if (userId != null) {
      var docRef = FirebaseFirestore.instance
          .collection('chats')
          .doc(userId)
          .collection('messages');

      await docRef.add({
        'role': message.role,
        'content': message.content,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } else {
      print("유저 ID가 null입니다.");
    }
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
                  _historyList.clear();
                });
              },
              child: const Text("네"))
        ],
      ),
    );
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
                        const PopupMenuItem(
                          child: ListTile(
                            title: Text("설정"),
                          ),
                        ),
                        PopupMenuItem(
                          onTap: () {
                            clearChat();
                          },
                          child: const ListTile(
                            title: Text("새로운 채팅"),
                          ),
                        )
                      ];
                    },
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: _historyList.isEmpty
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
                            itemCount: _historyList.length,
                            itemBuilder: (context, index) {
                              if (_historyList[index].role == "user") {
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
                                            Text(_historyList[index].content),
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
                                      Text(_historyList[index].content)
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
                    if (_historyList.isEmpty) return;
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

                        setState(() {
                          _historyList.add(
                            Messages(role: "user", content: textToSend),
                          );
                          _historyList
                              .add(Messages(role: "assistant", content: ""));
                        });

                        try {
                          await requestChat(
                              textToSend); // 중복 전송 방지를 위해 입력 필드 초기화 후 호출
                        } catch (e) {
                          print(e.toString());
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
