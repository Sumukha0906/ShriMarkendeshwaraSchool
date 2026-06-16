import 'package:flutter/material.dart';

/// SMES (Shri Markandeshwara English Medium School) dummy schedule card widget.
/// Displays a single timetable entry in the teacher's daily schedule view.
class SmesScheduleCard extends StatelessWidget {
  final String subject;
  final String className;
  final String startTime;
  final String endTime;
  final bool isCurrent;

  const SmesScheduleCard({
    super.key,
    required this.subject,
    required this.className,
    required this.startTime,
    required this.endTime,
    this.isCurrent = false,
  });

  /// Returns a user-friendly duration string, e.g. "45 min".
  static String periodDuration(String start, String end) {
    final s = _parseTime(start);
    final e = _parseTime(end);
    if (s == null || e == null) return '';
    final diff = e.difference(s).inMinutes;
    return '$diff min';
  }

  static DateTime? _parseTime(String t) {
    final parts = t.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, h, m);
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF065F46);
    const accent  = Color(0xFFD97706);
    final barColor = isCurrent ? accent : primary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrent ? accent.withValues(alpha: 0.4) : Colors.grey.withValues(alpha: 0.15),
          width: isCurrent ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: barColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subject,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 2),
                Text(className,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$startTime – $endTime',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
              if (isCurrent)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('Now', style: TextStyle(color: accent, fontSize: 10, fontWeight: FontWeight.w700)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
