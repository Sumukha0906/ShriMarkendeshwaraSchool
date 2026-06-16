enum SmesReportFormat { pdf, csv, json }
enum SmesReportType {
  feeStatement,
  attendanceSummary,
  marksheet,
  classProgress,
  staffSummary,
  expenseSummary,
}

abstract class SmesReportGenerator {
  final String schoolId;
  final String generatedByUid;
  final SmesReportFormat format;

  const SmesReportGenerator({
    required this.schoolId,
    required this.generatedByUid,
    required this.format,
  });

  Future<List<int>> generate(SmesReportRequest request);

  String get mimeType {
    switch (format) {
      case SmesReportFormat.pdf: return 'application/pdf';
      case SmesReportFormat.csv: return 'text/csv';
      case SmesReportFormat.json: return 'application/json';
    }
  }

  String fileExtension() {
    switch (format) {
      case SmesReportFormat.pdf: return '.pdf';
      case SmesReportFormat.csv: return '.csv';
      case SmesReportFormat.json: return '.json';
    }
  }

  String buildFileName(SmesReportRequest request) {
    final ts = DateTime.now();
    final stamp = '${ts.year}${ts.month.toString().padLeft(2,'0')}${ts.day.toString().padLeft(2,'0')}';
    return 'SMES_${request.type.name}_$stamp${fileExtension()}';
  }

  bool canGenerateFor(SmesReportType type) => true;
}

class SmesReportRequest {
  final SmesReportType type;
  final String? classId;
  final String? studentId;
  final String academicYear;
  final String? termId;
  final DateTime fromDate;
  final DateTime toDate;

  const SmesReportRequest({
    required this.type,
    required this.academicYear,
    required this.fromDate,
    required this.toDate,
    this.classId,
    this.studentId,
    this.termId,
  });

  bool get isSchoolWide => classId == null && studentId == null;
  bool get isStudentSpecific => studentId != null;
}
