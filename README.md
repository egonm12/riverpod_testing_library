# Riverpod Testing Library

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]
[![Coverage][test_coverage_badge]][test_coverage_badge]

A testing library which makes it easy to test providers. Built to be used with the [riverpod](https://pub.dev/packages/riverpod) state management package. Inspired by [bloc_test](https://pub.dev/packages/bloc_test).

---

## Getting started

Add `riverpod_testing_library` to your `pubspec.yaml`:

```yaml
dev_dependencies:
  riverpod_testing_library: 0.1.5
```

Install it:

```sh
dart pub get
```

---

## API

### `providerTest`

|Argument |Type    |Default|Description|
|-----|--------|-------|-----------|
|`provider`|[`ProviderListenable<State>`](https://pub.dev/documentation/riverpod/latest/riverpod/ProviderListenable-mixin.html)|  |The provider under test.
|`overrides`  |[`List<Override>`](https://pub.dev/documentation/riverpod/latest/riverpod/Override-class.html)|`<Override>[]`|A list of `Overrides` that stores the state of the providers and allows overriding the behavior of a specific provider|
|`setUp`  |`FutureOr<void> Function()?`| |Used to set up any dependencies prior to initializing the [provider] under test.|
|`skip`  |`int`|`0`|Can be used to skip any number of states.|
|`fireImmediately`  |`bool`|`false`|Tell Riverpod to immediately call the listener with the current value. Has no effect when `expect` is null.|
|`act`  |`FutureOr<void> Function(ProviderContainer container)?`||Will be invoked with the [ProviderContainer](https://pub.dev/documentation/riverpod/latest/riverpod/ProviderContainer-class.html) and should be used to interact with any provider.|
|`expect`  |`Object Function()?`||Asserts that the `provider` updates with the expected states (in  order) after [act] is executed.|
|`verify`  |`FutureOr<void> Function(ProviderContainer container)?`||Invoked after [act] and can be used for additional verification/assertions.|
|`tearDown`  |`FutureOr<void> Function()?`||Used to execute any code after the test has run.|

---

## Usage examples

### Write unit tests with `providerTest`

`providerTest` creates a new provider-specific tests case. It will handle asserting that the provider updates with the expected states (in order). It also handles ensuring that no additional states are stored by disposing the container being used in a test.

```dart
group('counterProvider', () {
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
    act: (container) => container.read(counterProvider.notifier).increment(),
    expect: () => [1],
  );
});
```

When using `providerTest` with state classes which don't override `==` and `hashCode` you can provide an `Iterable` of matchers instead of explicit state instances.

```dart
providerTest<int>(
  'emits [1] when Counter.increment() is called',
  provider: counterProvider,
  act: (container) => container.read(counterProvider.notifier).increment(),
  expect: () => [
    predicate<int>((value) {
      expect(value, 1);

      return true;
    }),
  ],
);
```

[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[test_coverage_badge]: https://github.com/egonm12/riverpod_testing_library/blob/main/coverage_badge.svg
