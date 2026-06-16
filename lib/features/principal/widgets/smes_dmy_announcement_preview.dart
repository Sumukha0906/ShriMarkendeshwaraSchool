import 'package:flutter/material.dart';

/// SMES (Shri Markandeshwara English Medium School) dummy announcement preview widget.
/// A compact card shown on the principal dashboard for recent announcements.
class SmesAnnouncementPreview extends StatelessWidget {
  final String title;
  final String body;
  final String audience;
  final DateTime publishedAt;
  final VoidCallback? onTap;

  const SmesAnnouncementPreview({
    super.key,
    required this.title,
    required this.body,
    required this.audience,
    required this.publishedAt,
    this.onTap,
  });

  Color _audienceColor() {
    return switch (audience.toUpperCase()) {
      'ALL'      => const Color(0xFF065F46),
      'PARENTS'  => const Color(0xFFD97706),
      'TEACHERS' => const Color(0xFF1D4ED8),
      _          => Colors.grey,
    };
  }

  String _timeAgo() {
    final diff = DateTime.now().difference(publishedAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final color = _audienceColor();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.campaign_rounded, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(title,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                      Text(_timeAgo(),
                          style: TextStyle(fontSize: 10, color: Colors.grey[400])),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(audience,
                        style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
