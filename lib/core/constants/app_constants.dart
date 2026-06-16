class AppConstants {
  // Academic
  static const String currentAcademicYear = '2026-27';

  // Invite expiry
  static const int inviteExpiryHours = 48;

  // Attendance session types
  static const String sessionMorning   = 'morning';
  static const String sessionAfternoon = 'afternoon';

  // Pagination
  static const int defaultPageSize = 50;

  // Message preview length for SMS/WhatsApp logs
  static const int messagePreviewLength = 200;

  // Days of week
  static const List<String> schoolDays = [
    'Monday', 'Tuesday', 'Wednesday',
    'Thursday', 'Friday', 'Saturday'
  ];

  // Fee heads (default — admin can customise per school)
  static const List<String> defaultFeeHeads = [
    'Tuition Fee',
    'Transport Fee',
    'Lab Fee',
    'Library Fee',
    'Sports Fee',
  ];

  // Notification types grouped for UI display
  static const List<String> attendanceNotifTypes = [
    'ATTENDANCE_MARKED',
    'ATTENDANCE_UPDATED',
    'STUDENT_ABSENT',
  ];

  static const List<String> leaveNotifTypes = [
    'LEAVE_SUBMITTED',
    'LEAVE_APPROVED',
    'LEAVE_REJECTED',
  ];
}