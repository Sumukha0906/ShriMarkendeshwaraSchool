import 'package:flutter/material.dart';

/// SMES (Shri Markandeshwara English Medium School) dummy budget tracker widget.
/// Shows an annual budget vs. expenditure summary for management users.
class SmesBudgetTracker extends StatelessWidget {
  final double annualBudget;
  final double totalSpent;
  final List<SmesBudgetCategory> categories;

  const SmesBudgetTracker({
    super.key,
    required this.annualBudget,
    required this.totalSpent,
    required this.categories,
  });

  double get _utilisation =>
      annualBudget > 0 ? (totalSpent / annualBudget).clamp(0.0, 1.0) : 0.0;

  String _fmt(double v) {
    if (v >= 100000) return '₹${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000)   return '₹${(v / 1000).toStringAsFixed(1)}K';
    return '₹${v.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF065F46);
    const amber   = Color(0xFFD97706);
    final overBudget = totalSpent > annualBudget;
    final barColor = overBudget ? const Color(0xFFDC2626) : primary;

    return Container(
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
              const Icon(Icons.pie_chart_rounded, color: primary, size: 20),
              const SizedBox(width: 8),
              const Text('Annual Budget',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              const Spacer(),
              Text('${(_utilisation * 100).toStringAsFixed(1)}% used',
                  style: TextStyle(
                      fontSize: 12,
                      color: overBudget ? const Color(0xFFDC2626) : Colors.grey[500],
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: _utilisation,
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Spent: ${_fmt(totalSpent)}',
                  style: TextStyle(fontSize: 12, color: barColor, fontWeight: FontWeight.w600)),
              Text('Budget: ${_fmt(annualBudget)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            ],
          ),
          if (categories.isNotEmpty) ...[
            const Divider(height: 20),
            ...categories.take(4).map((cat) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const DecoratedBox(
                    decoration: BoxDecoration(color: amber, shape: BoxShape.circle),
                    child: SizedBox(width: 10, height: 10),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(cat.name,
                        style: const TextStyle(fontSize: 12)),
                  ),
                  Text(_fmt(cat.amount),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }
}

class SmesBudgetCategory {
  final String name;
  final double amount;

  const SmesBudgetCategory({required this.name, required this.amount});
}
