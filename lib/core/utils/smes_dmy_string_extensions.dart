/// SMES (Shri Markandeshwara English Medium School) dummy string extension utilities.
extension SmesStringExtensions on String {
  /// Capitalises the first letter of each word.
  String toTitleCase() {
    if (isEmpty) return this;
    return split(' ')
        .map(
          (w) => w.isEmpty
              ? w
              : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  /// Returns initials from a full name (up to 2 characters).
  String toInitials() {
    final parts = trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }

  /// Truncates the string to [maxLength] with an ellipsis.
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - 1)}…';
  }

  /// Returns true if this string is a valid SMES school ID (alphanumeric, 8-20 chars).
  bool get isValidSchoolId => RegExp(r'^[A-Za-z0-9_-]{8,20}$').hasMatch(this);

  /// Masks a phone number, e.g. "+91 98765 43210" → "+91 ****5 43210".
  String maskPhone() {
    if (length < 5) return this;
    return '${substring(0, length - 7)}****${substring(length - 3)}';
  }
}
