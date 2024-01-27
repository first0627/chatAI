import 'package:chatprj/clean_arcitecture/presentation/manager/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/data_sources/chat_data_source.dart';

final chatDataSourceProvider = Provider<ChatDataSource>((ref) {
  final dataSource = ref.watch(chatMessageDataSourceProvider);
  return ChatDataSource(chatMessageDataSource: dataSource);
});
