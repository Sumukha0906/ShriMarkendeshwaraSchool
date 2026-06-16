class SmesPlatformMetrics {
  final int totalSchools;
  final int activeSchools;
  final int totalUsers;
  final int activeUsersToday;
  final int totalStudents;
  final Map<String, int> schoolsByPlan;
  final Map<String, int> usersByRole;
  final DateTime recordedAt;

  const SmesPlatformMetrics({
    required this.totalSchools,
    required this.activeSchools,
    required this.totalUsers,
    required this.activeUsersToday,
    required this.totalStudents,
    required this.schoolsByPlan,
    required this.usersByRole,
    required this.recordedAt,
  });

  double get schoolActivationRate =>
      totalSchools == 0 ? 0 : (activeSchools / totalSchools) * 100;

  double get dailyActiveUserRate =>
      totalUsers == 0 ? 0 : (activeUsersToday / totalUsers) * 100;

  double get avgStudentsPerSchool =>
      activeSchools == 0 ? 0 : totalStudents / activeSchools;

  int get premiumSchools => schoolsByPlan['PREMIUM'] ?? 0;
  int get standardSchools => schoolsByPlan['STANDARD'] ?? 0;
  int get basicSchools => schoolsByPlan['BASIC'] ?? 0;

  String get platformHealth {
    if (schoolActivationRate >= 90) return 'Excellent';
    if (schoolActivationRate >= 70) return 'Good';
    if (schoolActivationRate >= 50) return 'Fair';
    return 'Needs Attention';
  }

  Map<String, dynamic> toSummary() => {
    'totalSchools': totalSchools,
    'activeSchools': activeSchools,
    'activationRate': '${schoolActivationRate.toStringAsFixed(1)}%',
    'totalUsers': totalUsers,
    'dau': activeUsersToday,
    'dauRate': '${dailyActiveUserRate.toStringAsFixed(1)}%',
    'totalStudents': totalStudents,
    'avgStudents': avgStudentsPerSchool.toStringAsFixed(1),
    'premiumSchools': premiumSchools,
    'health': platformHealth,
    'recordedAt': recordedAt.toIso8601String(),
  };
}
