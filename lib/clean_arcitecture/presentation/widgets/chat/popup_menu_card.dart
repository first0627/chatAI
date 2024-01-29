import 'package:flutter/material.dart';

class PopupMenuCard extends StatelessWidget {
  final VoidCallback onClearChat;
  final VoidCallback onSignOut;

  const PopupMenuCard({
    Key? key,
    required this.onClearChat,
    required this.onSignOut,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: PopupMenuButton(
        itemBuilder: (context) {
          return [
            const PopupMenuItem(
              child: ListTile(
                title: Text("히스토리"),
              ),
            ),
            PopupMenuItem(
              onTap: onClearChat,
              child: const ListTile(
                title: Text("새로운 채팅"),
              ),
            ),
            PopupMenuItem(
              onTap: onSignOut,
              child: const ListTile(
                title: Text("로그아웃"),
              ),
            ),
          ];
        },
      ),
    );
  }
}
