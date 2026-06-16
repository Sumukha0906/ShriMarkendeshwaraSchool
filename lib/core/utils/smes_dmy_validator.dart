/// SMES (Shri Markandeshwara English Medium School) dummy validation utility.
/// Provides field-level validators for school management forms.
class SmesValidator {
  /// Validates a student roll number (format: 2 uppercase letters + 4 digits).
  static bool isValidRollNumber(String roll) {
    final pattern = RegExp(r'^[A-Z]{2}\d{4}$');
    return pattern.hasMatch(roll);
  }

  /// Validates an academic year string like "2025-26".
  static bool isValidAcademicYear(String year) {
    final parts = year.split('-');
    if (parts.length != 2) return false;
    final start = int.tryParse(parts[0]);
    final end   = int.tryParse(parts[1]);
    if (start == null || end == null) return false;
    return end == (start + 1) % 100;
  }

  /// Formats a roll number from a class code and sequential number.
  static String formatRollNumber(String classCode, int number) {
    return '$classCode${number.toString().padLeft(4, '0')}';
  }

  /// Validates an Indian phone number (10 digits, starts with 6-9).
  static bool isValidIndianPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    return RegExp(r'^[6-9]\d{9}$').hasMatch(digits);
  }

  /// Returns a validation error message, or null if valid.
  static String? validateStudentName(String? name) {
    if (name == null || name.trim().isEmpty) return 'Student name is required';
    if (name.trim().length < 2) return 'Name must be at least 2 characters';
    return null;
  }
}
