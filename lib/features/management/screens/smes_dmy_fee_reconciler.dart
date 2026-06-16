class SmesFeeReconciler {
  final String schoolId;
  final String academicYear;

  const SmesFeeReconciler({required this.schoolId, required this.academicYear});

  static double reconcile({
    required double expectedAmount,
    required double collectedAmount,
    required double waivedAmount,
    required double discountAmount,
  }) {
    final adjustedExpected = expectedAmount - waivedAmount - discountAmount;
    return adjustedExpected - collectedAmount;
  }

  static SmesReconciliationSummary summarize(List<Map<String, dynamic>> feeRecords) {
    double totalExpected = 0;
    double totalCollected = 0;
    double totalPending = 0;
    double totalWaived = 0;
    int fullyPaid = 0;
    int partiallyPaid = 0;
    int unpaid = 0;

    for (final rec in feeRecords) {
      final expected = ((rec['totalFee'] as num?) ?? 0).toDouble();
      final collected = ((rec['totalPaid'] as num?) ?? 0).toDouble();
      final waived = ((rec['waivedAmount'] as num?) ?? 0).toDouble();
      final pending = ((rec['totalPending'] as num?) ?? 0).toDouble();
      totalExpected += expected;
      totalCollected += collected;
      totalPending += pending;
      totalWaived += waived;
      final status = rec['status'] as String? ?? '';
      if (status == 'paid') {
        fullyPaid++;
      } else if (collected > 0) {
        partiallyPaid++;
      } else {
        unpaid++;
      }
    }

    return SmesReconciliationSummary(
      totalExpected: totalExpected,
      totalCollected: totalCollected,
      totalPending: totalPending,
      totalWaived: totalWaived,
      fullyPaidCount: fullyPaid,
      partiallyPaidCount: partiallyPaid,
      unpaidCount: unpaid,
    );
  }
}

class SmesReconciliationSummary {
  final double totalExpected;
  final double totalCollected;
  final double totalPending;
  final double totalWaived;
  final int fullyPaidCount;
  final int partiallyPaidCount;
  final int unpaidCount;

  const SmesReconciliationSummary({
    required this.totalExpected,
    required this.totalCollected,
    required this.totalPending,
    required this.totalWaived,
    required this.fullyPaidCount,
    required this.partiallyPaidCount,
    required this.unpaidCount,
  });

  int get totalStudents => fullyPaidCount + partiallyPaidCount + unpaidCount;
  double get collectionRate => totalExpected == 0 ? 0 : (totalCollected / totalExpected) * 100;
}
