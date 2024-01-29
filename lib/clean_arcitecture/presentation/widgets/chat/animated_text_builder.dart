import 'package:flutter/material.dart';

class AnimatedTextBuilder extends StatelessWidget {
  final Animation<int> characterCount;
  final String text;

  const AnimatedTextBuilder({
    super.key,
    required this.characterCount,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: characterCount,
      builder: (BuildContext context, Widget? child) {
        String displayedText = text.substring(0, characterCount.value);
        return Row(
          children: [
            Text(
              displayedText,
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
    );
  }
}
