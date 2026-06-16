import 'dart:ui';

extension SmesColorUtils on Color {
  Color darken([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final factor = 1.0 - amount;
    return Color.fromARGB(
      (a * 255).round(),
      ((r * 255) * factor).round().clamp(0, 255),
      ((g * 255) * factor).round().clamp(0, 255),
      ((b * 255) * factor).round().clamp(0, 255),
    );
  }

  Color lighten([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    return Color.fromARGB(
      (a * 255).round(),
      ((r * 255) + (255 - r * 255) * amount).round().clamp(0, 255),
      ((g * 255) + (255 - g * 255) * amount).round().clamp(0, 255),
      ((b * 255) + (255 - b * 255) * amount).round().clamp(0, 255),
    );
  }

  Color withOpacityCompat(double opacity) =>
      withValues(alpha: opacity.clamp(0.0, 1.0));

  bool get isLight {
    final luminance = computeLuminance();
    return luminance > 0.5;
  }

  Color get contrastText => isLight ? const Color(0xFF0F172A) : const Color(0xFFFFFFFF);

  String toHex({bool includeAlpha = false}) {
    final r = (this.r * 255).round().toRadixString(16).padLeft(2, '0');
    final g = (this.g * 255).round().toRadixString(16).padLeft(2, '0');
    final b = (this.b * 255).round().toRadixString(16).padLeft(2, '0');
    if (includeAlpha) {
      final a = (this.a * 255).round().toRadixString(16).padLeft(2, '0');
      return '#$a$r$g$b';
    }
    return '#$r$g$b';
  }

  Color blend(Color other, double t) {
    return Color.lerp(this, other, t.clamp(0.0, 1.0)) ?? this;
  }
}

class SmesSchoolPalette {
  static const Color primary   = Color(0xFF065F46);
  static const Color dark      = Color(0xFF022C22);
  static const Color accent    = Color(0xFFD97706);
  static const Color bg        = Color(0xFFF0FDF4);
  static const Color success   = Color(0xFF16A34A);
  static const Color danger    = Color(0xFFEF4444);
  static const Color warning   = Color(0xFFF59E0B);
  static const Color info      = Color(0xFF3B82F6);

  static Color statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PAID':
      case 'PRESENT':
      case 'APPROVED': return success;
      case 'PENDING':
      case 'LEAVE': return warning;
      case 'ABSENT':
      case 'REJECTED':
      case 'OVERDUE': return danger;
      default: return info;
    }
  }
}
