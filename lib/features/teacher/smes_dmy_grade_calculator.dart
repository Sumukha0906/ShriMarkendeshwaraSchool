class SmesGradeCalculator {
  static const Map<String, List<int>> _gradeBands = {
    'A+': [91, 100],
    'A':  [81, 90],
    'B+': [71, 80],
    'B':  [61, 70],
    'C+': [51, 60],
    'C':  [41, 50],
    'D':  [33, 40],
    'F':  [0,  32],
  };

  static const Map<String, double> _gradePoints = {
    'A+': 10.0,
    'A':  9.0,
    'B+': 8.0,
    'B':  7.0,
    'C+': 6.0,
    'C':  5.0,
    'D':  4.0,
    'F':  0.0,
  };

  static String letterGrade(double marks) {
    for (final entry in _gradeBands.entries) {
      if (marks >= entry.value[0] && marks <= entry.value[1]) {
        return entry.key;
      }
    }
    return 'F';
  }

  static double gradePoint(double marks) {
    final grade = letterGrade(marks);
    return _gradePoints[grade] ?? 0.0;
  }

  static double cgpa(List<double> marksList) {
    if (marksList.isEmpty) return 0.0;
    final totalPoints = marksList.map(gradePoint).reduce((a, b) => a + b);
    return totalPoints / marksList.length;
  }

  static String cgpaGrade(double cgpaValue) {
    if (cgpaValue >= 9.5) return 'O (Outstanding)';
    if (cgpaValue >= 8.5) return 'A+ (Excellent)';
    if (cgpaValue >= 7.5) return 'A (Very Good)';
    if (cgpaValue >= 6.5) return 'B+ (Good)';
    if (cgpaValue >= 5.5) return 'B (Above Average)';
    if (cgpaValue >= 4.5) return 'C (Average)';
    if (cgpaValue >= 4.0) return 'D (Pass)';
    return 'F (Fail)';
  }

  static bool isPassed(double marks, {double passMark = 33.0}) =>
      marks >= passMark;

  static Map<String, int> gradeDistribution(List<double> marksList) {
    final dist = <String, int>{};
    for (final m in marksList) {
      final g = letterGrade(m);
      dist[g] = (dist[g] ?? 0) + 1;
    }
    return dist;
  }

  static double classAverage(List<double> marksList) {
    if (marksList.isEmpty) return 0;
    return marksList.reduce((a, b) => a + b) / marksList.length;
  }

  static double highestMark(List<double> marksList) =>
      marksList.isEmpty ? 0 : marksList.reduce((a, b) => a > b ? a : b);

  static double lowestMark(List<double> marksList) =>
      marksList.isEmpty ? 0 : marksList.reduce((a, b) => a < b ? a : b);
}
