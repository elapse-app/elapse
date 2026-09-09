import 'dart:async';

import 'package:elapse_app/extras/async_cache.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reuses cached values until the TTL expires', () async {
    var now = DateTime(2026, 8, 21);
    var loads = 0;
    final cache = AsyncCache<String, int>(
      timeToLive: const Duration(minutes: 5),
      clock: () => now,
    );

    Future<int> load() async => ++loads;

    expect(await cache.get('team', load), 1);
    expect(await cache.get('team', load), 1);
    expect(loads, 1);

    now = now.add(const Duration(minutes: 6));
    expect(await cache.get('team', load), 2);
  });

  test('coalesces concurrent loads for the same key', () async {
    final completer = Completer<int>();
    var loads = 0;
    final cache = AsyncCache<String, int>(
      timeToLive: const Duration(minutes: 5),
    );

    Future<int> load() {
      loads++;
      return completer.future;
    }

    final first = cache.get('event', load);
    final second = cache.get('event', load, forceRefresh: true);
    expect(loads, 1);

    completer.complete(42);
    expect(await Future.wait([first, second]), [42, 42]);
  });

  test('does not cache failed loads', () async {
    var loads = 0;
    final cache = AsyncCache<String, int>(
      timeToLive: const Duration(minutes: 5),
    );

    Future<int> load() async {
      loads++;
      if (loads == 1) throw StateError('offline');
      return 7;
    }

    await expectLater(cache.get('event', load), throwsStateError);
    expect(await cache.get('event', load), 7);
    expect(loads, 2);
  });

  test('force refresh bypasses a completed cached value', () async {
    var loads = 0;
    final cache = AsyncCache<String, int>(
      timeToLive: const Duration(hours: 1),
    );

    Future<int> load() async => ++loads;

    expect(await cache.get('rankings', load), 1);
    expect(await cache.get('rankings', load, forceRefresh: true), 2);
  });
}
