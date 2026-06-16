class SmesGradeBands {
  static const Map<String, Map<String, dynamic>> cbse = {
    'A1': {'min': 91, 'max': 100, 'points': 10.0, 'remark': 'Outstanding'},
    'A2': {'min': 81, 'max': 90,  'points': 9.0,  'remark': 'Excellent'},
    'B1': {'min': 71, 'max': 80,  'points': 8.0,  'remark': 'Very Good'},
    'B2': {'min': 61, 'max': 70,  'points': 7.0,  'remark': 'Good'},
    'C1': {'min': 51, 'max': 60,  'points': 6.0,  'remark': 'Above Average'},
    'C2': {'min': 41, 'max': 50,  'points': 5.0,  'remark': 'Average'},
    'D':  {'min': 33, 'max': 40,  'points': 4.0,  'remark': 'Pass'},
    'E':  {'min': 0,  'max': 32,  'points': 0.0,  'remark': 'Needs Improvement'},
  };

  static const Map<String, Map<String, dynamic>> icse = {
    'A': {'min': 75, 'max': 100, 'points': 9.0, 'remark': 'Distinction'},
    'B': {'min': 60, 'max': 74,  'points': 7.0, 'remark': 'First Class'},
    'C': {'min': 45, 'max': 59,  'points': 5.0, 'remark': 'Second Class'},
    'D': {'min': 33, 'max': 44,  'points': 4.0, 'remark': 'Pass'},
    'F': {'min': 0,  'max': 32,  'points': 0.0, 'remark': 'Fail'},
  };

  static const List<String> subjectCodes = [
    'ENG', 'HIN', 'MAT', 'SCI', 'SST',
    'GUJ', 'MRT', 'COM', 'PHY', 'CHE',
    'BIO', 'HIS', 'GEO', 'ECO', 'ART',
  ];

  static const Map<String, String> subjectNames = {
    'ENG': 'English', 'HIN': 'Hindi', 'MAT': 'Mathematics',
    'SCI': 'Science', 'SST': 'Social Studies', 'GUJ': 'Gujarati',
    'MRT': 'Marathi', 'COM': 'Computer Science', 'PHY': 'Physics',
    'CHE': 'Chemistry', 'BIO': 'Biology', 'HIS': 'History',
    'GEO': 'Geography', 'ECO': 'Economics', 'ART': 'Art & Craft',
  };

  static String gradeForMarks(double marks, {bool useCbse = true}) {
    final bands = useCbse ? cbse : icse;
    for (final entry in bands.entries) {
      final min = entry.value['min'] as int;
      final max = entry.value['max'] as int;
      if (marks >= min && marks <= max) return entry.key;
    }
    return 'F';
  }

  static String remarkForGrade(String grade, {bool useCbse = true}) {
    final bands = useCbse ? cbse : icse;
    return (bands[grade]?['remark'] as String?) ?? 'N/A';
  }

  static double gradePointForMarks(double marks, {bool useCbse = true}) {
    final grade = gradeForMarks(marks, useCbse: useCbse);
    final bands = useCbse ? cbse : icse;
    return ((bands[grade]?['points']) as num?)?.toDouble() ?? 0.0;
  }
}
