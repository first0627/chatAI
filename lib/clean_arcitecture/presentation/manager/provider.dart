// 애니메이션 관련 상태 관리
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/messages.dart';

final messageHistoryProvider = StateProvider<List<Messages>>((ref) => []);

final streamTextProvider = StateProvider<String>((ref) => "");

// 기타 필요한 상태에 대한 프로바이더 추가...

// 애니메이션 관련 상태 관리
final animationControllerProvider =
    StateProvider<AnimationController?>((ref) => null);
final characterCountProvider = StateProvider<int>((ref) => 0);

// OpenAI API 키 상태 관리
final apiKeyProvider = StateProvider<String?>((ref) => dotenv.env["API_KEY"]);

// 테스트용 문자열 상태 관리
final testStringProvider =
    StateProvider<String>((ref) => "Test Flutter ChatGPT");
