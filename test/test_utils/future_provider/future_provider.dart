import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../async_notifier/async_counter.dart';

part 'future_provider.g.dart';

@riverpod
Future<bool> isAsyncCounterOdd(IsAsyncCounterOddRef ref) async {
  final counter = await ref.watch(asyncCounterProvider.future);

  return counter.isOdd;
}
