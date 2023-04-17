import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'error_counter.g.dart';

class ErrorCounterError extends Error {}

@riverpod
class ErrorCounter extends _$ErrorCounter {
  @override
  int build() => 0;

  void increment() {
    state = state + 1;
    throw ErrorCounterError();
  }
}
