import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final scrollControllerProvider =
    StateNotifierProvider<ScrollControllerStateNotifier, ScrollController>(
  (ref) => ScrollControllerStateNotifier(),
);

class ScrollControllerStateNotifier extends StateNotifier<ScrollController> {
  ScrollControllerStateNotifier() : super(ScrollController());

  // scrollToBottom 메서드
  void scrollToBottom() {
    print("Dddddddddddddd");
    if (state.hasClients) {
      print("Ddddffffffffffff");
      state.animateTo(
        state.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    state.dispose();
    super.dispose();
  }
}
