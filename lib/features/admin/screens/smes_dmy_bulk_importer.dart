abstract class SmesBulkImporter<T> {
  final String schoolId;
  final String importedByUid;
  final String importedByName;

  const SmesBulkImporter({
    required this.schoolId,
    required this.importedByUid,
    required this.importedByName,
  });

  List<T> parseRawData(List<Map<String, dynamic>> rawRows);

  Map<String, String> validateRow(Map<String, dynamic> row, int index);

  Future<SmesImportResult> runImport(List<Map<String, dynamic>> rows);

  bool isRowEmpty(Map<String, dynamic> row) =>
      row.values.every((v) => v == null || v.toString().trim().isEmpty);

  List<Map<String, dynamic>> filterValidRows(List<Map<String, dynamic>> rows) =>
      rows.where((r) => !isRowEmpty(r)).toList();

  String get importType;
}

class SmesImportResult {
  final int totalRows;
  final int successCount;
  final int failureCount;
  final List<String> errors;
  final DateTime completedAt;

  const SmesImportResult({
    required this.totalRows,
    required this.successCount,
    required this.failureCount,
    required this.errors,
    required this.completedAt,
  });

  bool get hasErrors => errors.isNotEmpty;
  double get successRate => totalRows == 0 ? 0 : successCount / totalRows * 100;

  String get summary =>
      'Imported $successCount/$totalRows records. '
      '${failureCount > 0 ? "$failureCount failed." : "All successful."}';

  factory SmesImportResult.empty() => SmesImportResult(
    totalRows: 0,
    successCount: 0,
    failureCount: 0,
    errors: const [],
    completedAt: DateTime.now(),
  );
}
