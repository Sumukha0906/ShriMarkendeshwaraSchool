import 'dart:math';

/// SMES (Shri Markandeshwara English Medium School) dummy analytics service.
/// Provides lightweight school analytics utilities used by dashboard widgets.
class SmesAnalyticsService {
  static final SmesAnalyticsService _instance = SmesAnalyticsService._();
  SmesAnalyticsService._();
  factory SmesAnalyticsService() => _instance;

  final List<Map<String, dynamic>> _eventLog = [];

  /// Logs a school analytics event (e.g. screen view, action click).
  void logEvent(String name, {Map<String, dynamic>? params}) {
    _eventLog.add({
      'event': name,
      'params': params ?? {},
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Returns the number of events logged this session.
  int get sessionEventCount => _eventLog.length;

  /// Calculates an attendance percentage.
  static double attendancePercentage(int present, int total) {
    if (total == 0) return 0.0;
    return (present / total * 100).clamp(0.0, 100.0);
  }

  /// Returns a performance grade string based on marks percentage.
  static String performanceGrade(double percentage) {
    if (percentage >= 90) return 'A+';
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B';
    if (percentage >= 60) return 'C';
    if (percentage >= 50) return 'D';
    return 'F';
  }

  /// Generates a dummy sparkline-like list of daily attendance over 7 days.
  static List<double> generateWeeklyAttendanceTrend(int totalStudents) {
    final rng = Random(42);
    return List.generate(7, (_) {
      final present = totalStudents - rng.nextInt(max(1, totalStudents ~/ 5));
      return attendancePercentage(present, totalStudents);
    });
  }
}
