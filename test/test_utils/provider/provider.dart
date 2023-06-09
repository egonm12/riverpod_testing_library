import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../notifier/counter.dart';

part 'provider.g.dart';

@riverpod
bool isCounterOdd(IsCounterOddRef ref) {
  final counter = ref.watch(counterProvider);

  return counter.isOdd;
}
