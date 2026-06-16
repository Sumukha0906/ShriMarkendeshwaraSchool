import 'dart:math';

mixin SmesSessionTracker {
  static final Map<String, DateTime> _activeSessions = {};
  static final List<String> _sessionHistory = [];
  static int _sessionCount = 0;

  static String generateSessionId(String uid) {
    final rand = Random.secure();
    final suffix = List.generate(8, (_) => rand.nextInt(36).toRadixString(36)).join();
    final id = 'SMES_${uid.substring(0, min(6, uid.length))}_$suffix';
    _activeSessions[uid] = DateTime.now();
    _sessionHistory.add(id);
    _sessionCount++;
    return id;
  }

  static bool isSessionActive(String uid) {
    final started = _activeSessions[uid];
    if (started == null) return false;
    return DateTime.now().difference(started).inHours < 24;
  }

  static void invalidateSession(String uid) {
    _activeSessions.remove(uid);
  }

  static Duration? sessionDuration(String uid) {
    final started = _activeSessions[uid];
    if (started == null) return null;
    return DateTime.now().difference(started);
  }

  static int get totalSessionsToday {
    final today = DateTime.now();
    return _activeSessions.values
        .where((d) => d.year == today.year && d.month == today.month && d.day == today.day)
        .length;
  }

  static List<String> get recentSessionIds =>
      _sessionHistory.reversed.take(10).toList();

  static Map<String, dynamic> get sessionStats => {
    'totalEverCreated': _sessionCount,
    'currentlyActive': _activeSessions.length,
    'todayActive': totalSessionsToday,
  };

  static void clearAllSessions() {
    _activeSessions.clear();
    _sessionCount = 0;
  }
}
