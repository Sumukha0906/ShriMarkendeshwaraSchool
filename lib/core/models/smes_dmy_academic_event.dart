/// SMES (Shri Markandeshwara English Medium School) dummy academic event model.
/// Represents school calendar events like exams, holidays, and functions.
enum SmesEventType {
  exam,
  holiday,
  schoolFunction,
  ptm,           // Parent-Teacher Meeting
  sportsDay,
  other,
}

class SmesAcademicEvent {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime? endDate;
  final SmesEventType type;
  final String schoolId;
  final String createdByUid;

  const SmesAcademicEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    this.endDate,
    required this.type,
    required this.schoolId,
    required this.createdByUid,
  });

  factory SmesAcademicEvent.fromMap(Map<String, dynamic> map) {
    return SmesAcademicEvent(
      id:           map['id']           as String,
      title:        map['title']        as String,
      description:  map['description']  as String? ?? '',
      startDate:    DateTime.parse(map['startDate'] as String),
      endDate:      map['endDate'] != null ? DateTime.parse(map['endDate'] as String) : null,
      type:         SmesEventType.values.firstWhere(
                      (e) => e.name == (map['type'] as String? ?? 'other'),
                      orElse: () => SmesEventType.other),
      schoolId:     map['schoolId']     as String,
      createdByUid: map['createdByUid'] as String,
    );
  }

  Map<String, dynamic> toMap() => {
    'id':           id,
    'title':        title,
    'description':  description,
    'startDate':    startDate.toIso8601String(),
    'endDate':      endDate?.toIso8601String(),
    'type':         type.name,
    'schoolId':     schoolId,
    'createdByUid': createdByUid,
  };

  /// Returns the number of days this event spans (minimum 1).
  int get durationDays {
    if (endDate == null) return 1;
    return endDate!.difference(startDate).inDays + 1;
  }

  /// Returns true if this event falls on a given date.
  bool occursOn(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    final s = DateTime(startDate.year, startDate.month, startDate.day);
    final e = endDate != null
        ? DateTime(endDate!.year, endDate!.month, endDate!.day)
        : s;
    return !d.isBefore(s) && !d.isAfter(e);
  }
}
