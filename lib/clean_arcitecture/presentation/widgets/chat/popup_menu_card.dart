import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../route/router.dart';

class PopupMenuCard extends StatelessWidget {
  final VoidCallback onClearChat;

  const PopupMenuCard({
    super.key,
    required this.onClearChat,
  });

  Future<void> signOut() async {
    print("signOut");
    await FirebaseAuth.instance.signOut();

    router.push('/login');
  }

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
              onTap: signOut,
              // onTap: () => context.read(authProvider).signOut(),
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
