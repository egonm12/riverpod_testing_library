import 'package:meta/meta.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';

// ignore: format-comment
/// {@template mock_notifier}
/// Extend or mixin this class to mark the implementation as a
/// [MockAutoDisposeNotifier].
///
/// A mocked auto dispose notifier implements the [build] method by returning
/// the [_build].
///
/// _**Note**: It is critical to explicitly provide the state
/// types when extending [MockAutoDisposeNotifier]_.
///
/// **GOOD**
/// ```dart
/// class MockNotifier extends MockAutoDisposeNotifier<NotifierState> implements
/// Notifier {
///  MockNotifier(super._initialState);
/// }
/// ```
///
/// **BAD**
/// ```dart
/// class MockNotifier extends MockAutoDisposeNotifier implements Notifier {}
/// ```
/// {@endtemplate}
@internal
class MockAutoDisposeNotifier<State> extends AutoDisposeNotifier<State>
    with Mock {
  /// {@macro mock_notifier}
  MockAutoDisposeNotifier(this._build) : super();

  final State Function() _build;

  @override
  State build() => _build();
}

// ignore: format-comment
/// {@template mock_async_notifier}
/// Extend or mixin this class to mark the implementation as a
/// [MockAutoDisposeNotifier].
///
/// A mocked auto dispose notifier implements the [build] method by returning
/// the [_build].
///
/// _**Note**: It is critical to explicitly provide the state
/// types when extending [MockAutoDisposeNotifier].
///
/// **GOOD**
/// ```dart
/// class MockNotifier extends MockAutoDisposeAsyncNotifier<NotifierState>
/// implements Notifier {
///   MockNotifier(super._build);
/// }
/// ```
///
/// **BAD**
/// ```dart
/// class MockNotifier extends MockAutoDisposeAsyncNotifier implements
/// Notifier {
///   MockNotifier(super._build)
/// }
/// ```
/// {@endtemplate}
@internal
class MockAutoDisposeAsyncNotifier<State>
    extends AutoDisposeAsyncNotifier<State> with Mock {
  /// {@macro mock_async_notifier}
  MockAutoDisposeAsyncNotifier(this._build) : super();

  final State Function() _build;

  @override
  State build() => _build();
}
