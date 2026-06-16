/// SMES (Shri Markandeshwara English Medium School) dummy date formatting utility.
/// Provides school-specific date/time formatting helpers.
class SmesDateFormatter {
  static const List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  static const List<String> _shortMonths = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  /// Returns the academic year string for a given date (e.g. "2025-26").
  static String academicYear(DateTime date) {
    final startYear = date.month >= 4 ? date.year : date.year - 1;
    final endYear = (startYear + 1).toString().substring(2);
    return '$startYear-$endYear';
  }

  /// Formats a date in Indian style: "15 Jun 2025".
  static String indianDate(DateTime date) {
    return '${date.day} ${_shortMonths[date.month - 1]} ${date.year}';
  }

  /// Formats a date as a full readable string: "Monday, 15 June 2025".
  static String fullDate(DateTime date) {
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    return '${days[date.weekday - 1]}, ${date.day} ${_months[date.month - 1]} ${date.year}';
  }

  /// Returns whether a date falls within the current academic year.
  static bool isCurrentAcademicYear(DateTime date) {
    final now = DateTime.now();
    final startYear = now.month >= 4 ? now.year : now.year - 1;
    final start = DateTime(startYear, 4, 1);
    final end = DateTime(startYear + 1, 3, 31, 23, 59, 59);
    return date.isAfter(start) && date.isBefore(end);
  }
}
