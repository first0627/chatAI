import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/data_sources/chat_message_data_source.dart';
import '../../data/repository/chat_message_repository.dart';
import '../../domain/use_cases/chat_message_user_case.dart';
import '../../domain/use_cases/get_chat_response.dart';
import 'chat_repository_provider.dart';

final requestChatProvider = Provider<RequestChat>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return RequestChat(repository);
});

final chatUseCaseProvider = Provider<ChatUseCase>((ref) {
  final chatRepository = ref.watch(chatMessageRepositoryProvider);
  return ChatUseCase(chatRepository);
});

final chatMessageRepositoryProvider =
    Provider<ChatMessageRepositoryImpl>((ref) {
  final dataSource = ref.watch(chatMessageDataSourceProvider);
  return ChatMessageRepositoryImpl(dataSource);
});

// lib/clean_arcitecture/presentation/manager/provider.dart

final chatMessageDataSourceProvider = Provider<ChatMessageDataSource>((ref) {
  return ChatMessageDataSource();
});

// lib/clean_arcitecture/presentation/manager/provider.dart
