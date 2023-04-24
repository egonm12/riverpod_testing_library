import 'dart:async';

import 'package:diff_match_patch/diff_match_patch.dart';
import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart' as test;

/// Creates a new `riverpod`-specific test case with the given [description].
/// [providerTest] will handle asserting that the `provider` updates with the
/// expected states (in order) after [act] is executed.
///
/// [provider] should be the `provider` under test.
///
/// [overrides] is a list of [Override]s that stores the state of the providers
/// and allows overriding the behavior of a specific provider.
///
/// [setUp] is optional and should be used to set up
/// any dependencies prior to initializing the [provider] under test.
/// [setUp] should be used to set up state necessary for a particular test case.
/// For common set up code, prefer to use `setUp` from `package:test/test.dart`.
///
/// [skip] is an optional `int` which can be used to skip any number of states.
/// [skip] defaults to 0.
///
/// [fireImmediately] (false by default) can be optionally passed to tell
/// Riverpod to immediately call the listener with the current value. Has no
/// effect when [expect] is `null`.
///
/// [act] is an optional callback which will be invoked with the
/// [ProviderContainer] and should be used to interact with any provider.
///
/// [expect] is an optional `Function` that returns a `Matcher` that asserts
/// that the `provider` updates with the expected states (in order) after [act]
/// is executed.
///
/// [verify] is an optional callback which is invoked after [act]
/// and can be used for additional verification/assertions.
///
/// [tearDown] is optional and can be used to execute any code after the test
/// has run.
/// [tearDown] should be used to clean up after a particular test case.
/// For common tear down code, prefer to use `tearDown` from `package:test/test.dart`.
@isTest
void providerTest<T>(
  String description, {
  required ProviderListenable<T> provider,
  List<Override> overrides = const <Override>[],
  FutureOr<void> Function()? setUp,
  int skip = 0,
  bool fireImmediately = false,
  FutureOr<void> Function(ProviderContainer container)? act,
  Object Function()? expect,
  FutureOr<void> Function(ProviderContainer container)? verify,
  FutureOr<void> Function()? tearDown,
}) {
  // ignore: avoid-passing-async-when-sync-expected
  test.test(description, () async {
    await testProvider(
      provider: provider,
      providerOverrides: overrides,
      setUp: setUp,
      skip: skip,
      fireImmediately: fireImmediately,
      act: act,
      expect: expect,
      verify: verify,
      tearDown: tearDown,
    );
  });
}

/// Internal [testProvider] runner which is only visible for testing.
/// This should never be used directly -- please use [testProvider] instead.
@internal
Future<void> testProvider<T>({
  required ProviderListenable<T> provider,
  List<Override> providerOverrides = const [],
  FutureOr<void> Function()? setUp,
  int skip = 0,
  bool fireImmediately = false,
  FutureOr<void> Function(ProviderContainer container)? act,
  Object Function()? expect,
  FutureOr<void> Function(ProviderContainer container)? verify,
  FutureOr<void> Function()? tearDown,
}) async {
  await setUp?.call();

  final container = _makeProviderContainer(providerOverrides);
  final states = _listenToProviderStates(
    container,
    provider,
    expect != null,
    fireImmediately,
  );

  await act?.call(container);

  if (skip > 0) states.removeRange(0, skip);
  if (expect != null) _compareStates(states, expect());

  await verify?.call(container);
  await tearDown?.call();
}

List<T> _listenToProviderStates<T>(
  ProviderContainer container,
  ProviderListenable<T> provider,
  bool shouldListen,
  bool fireImmediately,
) {
  final states = <T>[];
  if (shouldListen) {
    // ignore: avoid-ignoring-return-values
    container.listen<T>(
      provider,
      (_, current) => states.add(current),
      fireImmediately: fireImmediately,
    );
  }

  return states;
}

void _compareStates<T>(List<T> states, Object expected) {
  try {
    test.expect(states, test.wrapMatcher(expected));
  } on test.TestFailure catch (error) {
    final diff = _diffMatch(expected: expected, actual: states);

    // ignore: avoid-throw-in-catch-block
    throw test.TestFailure('${error.message}\n$diff');
  }
}

ProviderContainer _makeProviderContainer([
  List<Override> overrides = const [],
]) {
  final container = ProviderContainer(overrides: overrides);
  test.addTearDown(container.dispose);

  return container;
}

String _diffMatch({required Object? expected, required Object? actual}) {
  final buffer = StringBuffer();
  final differences = diff(expected.toString(), actual.toString());

  buffer
    ..writeln('${"=" * 4} diff ${"=" * 40}')
    ..writeln()
    ..writeln(differences.toPrettyString())
    ..writeln()
    ..writeln('${"=" * 4} end diff ${"=" * 36}');

  return buffer.toString();
}

extension on List<Diff> {
  String toPrettyString() {
    String identical(String str) => '\u001b[90m$str\u001B[0m';
    String deletion(String str) => '\u001b[31m[-$str-]\u001B[0m';
    String insertion(String str) => '\u001b[32m{+$str+}\u001B[0m';

    final buffer = StringBuffer();
    for (final difference in this) {
      switch (difference.operation) {
        case DIFF_EQUAL:
          buffer.write(identical(difference.text));
          break;
        case DIFF_DELETE:
          buffer.write(deletion(difference.text));
          break;
        case DIFF_INSERT:
          buffer.write(insertion(difference.text));
          break;
      }
    }

    return buffer.toString();
  }
}
