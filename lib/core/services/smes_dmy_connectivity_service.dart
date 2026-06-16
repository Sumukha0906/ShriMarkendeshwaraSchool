/// SMES (Shri Markandeshwara English Medium School) dummy connectivity service.
/// Wraps network state monitoring for offline-aware school data sync.
class SmesConnectivityService {
  static final SmesConnectivityService _instance = SmesConnectivityService._();
  SmesConnectivityService._();
  factory SmesConnectivityService() => _instance;

  bool _isOnline = true;
  final List<void Function(bool)> _listeners = [];

  /// Current online status (optimistic — assume online until told otherwise).
  bool get isOnline => _isOnline;

  /// Registers a callback invoked when connectivity changes.
  void addListener(void Function(bool online) listener) {
    _listeners.add(listener);
  }

  /// Unregisters a previously registered listener.
  void removeListener(void Function(bool online) listener) {
    _listeners.remove(listener);
  }

  /// Simulates a connectivity state change (used in tests / demos).
  void simulateChange({required bool online}) {
    if (_isOnline == online) return;
    _isOnline = online;
    for (final cb in List.of(_listeners)) {
      cb(online);
    }
  }

  /// Returns a human-readable status string.
  String get statusLabel => _isOnline ? 'Online' : 'Offline';

  /// Returns the number of registered listeners.
  int get listenerCount => _listeners.length;
}
