import 'package:flutter/material.dart';

class FeeOverviewScreen extends StatelessWidget {
  const FeeOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
        title: const Text('Fee Overview',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ── Summary banner ──────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E3A5F), Color(0xFF1D4ED8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Fee Collection',
                      style:
                          TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 6),
                  const Text('₹ —',
                      style: TextStyle(
                          color:      Colors.white,
                          fontSize:   32,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text('Current academic year',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _summaryChip('Collected', '₹ —',
                          const Color(0xFF4ADE80)),
                      const SizedBox(width: 12),
                      _summaryChip('Pending', '₹ —',
                          const Color(0xFFFBBF24)),
                      const SizedBox(width: 12),
                      _summaryChip('Defaulters', '—',
                          const Color(0xFFF87171)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Placeholder stat cards ──────────────────────────────────────
            Row(
              children: [
                Expanded(
                    child: _statCard('Classes\nwith dues',
                        Icons.class_rounded, const Color(0xFF3B82F6))),
                const SizedBox(width: 12),
                Expanded(
                    child: _statCard('Paid\nthis month',
                        Icons.check_circle_rounded, const Color(0xFF059669))),
                const SizedBox(width: 12),
                Expanded(
                    child: _statCard('Overdue',
                        Icons.warning_amber_rounded,
                        const Color(0xFFD97706))),
              ],
            ),
            const SizedBox(height: 20),

            // ── Coming soon card ────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color:        Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color:      Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset:     const Offset(0, 2))
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color:  Color(0xFFF0FDF4),
                      shape:  BoxShape.circle,
                    ),
                    child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Color(0xFFF59E0B),
                        size: 28),
                  ),
                  const SizedBox(height: 16),
                  const Text('Fee Management',
                      style: TextStyle(
                          fontSize:   18,
                          fontWeight: FontWeight.w800,
                          color:      Color(0xFF0A0F1E))),
                  const SizedBox(height: 10),
                  Text(
                    'Full fee tracking, class-wise summaries, payment recording, '
                    'and parent payment reminders are coming soon.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 13,
                        color:    Colors.grey[500],
                        height:   1.6),
                  ),
                  const SizedBox(height: 20),
                  // Feature list
                  ...[
                    'Class-wise fee collection summary',
                    'Individual student payment history',
                    'Send payment reminders to parents',
                    'Record cash / online payments',
                    'Export fee reports as PDF',
                  ].map(
                    (f) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.radio_button_unchecked,
                              size: 14, color: Color(0xFFD1D5DB)),
                          const SizedBox(width: 10),
                          Text(f,
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey[500])),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _summaryChip(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color:        Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style:
                    const TextStyle(color: Colors.white70, fontSize: 10)),
            const SizedBox(height: 3),
            Text(value,
                style: TextStyle(
                    color:      color,
                    fontSize:   15,
                    fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }

  static Widget _statCard(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color:      Colors.black.withValues(alpha: 0.04),
              blurRadius: 8)
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color:        color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text('—',
              style: TextStyle(
                  fontSize:   20,
                  fontWeight: FontWeight.w800,
                  color:      color)),
          const SizedBox(height: 2),
          Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize:   10,
                  color:      Colors.grey[500],
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
