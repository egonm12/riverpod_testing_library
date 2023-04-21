import 'package:riverpod/riverpod.dart';

class CounterStateNotifier extends StateNotifier<int> {
  CounterStateNotifier() : super(0);

  void increment() {
    state = state + 1;
  }
}

final counterStateNotifierProvider =
    StateNotifierProvider<CounterStateNotifier, int>((ref) {
  return CounterStateNotifier();
});
