import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

import '../../data/models/chat_completion_model.dart';
import '../../data/models/messages.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
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
      print("flag1");
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
      print("flag2");
      final url = Uri.https("api.openai.com", "/v1/chat/completions");
      print("flag3");
      final resp = await http.post(url,
          headers: {
            "Authorization": "Bearer $apiKey",
            "Content-Type": "application/json",
          },
          body: jsonEncode(openAiModel.toJson()));

      print("응답 데이터: ${resp.body.substring(0, min(100, resp.body.length))}");

      await saveMessageToFirestore(Messages(role: "user", content: text));

      if (resp.statusCode == 200) {
        final jsonData = jsonDecode(utf8.decode(resp.bodyBytes)) as Map;
        String role = jsonData["choices"][0]["message"]["role"];
        String content = jsonData["choices"][0]["message"]["content"];

        await saveMessageToFirestore(Messages(role: role, content: content));

        _historyList.last = _historyList.last.copyWith(
          role: role,
          content: content,
        );
        setState(() {
          _scrollDown();
        });

        print("API 응답 에러: ${resp.statusCode}");
        print("응답 내용: ${resp.body}");
      } else {
        print("JSON 파싱 에러: $e");
        print("응답 데이터: ${resp.body}");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Stream requestChatStream(String text) async* {
    print("flag11");
    ChatCompletionModel openAiModel = ChatCompletionModel(
        model: "gpt-3.5-turbo-1106",
        messages: [
          Messages(
            role: "system",
            content: "You are a helpful assistant.",
          ),
          ..._historyList,
        ],
        stream: true);

    final url = Uri.https("api.openai.com", "/v1/chat/completions");
    final request = http.Request("POST", url)
      ..headers.addAll(
        {
          "Authorization": "Bearer $apiKey",
          "Content-Type": 'application/json; charset=UTF-8',
          "Connection": "keep-alive",
          "Accept": "*/*",
          "Accept-Encoding": "gzip, deflate, br",
        },
      );

    request.body = jsonEncode(openAiModel.toJson());
    print("흥");
    print(request.body);
    final resp = await http.Client().send(request);
    print(resp.toString());
    print("aa");
    final byteStream = resp.stream.asyncExpand(
      (event) => Rx.timer(
        event,
        const Duration(milliseconds: 50),
      ),
    );
    final statusCode = resp.statusCode;
    print(statusCode);
    print("cc");
    var respText = "";
    print("bb");
    await for (final byte in byteStream) {
      var decoded = utf8.decode(byte, allowMalformed: false);
      respText += decoded;

      while (respText.contains("\n")) {
        var endOfJsonIndex = respText.indexOf("\n");
        var jsonResponseText = respText.substring(0, endOfJsonIndex);

        // 'data: ' 접두어를 제거합니다.
        var jsonStartIndex = jsonResponseText.indexOf('{');
        if (jsonStartIndex != -1) {
          jsonResponseText = jsonResponseText.substring(jsonStartIndex);
          try {
            final jsonResponse =
                jsonDecode(jsonResponseText) as Map<String, dynamic>;
            final content = jsonResponse["choices"][0]["delta"]["content"];
            if (content != null) {
              print("엉");
              // TODO: 응답 처리
            }
          } catch (e) {
            print("JSON 파싱 중 에러 발생: $e");
          }
        }

        // 다음 메시지 처리를 위해 respText 업데이트
        respText = respText.substring(endOfJsonIndex + 1);
      }
    }

    print("Aa");
    await saveMessageToFirestore(Messages(role: "user", content: text));
    if (respText.isNotEmpty) {
      setState(() {});
      await saveMessageToFirestore(
          Messages(role: "assistant", content: respText));
    }
  }

  Future<void> loadMessages() async {
    if (userId == null) {
      print("loadMessages: userId is null");
      return;
    }
    print("loadMessages: Loading messages for userId: $userId");

    var userDoc = FirebaseFirestore.instance.collection('chats').doc(userId);
    var collection = userDoc.collection('messages');
    var querySnapshot =
        await collection.orderBy('timestamp', descending: true).get();

    print("loadMessages: Found ${querySnapshot.docs.length} messages");
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

  Future<List<Messages>> loadMessagesFromFirestore() async {
    if (userId == null) return [];

    // Firestore 쿼리 경로 수정
    var userDoc = FirebaseFirestore.instance.collection('chats').doc(userId);
    var collection = userDoc.collection('messages'); // 사용자별 메시지가 저장된 서브컬렉션
    var querySnapshot =
        await collection.orderBy('timestamp', descending: true).get();

    return querySnapshot.docs.map((doc) {
      return Messages(
        role: doc['role'],
        content: doc['content'],
      );
    }).toList();
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
