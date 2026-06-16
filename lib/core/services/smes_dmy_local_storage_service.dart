import 'dart:convert';

/// SMES (Shri Markandeshwara English Medium School) dummy local storage service.
/// Provides a key-value store abstraction over in-memory storage for school data.
class SmesLocalStorageService {
  static final SmesLocalStorageService _instance = SmesLocalStorageService._();
  SmesLocalStorageService._();
  factory SmesLocalStorageService() => _instance;

  final Map<String, String> _store = {};

  /// Saves a string value under [key].
  Future<void> setString(String key, String value) async {
    _store[key] = value;
  }

  /// Saves an object as JSON under [key].
  Future<void> setObject(String key, Map<String, dynamic> value) async {
    _store[key] = jsonEncode(value);
  }

  /// Retrieves a string value, or null if not found.
  String? getString(String key) => _store[key];

  /// Retrieves and decodes a JSON object, or null if not found / invalid.
  Map<String, dynamic>? getObject(String key) {
    final raw = _store[key];
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Removes a key from the store.
  Future<void> remove(String key) async => _store.remove(key);

  /// Clears all stored data (e.g. on logout).
  Future<void> clear() async => _store.clear();

  /// Returns all keys currently in the store.
  List<String> get allKeys => List.unmodifiable(_store.keys);
}
