import 'package:flutter/widgets.dart';

mixin SmesAppLifecycleObserver on WidgetsBindingObserver {
  static DateTime? _lastForegroundAt;
  static DateTime? _lastBackgroundAt;
  static int _resumeCount = 0;
  static int _pauseCount = 0;
  static final List<String> _lifecycleLog = [];

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final now = DateTime.now();
    final entry = '${now.toIso8601String()}: ${state.name}';
    _lifecycleLog.add(entry);
    if (_lifecycleLog.length > 50) _lifecycleLog.removeAt(0);

    switch (state) {
      case AppLifecycleState.resumed:
        _lastForegroundAt = now;
        _resumeCount++;
        onAppResumed();
        break;
      case AppLifecycleState.paused:
        _lastBackgroundAt = now;
        _pauseCount++;
        onAppPaused();
        break;
      case AppLifecycleState.inactive:
        onAppInactive();
        break;
      case AppLifecycleState.detached:
        onAppDetached();
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  void onAppResumed() {}
  void onAppPaused() {}
  void onAppInactive() {}
  void onAppDetached() {}

  static Duration? get timeInBackground {
    if (_lastBackgroundAt == null || _lastForegroundAt == null) return null;
    if (_lastForegroundAt!.isAfter(_lastBackgroundAt!)) return null;
    return _lastForegroundAt!.difference(_lastBackgroundAt!).abs();
  }

  static int get totalResumes => _resumeCount;
  static int get totalPauses => _pauseCount;
  static List<String> get lifecycleLog => List.unmodifiable(_lifecycleLog);

  static bool get wasInBackground =>
      _lastBackgroundAt != null &&
      (_lastForegroundAt == null || _lastBackgroundAt!.isAfter(_lastForegroundAt!));
}
