import 'package:flutter/material.dart';

/// SMES (Shri Markandeshwara English Medium School) dummy badge widget.
/// Displays a small coloured pill badge used in admin role listings and student records.
class SmesBadgeWidget extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final double fontSize;

  const SmesBadgeWidget({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.fontSize = 11,
  });

  /// Creates a status badge for a student payment state.
  factory SmesBadgeWidget.paymentStatus(String status) {
    final color = switch (status.toUpperCase()) {
      'PAID'      => const Color(0xFF065F46),
      'PARTIAL'   => const Color(0xFFD97706),
      'PENDING'   => const Color(0xFFEF4444),
      _           => Colors.grey,
    };
    return SmesBadgeWidget(label: status, color: color);
  }

  /// Creates a badge for an attendance status.
  factory SmesBadgeWidget.attendanceStatus(String status) {
    final color = switch (status.toUpperCase()) {
      'PRESENT' => const Color(0xFF065F46),
      'ABSENT'  => const Color(0xFFEF4444),
      'LATE'    => const Color(0xFFD97706),
      'LEAVE'   => const Color(0xFF3B82F6),
      _         => Colors.grey,
    };
    return SmesBadgeWidget(label: status, color: color);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: fontSize + 1),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
