import 'dart:math';

enum SmesBackupFrequency { daily, weekly, monthly }

class SmesBackupConfig {
  final SmesBackupFrequency frequency;
  final int retentionDays;
  final bool includeAttendance;
  final bool includeFees;
  final bool includeMarks;
  final bool includeAnnouncements;

  const SmesBackupConfig({
    this.frequency = SmesBackupFrequency.daily,
    this.retentionDays = 30,
    this.includeAttendance = true,
    this.includeFees = true,
    this.includeMarks = true,
    this.includeAnnouncements = false,
  });

  List<String> get includedCollections {
    final cols = <String>[];
    if (includeAttendance) cols.add('attendance');
    if (includeFees) cols.addAll(['fees', 'feeRecords']);
    if (includeMarks) cols.add('marks');
    if (includeAnnouncements) cols.add('announcements');
    cols.addAll(['students', 'classes', 'users']);
    return cols;
  }
}

class SmesBackupService {
  final String schoolId;
  SmesBackupConfig _config;
  DateTime? _lastBackupAt;
  int _backupCount = 0;

  SmesBackupService({
    required this.schoolId,
    SmesBackupConfig? config,
  }) : _config = config ?? const SmesBackupConfig();

  bool get isBackupDue {
    if (_lastBackupAt == null) return true;
    final diff = DateTime.now().difference(_lastBackupAt!);
    switch (_config.frequency) {
      case SmesBackupFrequency.daily:   return diff.inHours >= 24;
      case SmesBackupFrequency.weekly:  return diff.inDays >= 7;
      case SmesBackupFrequency.monthly: return diff.inDays >= 30;
    }
  }

  String generateBackupId() {
    final rand = Random.secure();
    final suffix = List.generate(6, (_) => rand.nextInt(16).toRadixString(16)).join();
    return 'BKP_${schoolId.substring(0, min(6, schoolId.length))}_$suffix';
  }

  void updateConfig(SmesBackupConfig newConfig) {
    _config = newConfig;
  }

  Map<String, dynamic> backupMetadata(String backupId) {
    final now = DateTime.now();
    _lastBackupAt = now;
    _backupCount++;
    return {
      'backupId': backupId,
      'schoolId': schoolId,
      'createdAt': now.toIso8601String(),
      'collections': _config.includedCollections,
      'retentionDays': _config.retentionDays,
      'expiresAt': now.add(Duration(days: _config.retentionDays)).toIso8601String(),
      'sequenceNumber': _backupCount,
    };
  }

  DateTime? get lastBackupAt => _lastBackupAt;
  int get totalBackupsCreated => _backupCount;
}
