class SmesSchoolHealthScore {
  final double attendanceScore;
  final double feeCollectionScore;
  final double academicScore;
  final double staffPresenceScore;
  final double communicationScore;

  const SmesSchoolHealthScore({
    required this.attendanceScore,
    required this.feeCollectionScore,
    required this.academicScore,
    required this.staffPresenceScore,
    required this.communicationScore,
  });

  double get overallScore {
    return (attendanceScore * 0.25) +
           (feeCollectionScore * 0.25) +
           (academicScore * 0.25) +
           (staffPresenceScore * 0.15) +
           (communicationScore * 0.10);
  }

  String get healthLabel {
    final score = overallScore;
    if (score >= 90) return 'Excellent';
    if (score >= 75) return 'Good';
    if (score >= 60) return 'Satisfactory';
    if (score >= 45) return 'Needs Attention';
    return 'Critical';
  }

  List<String> get areasOfConcern {
    final concerns = <String>[];
    if (attendanceScore < 70)      concerns.add('Student attendance is low');
    if (feeCollectionScore < 60)   concerns.add('Fee collection needs improvement');
    if (academicScore < 60)        concerns.add('Academic performance is below par');
    if (staffPresenceScore < 80)   concerns.add('Staff attendance issues detected');
    if (communicationScore < 50)   concerns.add('Parent-school communication is low');
    return concerns;
  }

  Map<String, double> get breakdown => {
    'Student Attendance': attendanceScore,
    'Fee Collection': feeCollectionScore,
    'Academics': academicScore,
    'Staff Presence': staffPresenceScore,
    'Communication': communicationScore,
    'Overall': overallScore,
  };

  factory SmesSchoolHealthScore.fromRawData({
    required int totalStudents,
    required int presentToday,
    required double totalFees,
    required double collectedFees,
    required double avgMarks,
    required int totalStaff,
    required int staffPresent,
    required int announcementsThisMonth,
  }) {
    final attendance = totalStudents == 0 ? 0.0 : (presentToday / totalStudents) * 100;
    final feeCollection = totalFees == 0 ? 100.0 : (collectedFees / totalFees) * 100;
    final academic = avgMarks.clamp(0, 100).toDouble();
    final staffPresence = totalStaff == 0 ? 0.0 : (staffPresent / totalStaff) * 100;
    final communication = (announcementsThisMonth * 10).clamp(0, 100).toDouble();
    return SmesSchoolHealthScore(
      attendanceScore: attendance,
      feeCollectionScore: feeCollection,
      academicScore: academic,
      staffPresenceScore: staffPresence,
      communicationScore: communication,
    );
  }
}
