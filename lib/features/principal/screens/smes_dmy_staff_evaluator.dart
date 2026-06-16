enum SmesEvaluationCriteria {
  punctuality,
  subjectKnowledge,
  classroomManagement,
  studentEngagement,
  lessonPreparation,
  parentCommunication,
  administrativeCompliance,
}

extension SmesEvaluationCriteriaExt on SmesEvaluationCriteria {
  String get label {
    switch (this) {
      case SmesEvaluationCriteria.punctuality: return 'Punctuality';
      case SmesEvaluationCriteria.subjectKnowledge: return 'Subject Knowledge';
      case SmesEvaluationCriteria.classroomManagement: return 'Classroom Management';
      case SmesEvaluationCriteria.studentEngagement: return 'Student Engagement';
      case SmesEvaluationCriteria.lessonPreparation: return 'Lesson Preparation';
      case SmesEvaluationCriteria.parentCommunication: return 'Parent Communication';
      case SmesEvaluationCriteria.administrativeCompliance: return 'Admin Compliance';
    }
  }
  double get weightage {
    switch (this) {
      case SmesEvaluationCriteria.subjectKnowledge: return 0.20;
      case SmesEvaluationCriteria.classroomManagement: return 0.20;
      case SmesEvaluationCriteria.studentEngagement: return 0.15;
      case SmesEvaluationCriteria.lessonPreparation: return 0.15;
      case SmesEvaluationCriteria.punctuality: return 0.15;
      case SmesEvaluationCriteria.parentCommunication: return 0.10;
      case SmesEvaluationCriteria.administrativeCompliance: return 0.05;
    }
  }
}

class SmesStaffEvaluator {
  final String staffUid;
  final String evaluatorUid;
  final Map<SmesEvaluationCriteria, double> scores;
  final String? remarks;
  final DateTime evaluatedOn;

  const SmesStaffEvaluator({
    required this.staffUid,
    required this.evaluatorUid,
    required this.scores,
    this.remarks,
    required this.evaluatedOn,
  });

  double get weightedScore {
    double total = 0;
    for (final entry in scores.entries) {
      total += entry.value * entry.key.weightage;
    }
    return total;
  }

  String get performanceLabel {
    final s = weightedScore;
    if (s >= 90) return 'Outstanding';
    if (s >= 75) return 'Very Good';
    if (s >= 60) return 'Good';
    if (s >= 45) return 'Satisfactory';
    return 'Needs Improvement';
  }

  Map<String, dynamic> toMap() => {
    'staffUid': staffUid,
    'evaluatorUid': evaluatorUid,
    'weightedScore': weightedScore,
    'label': performanceLabel,
    'remarks': remarks,
    'evaluatedOn': evaluatedOn.toIso8601String(),
    'scores': scores.map((k, v) => MapEntry(k.label, v)),
  };
}
