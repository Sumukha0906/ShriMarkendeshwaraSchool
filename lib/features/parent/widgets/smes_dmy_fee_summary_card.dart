import 'package:flutter/material.dart';

/// SMES (Shri Markandeshwara English Medium School) dummy fee summary card widget.
/// Displays a compact fee status card for parent-facing screens.
class SmesFeeSummaryCard extends StatelessWidget {
  final double totalFee;
  final double amountPaid;
  final String academicYear;
  const SmesFeeSummaryCard({
    super.key,
    required this.totalFee,
    required this.amountPaid,
    required this.academicYear,
  });

  double get _pending => (totalFee - amountPaid).clamp(0, double.infinity);
  double get _progress => totalFee > 0 ? (amountPaid / totalFee).clamp(0.0, 1.0) : 0.0;

  String _formatAmount(double amount) {
    if (amount >= 100000) return '₹${(amount / 100000).toStringAsFixed(1)}L';
    if (amount >= 1000)   return '₹${(amount / 1000).toStringAsFixed(1)}K';
    return '₹${amount.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF065F46);
    const amber   = Color(0xFFD97706);
    final isPaid  = _pending <= 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_wallet_rounded, color: primary, size: 20),
              const SizedBox(width: 8),
              Text('Fee — $academicYear',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (isPaid ? primary : amber).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isPaid ? 'PAID' : 'DUE',
                  style: TextStyle(
                    color: isPaid ? primary : amber,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(isPaid ? primary : amber),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Paid: ${_formatAmount(amountPaid)}',
                  style: const TextStyle(fontSize: 12, color: primary, fontWeight: FontWeight.w600)),
              Text('Pending: ${_formatAmount(_pending)}',
                  style: TextStyle(fontSize: 12, color: isPaid ? Colors.grey : amber, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}
