import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'stream_provider.g.dart';

@riverpod
Stream<int> streamCounter(StreamCounterRef _) {
  return Stream.value(0);
}
