import 'dart:math';
import 'package:flutter/material.dart';

/// SMES (Shri Markandeshwara English Medium School) dummy school stats chart.
/// Renders a simple bar chart for principal-level school statistics.
class SmesSchoolStatsChart extends StatelessWidget {
  final List<SmesStatBar> bars;
  final double maxHeight;

  const SmesSchoolStatsChart({
    super.key,
    required this.bars,
    this.maxHeight = 120,
  });

  @override
  Widget build(BuildContext context) {
    final maxValue = bars.map((b) => b.value).fold(0.0, max);
    return SizedBox(
      height: maxHeight + 32,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: bars.map((bar) {
          final fraction = maxValue > 0 ? bar.value / maxValue : 0.0;
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                bar.value.toStringAsFixed(0),
                style: TextStyle(fontSize: 10, color: bar.color, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
                width: 28,
                height: maxHeight * fraction,
                decoration: BoxDecoration(
                  color: bar.color,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                bar.label,
                style: TextStyle(fontSize: 9, color: Colors.grey[600]),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class SmesStatBar {
  final String label;
  final double value;
  final Color color;

  const SmesStatBar({
    required this.label,
    required this.value,
    this.color = const Color(0xFF065F46),
  });
}
