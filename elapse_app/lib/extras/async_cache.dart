/// A small in-memory cache that also coalesces concurrent requests for a key.
///
/// Failed loads are never cached, and an in-flight load is always shared even
/// when callers request a refresh. This prevents refresh gestures and sibling
/// screens from creating a burst of identical network requests.
class AsyncCache<K, V> {
  AsyncCache({
    required this.timeToLive,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final Duration timeToLive;
  final DateTime Function() _clock;
  final Map<K, _CacheEntry<V>> _values = {};
  final Map<K, Future<V>> _inFlight = {};

  Future<V> get(
    K key,
    Future<V> Function() loader, {
    bool forceRefresh = false,
  }) {
    final cached = _values[key];
    if (!forceRefresh && cached != null && cached.expiresAt.isAfter(_clock())) {
      return Future.value(cached.value);
    }

    final activeRequest = _inFlight[key];
    if (activeRequest != null) {
      return activeRequest;
    }

    final request = Future<V>.sync(loader).then((value) {
      _values[key] = _CacheEntry(
        value: value,
        expiresAt: _clock().add(timeToLive),
      );
      return value;
    }).whenComplete(() {
      _inFlight.remove(key);
    });

    _inFlight[key] = request;
    return request;
  }

  void invalidate(K key) {
    _values.remove(key);
  }

  void clear() {
    _values.clear();
  }
}

class _CacheEntry<V> {
  const _CacheEntry({required this.value, required this.expiresAt});

  final V value;
  final DateTime expiresAt;
}
