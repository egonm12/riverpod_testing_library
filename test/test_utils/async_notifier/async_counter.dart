
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'async_counter.g.dart';

@riverpod
class AsyncCounter extends _$AsyncCounter {
  @override
  FutureOr<int> build() => 0;

  Future<void> increment() async {
    await Future<void>.delayed(const Duration(microseconds: 1));

    final count = state.valueOrNull ?? 0;

    state = AsyncValue.data(count + 1);
  }
}
