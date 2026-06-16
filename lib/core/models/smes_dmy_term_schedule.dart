enum SmesTerm { firstTerm, secondTerm, thirdTerm, annual }

extension SmesTermExtension on SmesTerm {
  String get displayName {
    switch (this) {
      case SmesTerm.firstTerm:  return 'First Term';
      case SmesTerm.secondTerm: return 'Second Term';
      case SmesTerm.thirdTerm:  return 'Third Term';
      case SmesTerm.annual:     return 'Annual Exam';
    }
  }

  String get shortCode {
    switch (this) {
      case SmesTerm.firstTerm:  return 'T1';
      case SmesTerm.secondTerm: return 'T2';
      case SmesTerm.thirdTerm:  return 'T3';
      case SmesTerm.annual:     return 'AE';
    }
  }
}

class SmesTermSchedule {
  final String id;
  final String schoolId;
  final String academicYear;
  final SmesTerm term;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime? examStartDate;
  final DateTime? examEndDate;
  final DateTime? resultDate;
  final bool isActive;

  const SmesTermSchedule({
    required this.id,
    required this.schoolId,
    required this.academicYear,
    required this.term,
    required this.startDate,
    required this.endDate,
    this.examStartDate,
    this.examEndDate,
    this.resultDate,
    this.isActive = false,
  });

  int get totalWorkingDays {
    int count = 0;
    DateTime current = startDate;
    while (!current.isAfter(endDate)) {
      if (current.weekday != DateTime.saturday &&
          current.weekday != DateTime.sunday) {
        count++;
      }
      current = current.add(const Duration(days: 1));
    }
    return count;
  }

  int get daysRemaining {
    final today = DateTime.now();
    if (today.isAfter(endDate)) return 0;
    return endDate.difference(today).inDays;
  }

  bool get isOngoing {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  bool get hasExams => examStartDate != null;

  Map<String, dynamic> toMap() => {
    'id': id,
    'schoolId': schoolId,
    'academicYear': academicYear,
    'term': term.shortCode,
    'termName': term.displayName,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'workingDays': totalWorkingDays,
    'isActive': isActive,
    if (examStartDate != null) 'examStart': examStartDate!.toIso8601String(),
    if (examEndDate != null)   'examEnd': examEndDate!.toIso8601String(),
    if (resultDate != null)    'resultDate': resultDate!.toIso8601String(),
  };
}
