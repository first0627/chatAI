import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/chat_repository.dart';
import '../../domain/repositories/chat_repository_domain.dart';
import 'chat_data_soruce_provider.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final dataSource = ref.watch(chatDataSourceProvider);
  return ChatRepositoryImpl(dataSource);
});
