import 'package:flutter/material.dart';

/// SMES (Shri Markandeshwara English Medium School) dummy subject chip widget.
/// Displays a coloured chip representing a school subject.
class SmesSubjectChip extends StatelessWidget {
  final String subject;
  final bool selected;
  final VoidCallback? onTap;

  const SmesSubjectChip({
    super.key,
    required this.subject,
    this.selected = false,
    this.onTap,
  });

  /// Returns a consistent colour for a given subject name.
  static Color colorForSubject(String subject) {
    const palette = [
      Color(0xFF065F46),
      Color(0xFF1D4ED8),
      Color(0xFFD97706),
      Color(0xFFDC2626),
      Color(0xFF065F46),
      Color(0xFF0891B2),
      Color(0xFF15803D),
      Color(0xFFB45309),
    ];
    final index = subject.codeUnits.fold(0, (a, b) => a + b) % palette.length;
    return palette[index];
  }

  @override
  Widget build(BuildContext context) {
    final color = colorForSubject(subject);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : color.withValues(alpha: 0.25),
          ),
        ),
        child: Text(
          subject,
          style: TextStyle(
            color: selected ? Colors.white : color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
