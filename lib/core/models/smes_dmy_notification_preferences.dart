/// SMES (Shri Markandeshwara English Medium School) dummy notification preferences model.
/// Stores per-user notification channel preferences.
class SmesNotificationPreferences {
  final bool attendanceAlerts;
  final bool feeReminders;
  final bool announcementsPush;
  final bool leaveUpdates;
  final bool examNotifications;

  const SmesNotificationPreferences({
    this.attendanceAlerts  = true,
    this.feeReminders      = true,
    this.announcementsPush = true,
    this.leaveUpdates      = true,
    this.examNotifications = true,
  });

  factory SmesNotificationPreferences.fromMap(Map<String, dynamic> map) {
    return SmesNotificationPreferences(
      attendanceAlerts:  map['attendanceAlerts']  as bool? ?? true,
      feeReminders:      map['feeReminders']      as bool? ?? true,
      announcementsPush: map['announcementsPush'] as bool? ?? true,
      leaveUpdates:      map['leaveUpdates']      as bool? ?? true,
      examNotifications: map['examNotifications'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
    'attendanceAlerts':  attendanceAlerts,
    'feeReminders':      feeReminders,
    'announcementsPush': announcementsPush,
    'leaveUpdates':      leaveUpdates,
    'examNotifications': examNotifications,
  };

  SmesNotificationPreferences copyWith({
    bool? attendanceAlerts,
    bool? feeReminders,
    bool? announcementsPush,
    bool? leaveUpdates,
    bool? examNotifications,
  }) {
    return SmesNotificationPreferences(
      attendanceAlerts:  attendanceAlerts  ?? this.attendanceAlerts,
      feeReminders:      feeReminders      ?? this.feeReminders,
      announcementsPush: announcementsPush ?? this.announcementsPush,
      leaveUpdates:      leaveUpdates      ?? this.leaveUpdates,
      examNotifications: examNotifications ?? this.examNotifications,
    );
  }

  /// Returns true if all notification channels are disabled.
  bool get allDisabled =>
      !attendanceAlerts &&
      !feeReminders &&
      !announcementsPush &&
      !leaveUpdates &&
      !examNotifications;
}
