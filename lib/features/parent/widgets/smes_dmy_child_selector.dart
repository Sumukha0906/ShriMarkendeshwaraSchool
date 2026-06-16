import 'package:flutter/material.dart';

/// SMES (Shri Markandeshwara English Medium School) dummy child selector widget.
/// A horizontal chip row for parents who have multiple enrolled children.
class SmesChildSelector extends StatelessWidget {
  final List<SmesChildInfo> children;
  final String selectedChildId;
  final void Function(String childId) onSelect;

  const SmesChildSelector({
    super.key,
    required this.children,
    required this.selectedChildId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: children.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final child = children[i];
          final selected = child.id == selectedChildId;
          return GestureDetector(
            onTap: () => onSelect(child.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF065F46)
                    : const Color(0xFF065F46).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: selected
                      ? const Color(0xFF065F46)
                      : const Color(0xFF065F46).withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                child.name,
                style: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF065F46),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class SmesChildInfo {
  final String id;
  final String name;
  final String className;

  const SmesChildInfo({
    required this.id,
    required this.name,
    required this.className,
  });
}
