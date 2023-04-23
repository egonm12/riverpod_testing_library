import 'dart:async';

import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';

import 'package:riverpod_testing_library/src/provider_test.dart';
import '../test_utils/async_notifier/async_counter.dart';
import '../test_utils/future_provider/future_provider.dart';
import '../test_utils/mocks.dart';
import '../test_utils/notifier/counter.dart';
import '../test_utils/notifier/error_counter.dart';
import '../test_utils/provider/provider.dart';
import '../test_utils/state_notifier/counter_state_notifier.dart';
import '../test_utils/stream_provider/stream_provider.dart';

class Listener extends Mock {
  void call();
}

void main() {
  group('providerTest', () {
    late Listener listener;

    setUp(() {
      listener = Listener();
    });

    setUpAll(() {
      registerFallbackValue(ProviderContainer());
    });

    test('calls set up', () async {
      await testProvider(provider: counterProvider, setUp: listener.call);

      verify(listener.call).called(1);
    });

    test('calls tear down', () async {
      await testProvider(provider: counterProvider, tearDown: listener.call);

      verify(listener.call).called(1);
    });

    test('calls verify', () async {
      await testProvider(
        provider: counterProvider,
        verify: (_) => listener.call(),
      );

      verify(listener.call).called(1);
    });

    group('Provider', () {
      providerTest<bool>(
        'emits false when the counter provider returns an even value '
        'and fireImmediately: true',
        provider: isCounterOddProvider,
        overrides: [
          counterProvider.overrideWith(() => CounterMock(() => 0)),
        ],
        fireImmediately: true,
        expect: () => [false],
      );

      providerTest<bool>(
        'emits true when the counter provider returns an odd value '
        'and fireImmediately: true',
        provider: isCounterOddProvider,
        overrides: [
          counterProvider.overrideWith(() => CounterMock(() => 1)),
        ],
        fireImmediately: true,
        expect: () => [true],
      );
    });

    group('FutureProvider', () {
      providerTest<AsyncValue<bool>>(
        'emits AsyncValue.data(false) when the async counter provider returns '
        'an even value',
        provider: isAsyncCounterOddProvider,
        overrides: [
          asyncCounterProvider.overrideWith(() => AsyncCounterMock(() => 0)),
        ],
        expect: () => const [AsyncValue.data(false)],
      );

      providerTest<AsyncValue<bool>>(
        'emits AsyncValue.data(true) when the async counter provider returns '
        'an odd value',
        provider: isAsyncCounterOddProvider,
        overrides: [
          asyncCounterProvider.overrideWith(() => AsyncCounterMock(() => 1)),
        ],
        expect: () => const [AsyncValue.data(true)],
      );

      providerTest<AsyncValue<bool>>(
        'emits [AsyncValue<bool>.loading(), AsyncValue.data(false)] '
        'when fireImmediately: true',
        provider: isAsyncCounterOddProvider,
        overrides: [
          asyncCounterProvider.overrideWith(() => AsyncCounterMock(() => 0)),
        ],
        fireImmediately: true,
        expect: () => const [
          AsyncValue<bool>.loading(),
          AsyncValue.data(false),
        ],
      );
    });

    group('StreamProvider', () {
      providerTest<AsyncValue<int>>(
        'emits AsyncValue.data(0) when the stream counter provider returns '
        'the stream value',
        provider: streamCounterProvider,
        expect: () => const [AsyncValue.data(0)],
      );

      providerTest<AsyncValue<int>>(
        'emits [AsyncValue<bool>.loading(), AsyncValue.data(false)] '
        'when fireImmediately: true',
        provider: streamCounterProvider,
        fireImmediately: true,
        expect: () => const [
          AsyncValue<int>.loading(),
          AsyncValue.data(0),
        ],
      );
    });

    group('Counter NotifierProvider', () {
      providerTest<int>(
        'supports matcher "predicate"',
        provider: counterProvider,
        act: (container) =>
            container.read(counterProvider.notifier).increment(),
        expect: () => [
          predicate<int>((value) {
            expect(value, 1);

            return true;
          }),
        ],
      );

      providerTest<int>(
        'supports matcher "contains"',
        provider: counterProvider,
        act: (container) =>
            container.read(counterProvider.notifier).increment(),
        expect: () => contains(1),
      );

      providerTest<int>(
        'supports skipping states',
        provider: counterProvider,
        skip: 2,
        act: (container) {
          container.read(counterProvider.notifier).increment();
          container.read(counterProvider.notifier).increment();
          container.read(counterProvider.notifier).increment();
        },
        expect: () => [3],
      );

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

      providerTest<int>(
        'emits [1] when Counter.increment() is called with async act',
        provider: counterProvider,
        act: (container) async {
          await Future<void>.delayed(const Duration(seconds: 1));
          container.read(counterProvider.notifier).increment();
        },
        expect: () => [1],
      );

      test('fails immediately when expectation is incorrect', () async {
        const expectedError = 'Expected: [2]\n'
            '  Actual: [1]\n'
            '   Which: at location [0] is <1> instead of <2>\n'
            '\n'
            '==== diff ========================================\n'
            '\n'
            '''\x1B[90m[\x1B[0m\x1B[31m[-2-]\x1B[0m\x1B[32m{+1+}\x1B[0m\x1B[90m]\x1B[0m\n'''
            '\n'
            '==== end diff ====================================\n';

        Object? actualError;

        final completer = Completer<void>();

        await runZonedGuarded(
          () async {
            unawaited(
              // ignore: prefer-async-await
              testProvider<int>(
                provider: counterProvider,
                act: (container) =>
                    container.read(counterProvider.notifier).increment(),
                expect: () => const <int>[2],
              ).then((_) => completer.complete()),
            );

            await completer.future;
          },
          (Object error, _) {
            actualError = error;
            if (!completer.isCompleted) completer.complete();
          },
        );

        expect((actualError as TestFailure?)?.message, expectedError);
      });

      test(
        'fails immediately when uncaught error occurs in provider',
        () async {
          Object? actualError;

          final completer = Completer<void>();

          await runZonedGuarded(
            () async {
              unawaited(
                // ignore: prefer-async-await
                testProvider<int>(
                  provider: errorCounterProvider,
                  act: (container) =>
                      container.read(errorCounterProvider.notifier).increment(),
                  expect: () => const <int>[1],
                ).then((_) => completer.complete()),
              );

              await completer.future;
            },
            (Object error, _) {
              actualError = error;
              if (!completer.isCompleted) completer.complete();
            },
          );

          expect(
            actualError,
            isA<ErrorCounterError>(),
          );
        },
      );

      test(
        'fails immediately when uncaught exception occurs in act',
        () async {
          final exception = Exception('Something went wrong!');
          Object? actualError;

          final completer = Completer<void>();

          await runZonedGuarded(
            () async {
              unawaited(
                // ignore: prefer-async-await
                testProvider<int>(
                  provider: errorCounterProvider,
                  act: (container) => throw exception,
                  expect: () => const <int>[1],
                ).then((_) => completer.complete()),
              );

              await completer.future;
            },
            (Object error, _) {
              actualError = error;
              if (!completer.isCompleted) completer.complete();
            },
          );

          expect(actualError, exception);
        },
      );
    });

    group('Counter AsyncNotifierProvider', () {
      providerTest<AsyncValue<int>>(
        'supports skipping states',
        provider: asyncCounterProvider,
        skip: 2,
        act: (container) async {
          final notifier = container.read(asyncCounterProvider.notifier);
          await Future.wait([
            notifier.increment(),
            notifier.increment(),
            notifier.increment(),
          ]);
        },
        expect: () => [const AsyncValue.data(3)],
      );

      providerTest<AsyncValue<int>>(
        'emits the initial state when fireImmediately is true',
        provider: asyncCounterProvider,
        fireImmediately: true,
        expect: () => const [AsyncValue.data(0)],
      );

      providerTest<AsyncValue<int>>(
        'emits [] when nothing is done',
        provider: asyncCounterProvider,
        expect: () => [],
      );

      providerTest<AsyncValue<int>>(
        'emits [1] when Counter.increment() is called',
        provider: asyncCounterProvider,
        act: (container) async =>
            container.read(asyncCounterProvider.notifier).increment(),
        expect: () => [const AsyncValue.data(1)],
      );
    });

    group('Counter StateNotifierProvider', () {
      providerTest<int>(
        'emits the initial state when fireImmediately is true',
        provider: counterStateNotifierProvider,
        fireImmediately: true,
        expect: () => [0],
      );

      providerTest<int>(
        'emits [] when nothing is done',
        provider: counterStateNotifierProvider,
        expect: () => [],
      );

      providerTest<int>(
        'emits [1] when CounterStateNotifier.increment() is called',
        provider: counterStateNotifierProvider,
        act: (container) =>
            container.read(counterStateNotifierProvider.notifier).increment(),
        expect: () => [1],
      );
    });
  });
}
