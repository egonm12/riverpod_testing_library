# Riverpod Test

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]

A testing library which makes it easy to test providers. Built to be used with the [riverpod](https://pub.dev/packages/riverpod) state management package. Inspired by [bloc_test](https://pub.dev/packages/bloc_test).

## Getting started

Add `riverpod_test` to your `pubspec.yaml`:

```yaml
dev_dependencies:
  riverpod_test: 0.1.0
```

Install it:

```sh
dart pub get
```

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
