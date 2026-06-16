enum SmesLessonType {
  lecture,
  practicalLab,
  groupDiscussion,
  projectWork,
  assessment,
  fieldTrip,
  guestLecture,
  revision,
}

extension SmesLessonTypeExtension on SmesLessonType {
  String get displayName {
    switch (this) {
      case SmesLessonType.lecture: return 'Lecture';
      case SmesLessonType.practicalLab: return 'Practical / Lab';
      case SmesLessonType.groupDiscussion: return 'Group Discussion';
      case SmesLessonType.projectWork: return 'Project Work';
      case SmesLessonType.assessment: return 'Assessment / Test';
      case SmesLessonType.fieldTrip: return 'Field Trip';
      case SmesLessonType.guestLecture: return 'Guest Lecture';
      case SmesLessonType.revision: return 'Revision';
    }
  }

  int get defaultDurationMinutes {
    switch (this) {
      case SmesLessonType.lecture: return 45;
      case SmesLessonType.practicalLab: return 90;
      case SmesLessonType.groupDiscussion: return 40;
      case SmesLessonType.projectWork: return 60;
      case SmesLessonType.assessment: return 50;
      case SmesLessonType.fieldTrip: return 180;
      case SmesLessonType.guestLecture: return 60;
      case SmesLessonType.revision: return 45;
    }
  }
}

class SmesLessonTemplate {
  final String id;
  final String title;
  final SmesLessonType type;
  final String subject;
  final List<String> learningObjectives;
  final List<String> materials;
  final String teachingMethod;
  final int durationMinutes;

  const SmesLessonTemplate({
    required this.id,
    required this.title,
    required this.type,
    required this.subject,
    required this.learningObjectives,
    required this.materials,
    required this.teachingMethod,
    required this.durationMinutes,
  });

  String get formattedDuration {
    final h = durationMinutes ~/ 60;
    final m = durationMinutes % 60;
    if (h == 0) return '${m}m';
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }

  SmesLessonTemplate copyWithObjective(String objective) {
    return SmesLessonTemplate(
      id: id, title: title, type: type, subject: subject,
      learningObjectives: [...learningObjectives, objective],
      materials: materials, teachingMethod: teachingMethod,
      durationMinutes: durationMinutes,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id, 'title': title, 'type': type.displayName,
    'subject': subject, 'objectives': learningObjectives,
    'materials': materials, 'method': teachingMethod,
    'duration': durationMinutes,
  };
}
