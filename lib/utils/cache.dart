import 'dart:async';

class SimpleCache<K, V> {
  final int capacity;
  final Map<K, V> _cache = {};

  SimpleCache(this.capacity);

  V? get(K key) {
    if (!_cache.containsKey(key)) {
      return null;
    }

    return _cache[key];
  }

  void put(K key, V value) {
    if (_cache.containsKey(key)) {
      return;
    }

    if (_cache.length >= capacity) {
      final oldestKey = _cache.keys.first;
      _cache.remove(oldestKey);
    }

    // Add new key to the end of access order and cache
    _cache[key] = value;
  }

  void clear() {
    _cache.clear();
  }

  int get length => _cache.length;
}
