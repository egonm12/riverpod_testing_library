import 'package:riverpod_testing_library/src/mock_provider.dart';
import 'async_notifier/async_counter.dart';
import 'notifier/counter.dart';

class CounterMock extends MockAutoDisposeNotifier<int> implements Counter {
  CounterMock(super._build);
}

class AsyncCounterMock extends MockAutoDisposeAsyncNotifier<int>
    implements AsyncCounter {
  AsyncCounterMock(super._build);
}
