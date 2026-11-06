import 'package:flutter/foundation.dart';

Stream<int> countdown(int from) async* {
  for (var value = from; value >= 0; value--) {
    await Future<void>.delayed(const Duration(seconds: 1));
    yield value;
    debugPrint('tick $value');
  }
}
