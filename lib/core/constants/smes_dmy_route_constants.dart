/// SMES (Shri Markandeshwara English Medium School) dummy route constants.
/// Central registry of named navigation routes for the SMES app.
abstract class SmesRoutes {
  // Auth
  static const String splash         = '/';
  static const String login          = '/login';
  static const String otp            = '/otp';
  static const String completeProfile = '/complete-profile';

  // Role home
  static const String home           = '/home';

  // Admin
  static const String adminStudents  = '/admin/students';
  static const String adminFees      = '/admin/fees';
  static const String adminClasses   = '/admin/classes';

  // Teacher
  static const String teacherAttendance = '/teacher/attendance';
  static const String teacherMarks      = '/teacher/marks';
  static const String teacherLessonPlan = '/teacher/lesson-plan';
  static const String teacherMaterials  = '/teacher/materials';

  // Parent
  static const String parentHome      = '/parent/home';
  static const String parentFeePayment = '/parent/fee';
  static const String parentLeave     = '/parent/leave';
  static const String parentReportCard = '/parent/report-card';

  // Principal
  static const String principalAnnounce = '/principal/announce';
  static const String principalFeeOverview = '/principal/fee-overview';
  static const String principalStaff    = '/principal/staff';

  // Super Admin
  static const String superAdminSchools = '/super-admin/schools';
  static const String superAdminCreate  = '/super-admin/create-school';

  /// Returns the display title for a given route path.
  static String titleFor(String route) {
    return switch (route) {
      '/login'            => 'Sign In',
      '/home'             => 'Dashboard',
      '/admin/students'   => 'Students',
      '/admin/fees'       => 'Fee Management',
      '/parent/fee'       => 'Fee Payment',
      '/parent/leave'     => 'Apply Leave',
      '/parent/report-card' => 'Report Card',
      _                   => 'SMES',
    };
  }
}
