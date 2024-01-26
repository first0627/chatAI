import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/data_sources/chat_data_source.dart';

final chatDataSourceProvider = Provider<ChatDataSource>((ref) {
  return ChatDataSource();
});
