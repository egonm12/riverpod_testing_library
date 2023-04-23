import 'package:riverpod_test/riverpod_test.dart';
import 'package:test/test.dart';

import '../test/test_utils/notifier/counter.dart';

void main() {
  group('provider_test', () {
    group('Counter NotifierProvider', () {
      providerTest<int>(
        'emits the initial state when fireImmediately is true',
        provider: counterProvider,
        fireImmediately: true,
        expect: () => [0],
      );

      providerTest<int>(
        'emits [] when nothing is done',
        provider: counterProvider,
        expect: () => [],
      );

      providerTest<int>(
        'emits [1] when Counter.increment() is called',
        provider: counterProvider,
        act: (container) =>
            container.read(counterProvider.notifier).increment(),
        expect: () => [1],
      );
    });
  });
}
