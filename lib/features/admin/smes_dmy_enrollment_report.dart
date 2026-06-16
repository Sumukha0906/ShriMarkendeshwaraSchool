class SmesEnrollmentReport {
  final String schoolId;
  final String academicYear;
  final Map<String, int> classwiseCount;
  final int totalBoys;
  final int totalGirls;
  final DateTime generatedAt;

  const SmesEnrollmentReport({
    required this.schoolId,
    required this.academicYear,
    required this.classwiseCount,
    required this.totalBoys,
    required this.totalGirls,
    required this.generatedAt,
  });

  int get totalStudents => totalBoys + totalGirls;

  double get genderRatio =>
      totalGirls == 0 ? 0 : totalBoys / totalGirls;

  String get formattedRatio {
    final r = genderRatio;
    return '${r.toStringAsFixed(2)} : 1 (B:G)';
  }

  int get totalClasses => classwiseCount.length;

  double get averageClassSize =>
      totalClasses == 0 ? 0 : totalStudents / totalClasses;

  String get largestClass {
    if (classwiseCount.isEmpty) return 'N/A';
    return classwiseCount.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  String get smallestClass {
    if (classwiseCount.isEmpty) return 'N/A';
    return classwiseCount.entries
        .reduce((a, b) => a.value < b.value ? a : b)
        .key;
  }

  Map<String, dynamic> toSummaryMap() => {
    'schoolId': schoolId,
    'academicYear': academicYear,
    'totalStudents': totalStudents,
    'totalBoys': totalBoys,
    'totalGirls': totalGirls,
    'genderRatio': formattedRatio,
    'totalClasses': totalClasses,
    'avgClassSize': averageClassSize.toStringAsFixed(1),
    'largestClass': largestClass,
    'generatedAt': generatedAt.toIso8601String(),
  };

  SmesEnrollmentReport copyWith({int? additionalBoys, int? additionalGirls}) {
    return SmesEnrollmentReport(
      schoolId: schoolId,
      academicYear: academicYear,
      classwiseCount: classwiseCount,
      totalBoys: totalBoys + (additionalBoys ?? 0),
      totalGirls: totalGirls + (additionalGirls ?? 0),
      generatedAt: generatedAt,
    );
  }
}
