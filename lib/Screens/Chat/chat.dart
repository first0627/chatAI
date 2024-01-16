import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  TextEditingController messageTextontroller = TextEditingController();
  ScrollController scrollController = ScrollController();

  static const String _kStrings = "FastCampus Flutter ChatGPT";

  String get _currentString => _kStrings;

  late Animation<int> _characterCount;
  late AnimationController animationController;

  setupAnimations() {
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2500),
    );
    _characterCount = StepTween(
      begin: 0,
      end: _currentString.length,
    ).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeIn),
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
        Future.delayed(const Duration(seconds: 1)).then((value) {
          animationController.forward();
        });
      }
    });

    animationController.forward();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setupAnimations();
  }

  @override
  void dispose() {
    messageTextontroller.dispose();
    scrollController.dispose();
    super.dispose();
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
                            title: Text('히스토리'),
                          ),
                        ),
                        const PopupMenuItem(
                          child: ListTile(
                            title: Text('설정'),
                          ),
                        ),
                        const PopupMenuItem(
                          child: ListTile(
                            title: Text('새로운 채팅'),
                          ),
                        ),
                      ];
                    },
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: AnimatedBuilder(
                        animation: _characterCount,
                        builder: (BuildContext context, Widget? child) {
                          String text = _currentString.substring(
                              0, _characterCount.value);
                          return Row(
                            children: [
                              Text(
                                "${text}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              CircleAvatar(
                                radius: 8,
                                backgroundColor: Colors.orange[200],
                              )
                            ],
                          );
                        }
                        // child: ListView.builder(
                        //   itemCount: 100,
                        //   itemBuilder: (context, index) {
                        //     if (index % 2 == 0) {
                        //       return const Padding(
                        //         padding: EdgeInsets.all(16.0),
                        //         child: Row(
                        //           children: [
                        //             CircleAvatar(),
                        //             SizedBox(
                        //               width: 8,
                        //             ),
                        //             Expanded(
                        //               child: Column(
                        //                 crossAxisAlignment: CrossAxisAlignment.start,
                        //                 children: [
                        //                   Text("User Name"),
                        //                   Text("Message"),
                        //                 ],
                        //               ),
                        //             ),
                        //           ],
                        //         ),
                        //       );
                        //     }
                        //     return const Row(
                        //       children: [
                        //         CircleAvatar(
                        //           backgroundColor: Colors.teal,
                        //         ),
                        //         SizedBox(
                        //           width: 8,
                        //         ),
                        //         Expanded(
                        //             child: Column(
                        //           crossAxisAlignment: CrossAxisAlignment.start,
                        //           children: [
                        //             Text("ChatGpt"),
                        //             Text("OpenAI OpenAI OpenAI OpenAI"),
                        //           ],
                        //         ))
                        //       ],
                        //     );
                        //   },
                        // ),
                        ),
                  ),
                ),
              ),
              Dismissible(
                key: const Key('chat'),
                direction: DismissDirection.startToEnd,
                onDismissed: (d) {
                  if (d == DismissDirection.startToEnd) {}
                },
                background: const Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("New Chat"),
                  ],
                ),
                confirmDismiss: (d) async {
                  if (d == DismissDirection.startToEnd) {}
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
                          controller: messageTextontroller,
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
                      onPressed: () {},
                      icon: const Icon(Icons.arrow_circle_up),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
