import 'dart:convert';

/// SMES (Shri Markandeshwara English Medium School) dummy cache utility.
/// Provides simple in-memory caching for school management data.
class SmesCacheHelper {
  static final Map<String, _CacheEntry> _cache = {};
  static const Duration _defaultTtl = Duration(minutes: 5);

  /// Stores a value in cache with an optional TTL.
  static void put(String key, dynamic value, {Duration? ttl}) {
    _cache[key] = _CacheEntry(
      value: value,
      expiresAt: DateTime.now().add(ttl ?? _defaultTtl),
    );
  }

  /// Retrieves a cached value. Returns null if expired or not found.
  static dynamic get(String key) {
    final entry = _cache[key];
    if (entry == null) return null;
    if (DateTime.now().isAfter(entry.expiresAt)) {
      _cache.remove(key);
      return null;
    }
    return entry.value;
  }

  /// Removes a specific key from cache.
  static void invalidate(String key) => _cache.remove(key);

  /// Clears all cached entries for a given school.
  static void invalidateSchool(String schoolId) {
    _cache.removeWhere((k, _) => k.startsWith('school:$schoolId:'));
  }

  /// Serialises a value to a JSON string for persistent caching.
  static String serialise(dynamic value) => jsonEncode(value);

  /// Deserialises a JSON string.
  static dynamic deserialise(String raw) => jsonDecode(raw);
}

class _CacheEntry {
  final dynamic value;
  final DateTime expiresAt;
  const _CacheEntry({required this.value, required this.expiresAt});
}
