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

---

## Continuous Integration 🤖

Riverpod Test comes with a built-in [GitHub Actions workflow][github_actions_link] powered by [Very Good Workflows][very_good_workflows_link] but you can also add your preferred CI/CD solution.

Out of the box, on each pull request and push, the CI `formats`, `lints`, and `tests` the code. This ensures the code remains consistent and behaves correctly as you add functionality or make changes. The project uses [Very Good Analysis][very_good_analysis_link] for a strict set of analysis options used by our team. Code coverage is enforced using the [Very Good Workflows][very_good_coverage_link].

---

## Running Tests 🧪

To run all unit tests:

```sh
dart pub global activate coverage 1.2.0
dart test --coverage=coverage
dart pub global run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info
```

To view the generated coverage report you can use [lcov](https://github.com/linux-test-project/lcov).

```sh
# Generate Coverage Report
genhtml coverage/lcov.info -o coverage/

# Open Coverage Report
open coverage/index.html
```

[github_actions_link]: https://docs.github.com/en/actions/learn-github-actions
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[very_good_coverage_link]: https://github.com/marketplace/actions/very-good-coverage
[very_good_workflows_link]: https://github.com/VeryGoodOpenSource/very_good_workflows
