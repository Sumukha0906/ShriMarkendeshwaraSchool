enum SmesStaffQualification {
  belowGraduate,
  graduate,
  postGraduate,
  mPhil,
  phD,
  bEd,
  mEd,
}

extension SmesStaffQualificationExt on SmesStaffQualification {
  String get label {
    switch (this) {
      case SmesStaffQualification.belowGraduate: return 'Below Graduate';
      case SmesStaffQualification.graduate:      return 'Graduate (B.A/B.Sc/B.Com)';
      case SmesStaffQualification.postGraduate:  return 'Post Graduate (M.A/M.Sc)';
      case SmesStaffQualification.mPhil:         return 'M.Phil';
      case SmesStaffQualification.phD:           return 'Ph.D';
      case SmesStaffQualification.bEd:           return 'B.Ed';
      case SmesStaffQualification.mEd:           return 'M.Ed';
    }
  }
}

class SmesStaffProfileExtension {
  final String uid;
  final List<SmesStaffQualification> qualifications;
  final List<String> subjectsCanTeach;
  final int experienceYears;
  final String? previousSchool;
  final DateTime joinedOn;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String bloodGroup;
  final String? aadhaarLast4;

  const SmesStaffProfileExtension({
    required this.uid,
    required this.qualifications,
    required this.subjectsCanTeach,
    required this.experienceYears,
    required this.joinedOn,
    required this.bloodGroup,
    this.previousSchool,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.aadhaarLast4,
  });

  bool get isExperienced => experienceYears >= 5;

  String get highestQualification {
    const order = [
      SmesStaffQualification.phD,
      SmesStaffQualification.mPhil,
      SmesStaffQualification.mEd,
      SmesStaffQualification.postGraduate,
      SmesStaffQualification.bEd,
      SmesStaffQualification.graduate,
      SmesStaffQualification.belowGraduate,
    ];
    for (final q in order) {
      if (qualifications.contains(q)) return q.label;
    }
    return 'Not specified';
  }

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'qualifications': qualifications.map((q) => q.label).toList(),
    'highestQualification': highestQualification,
    'subjectsCanTeach': subjectsCanTeach,
    'experienceYears': experienceYears,
    'joinedOn': joinedOn.toIso8601String(),
    'bloodGroup': bloodGroup,
    if (previousSchool != null) 'previousSchool': previousSchool,
    if (aadhaarLast4 != null) 'aadhaarLast4': aadhaarLast4,
  };
}
