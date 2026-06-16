class SmesBudgetPlanner {
  final String schoolId;
  final String academicYear;
  final Map<String, double> allocations;
  final Map<String, double> actualSpend;

  const SmesBudgetPlanner({
    required this.schoolId,
    required this.academicYear,
    required this.allocations,
    required this.actualSpend,
  });

  double get totalAllocated =>
      allocations.values.fold(0, (a, b) => a + b);

  double get totalSpent =>
      actualSpend.values.fold(0, (a, b) => a + b);

  double get totalRemaining => totalAllocated - totalSpent;

  double get utilizationRate =>
      totalAllocated == 0 ? 0 : (totalSpent / totalAllocated) * 100;

  bool get isOverBudget => totalSpent > totalAllocated;

  Map<String, double> get categoryVariance {
    final result = <String, double>{};
    for (final cat in allocations.keys) {
      final alloc = allocations[cat] ?? 0;
      final spent = actualSpend[cat] ?? 0;
      result[cat] = alloc - spent;
    }
    return result;
  }

  List<String> get overSpentCategories {
    return categoryVariance.entries
        .where((e) => e.value < 0)
        .map((e) => e.key)
        .toList();
  }

  List<String> get underUtilizedCategories {
    return categoryVariance.entries
        .where((e) => e.value > (allocations[e.key] ?? 0) * 0.3)
        .map((e) => e.key)
        .toList();
  }

  String get budgetStatus {
    if (isOverBudget) return 'Over Budget';
    if (utilizationRate > 85) return 'Near Limit';
    if (utilizationRate > 50) return 'On Track';
    return 'Under Utilized';
  }

  SmesBudgetPlanner addSpend(String category, double amount) {
    final updated = Map<String, double>.from(actualSpend);
    updated[category] = (updated[category] ?? 0) + amount;
    return SmesBudgetPlanner(
      schoolId: schoolId,
      academicYear: academicYear,
      allocations: allocations,
      actualSpend: updated,
    );
  }
}
