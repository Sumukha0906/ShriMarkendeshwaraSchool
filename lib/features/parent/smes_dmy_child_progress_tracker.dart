class SmesChildProgressTracker {
  final String studentId;
  final String studentName;
  final String className;
  final Map<String, double> subjectMarks;
  final int totalAbsences;
  final int totalWorkingDays;
  final List<String> pendingFeeTerms;

  const SmesChildProgressTracker({
    required this.studentId,
    required this.studentName,
    required this.className,
    required this.subjectMarks,
    required this.totalAbsences,
    required this.totalWorkingDays,
    required this.pendingFeeTerms,
  });

  double get attendancePercentage {
    if (totalWorkingDays == 0) return 0;
    final present = totalWorkingDays - totalAbsences;
    return (present / totalWorkingDays) * 100;
  }

  bool get hasLowAttendance => attendancePercentage < 75;

  double get overallAverage {
    if (subjectMarks.isEmpty) return 0;
    return subjectMarks.values.reduce((a, b) => a + b) / subjectMarks.length;
  }

  String get performanceBand {
    final avg = overallAverage;
    if (avg >= 85) return 'Excellent';
    if (avg >= 70) return 'Good';
    if (avg >= 50) return 'Average';
    if (avg >= 33) return 'Below Average';
    return 'Needs Improvement';
  }

  bool get hasPendingFees => pendingFeeTerms.isNotEmpty;

  String get weakestSubject {
    if (subjectMarks.isEmpty) return 'N/A';
    return subjectMarks.entries
        .reduce((a, b) => a.value < b.value ? a : b)
        .key;
  }

  String get strongestSubject {
    if (subjectMarks.isEmpty) return 'N/A';
    return subjectMarks.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  List<String> get alerts {
    final issues = <String>[];
    if (hasLowAttendance) issues.add('Low attendance: ${attendancePercentage.toStringAsFixed(1)}%');
    if (hasPendingFees) issues.add('Pending fees: ${pendingFeeTerms.join(", ")}');
    if (overallAverage < 40) issues.add('Academic performance needs attention');
    return issues;
  }
}
