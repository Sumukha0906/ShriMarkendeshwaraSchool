import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/models/class_model.dart';
import '../../../core/models/student.dart';
import '../../../core/models/marks.dart';

// ── Theme ──────────────────────────────────────────────────────────────────
const _kPrimary = Color(0xFF065F46);
const _kDark    = Color(0xFF022C22);
const _kBg      = Color(0xFFF0FDF4);
const _kBlue     = Color(0xFF3B82F6);
const _kRed      = Color(0xFFEF4444);
const _kAmber    = Color(0xFFF59E0B);
const _academicYear = '2026-27';

// ── Data holder ────────────────────────────────────────────────────────────
class _StudentResult {
  final Student student;
  final StudentMarks marks;
  const _StudentResult({required this.student, required this.marks});
}

// ══════════════════════════════════════════════════════════════════════════════
//  MarksResultsScreen
// ══════════════════════════════════════════════════════════════════════════════

class MarksResultsScreen extends ConsumerStatefulWidget {
  final String schoolId;
  /// Null when accessed by principal (shows all classes).
  final String? teacherUid;
  final String? preselectedClassId;

  const MarksResultsScreen({
    super.key,
    required this.schoolId,
    this.teacherUid,
    this.preselectedClassId,
  });

  @override
  ConsumerState<MarksResultsScreen> createState() => _MarksResultsScreenState();
}

class _MarksResultsScreenState extends ConsumerState<MarksResultsScreen> {
  // Phase: 0 = class list, 1 = test list, 2 = test results
  int _phase = 0;

  List<ClassModel> _classes = [];
  ClassModel? _selectedClass;

  List<String> _terms = [];
  String? _selectedTerm;

  List<_StudentResult> _results = [];

  bool _loading = false;

  // Search
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  List<Student> _searchStudents = [];
  bool _searchLoading = false;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadClasses());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Loading helpers ──────────────────────────────────────────────────────

  Future<void> _loadClasses() async {
    setState(() => _loading = true);
    final fs = ref.read(firestoreServiceProvider);
    List<ClassModel> classes;
    if (widget.teacherUid != null) {
      classes = await fs
          .streamAllClassesForTeacher(widget.schoolId, widget.teacherUid!)
          .first;
    } else {
      classes = await fs.streamSchoolClasses(widget.schoolId).first;
    }
    setState(() {
      _classes = classes;
      _loading = false;
    });

    if (widget.preselectedClassId != null) {
      final match = classes.where(
              (c) => c.classId == widget.preselectedClassId)
          .firstOrNull;
      if (match != null) _selectClass(match);
    }
  }

  Future<void> _selectClass(ClassModel cls) async {
    setState(() {
      _selectedClass = cls;
      _phase = 1;
      _terms = [];
      _selectedTerm = null;
      _results = [];
      _loading = true;
    });
    final fs = ref.read(firestoreServiceProvider);
    final students = await fs.streamStudentsByClass(cls.classId).first;
    final termSet = <String>{};
    for (final s in students) {
      final allMarks = await fs.streamAllStudentMarks(s.studentId).first;
      for (final m in allMarks) {
        if (m.classId == cls.classId) termSet.add(m.term);
      }
    }
    final termList = termSet.toList()..sort();
    if (mounted) {
      setState(() {
        _terms = termList;
        _loading = false;
      });
    }
  }

  Future<void> _selectTerm(String term) async {
    setState(() {
      _selectedTerm = term;
      _phase = 2;
      _results = [];
      _loading = true;
    });
    final fs = ref.read(firestoreServiceProvider);
    final students =
        await fs.streamStudentsByClass(_selectedClass!.classId).first;
    final results = <_StudentResult>[];
    for (final s in students) {
      final marks =
          await fs.getStudentMarks(s.studentId, _academicYear, term);
      if (marks != null) results.add(_StudentResult(student: s, marks: marks));
    }
    results.sort((a, b) {
      final ra = int.tryParse(a.student.rollNo) ?? 999;
      final rb = int.tryParse(b.student.rollNo) ?? 999;
      return ra.compareTo(rb);
    });
    if (mounted) {
      setState(() {
        _results = results;
        _loading = false;
      });
    }
  }

  // ── Search ───────────────────────────────────────────────────────────────

  void _onSearchChanged() {
    final q = _searchCtrl.text.trim();
    setState(() => _searchQuery = q);
    if (q.length >= 2) {
      _doSearch(q);
    } else {
      setState(() => _searchStudents = []);
    }
  }

  Future<void> _doSearch(String q) async {
    setState(() => _searchLoading = true);
    final fs = ref.read(firestoreServiceProvider);
    final all = await fs.streamSchoolStudents(widget.schoolId).first;
    final lower = q.toLowerCase();
    if (mounted) {
      setState(() {
        _searchStudents = all
            .where((s) =>
                s.name.toLowerCase().contains(lower) ||
                s.rollNo.toLowerCase().contains(lower))
            .toList();
        _searchLoading = false;
      });
    }
  }

  // ── Back navigation ──────────────────────────────────────────────────────

  bool _handleBack() {
    if (_searchQuery.isNotEmpty) {
      _searchCtrl.clear();
      return true;
    }
    if (_phase == 2) {
      setState(() {
        _phase = 1;
        _selectedTerm = null;
        _results = [];
      });
      return true;
    }
    if (_phase == 1) {
      setState(() {
        _phase = 0;
        _selectedClass = null;
        _terms = [];
      });
      return true;
    }
    return false;
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (!_handleBack()) Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: _kBg,
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  AppBar _buildAppBar() {
    String title = 'Results';
    if (_phase == 1 && _selectedClass != null) {
      title = _selectedClass!.displayName;
    } else if (_phase == 2 && _selectedTerm != null) {
      title = _selectedTerm!;
    }
    // Pattern A — rounded bottom AppBar
    return AppBar(
      backgroundColor: _kDark,
      foregroundColor: Colors.white,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          if (!_handleBack()) Navigator.of(context).pop();
        },
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        // Search bar (visible in phase 0 only)
        if (_phase == 0) _buildSearchBar(),

        // Main content
        Expanded(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: _kPrimary))
              : _searchQuery.isNotEmpty
                  ? _buildSearchResults()
                  : _phase == 0
                      ? _buildClassList()
                      : _phase == 1
                          ? _buildTestList()
                          : _buildResultsTable(),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: TextField(
        controller: _searchCtrl,
        decoration: InputDecoration(
          hintText: 'Search student by name...',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: _kPrimary, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => _searchCtrl.clear(),
                )
              : null,
          filled: true,
          fillColor: _kBg,
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  // ── Phase 0: Class List ──────────────────────────────────────────────────

  Widget _buildClassList() {
    if (_classes.isEmpty) {
      return const Center(child: Text('No classes found'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _classes.length,
      itemBuilder: (_, i) {
        final cls = _classes[i];
        return GestureDetector(
          onTap: () => _selectClass(cls),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _kPrimary.withValues(alpha: 0.15)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: _kPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.class_rounded,
                      color: _kPrimary, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    cls.displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: _kPrimary, size: 22),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Phase 1: Test List ───────────────────────────────────────────────────

  Widget _buildTestList() {
    if (_terms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 56, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              'No tests recorded yet',
              style: TextStyle(color: Colors.grey[500], fontSize: 15),
            ),
            const SizedBox(height: 6),
            Text(
              'Record marks using "Record New Test Marks"',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _terms.length,
      itemBuilder: (_, i) {
        final term = _terms[i];
        return GestureDetector(
          onTap: () => _selectTerm(term),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _kBlue.withValues(alpha: 0.15)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: _kBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.quiz_rounded,
                      color: _kBlue, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        term,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        _academicYear,
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: _kBlue, size: 22),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Phase 2: Results Table ───────────────────────────────────────────────

  Widget _buildResultsTable() {
    if (_results.isEmpty) {
      return const Center(child: Text('No results found for this test'));
    }

    // Collect all subjects in order of first appearance
    final subjects = <String>[];
    for (final r in _results) {
      for (final sm in r.marks.subjects) {
        if (!subjects.contains(sm.subject)) subjects.add(sm.subject);
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _kDark,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.people_rounded,
                    color: Colors.white70, size: 16),
                const SizedBox(width: 8),
                Text(
                  '${_results.length} students  •  ${subjects.length} subject${subjects.length != 1 ? 's' : ''}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Student cards
          ..._results.map((r) => _buildStudentResultCard(r, subjects)),
        ],
      ),
    );
  }

  Widget _buildStudentResultCard(_StudentResult r, List<String> allSubjects) {
    final totalObtained = r.marks.totalObtained;
    final totalMax = r.marks.totalMax;
    final pct = totalMax > 0 ? (totalObtained / totalMax * 100) : 0.0;
    final grade = _gradeFromPct(pct);
    final gradeColor = _gradeColor(grade);

    // Pattern H — top accent stripe on result cards
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(top: BorderSide(color: gradeColor, width: 3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: gradeColor.withValues(alpha: 0.06),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
              border: Border(
                  bottom: BorderSide(
                      color: gradeColor.withValues(alpha: 0.15))),
            ),
            child: Row(
              children: [
                // Roll badge
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _kPrimary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      r.student.rollNo.isNotEmpty
                          ? r.student.rollNo
                          : '#',
                      style: const TextStyle(
                          color: _kPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 11),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    r.student.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ),
                // Total + Grade
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${totalObtained.toStringAsFixed(0)}/${totalMax.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: gradeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        '$grade  ${pct.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: gradeColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Subject rows
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Column(
              children: allSubjects.map((sub) {
                final sm = r.marks.subjects
                    .where((s) => s.subject == sub)
                    .firstOrNull;
                if (sm == null) {
                  return _SubjectRow(
                      subject: sub, obtained: null, max: null);
                }
                return _SubjectRow(
                  subject: sub,
                  obtained: sm.marksObtained,
                  max: sm.maxMarks,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Search Results ───────────────────────────────────────────────────────

  Widget _buildSearchResults() {
    if (_searchLoading) {
      return const Center(
          child: CircularProgressIndicator(color: _kPrimary));
    }
    if (_searchStudents.isEmpty) {
      return Center(
        child: Text(
          'No students found',
          style: TextStyle(color: Colors.grey[500]),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchStudents.length,
      itemBuilder: (_, i) {
        final s = _searchStudents[i];
        return GestureDetector(
          onTap: () => _showStudentReport(s),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: _kPrimary.withValues(alpha: 0.12),
                  child: Text(
                    s.name.isNotEmpty ? s.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                        color: _kPrimary, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 14)),
                      Text(
                        'Roll: ${s.rollNo.isNotEmpty ? s.rollNo : '—'}',
                        style: TextStyle(
                            color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: _kPrimary, size: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showStudentReport(Student student) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _StudentReportSheet(
        student: student,
        firestoreService: ref.read(firestoreServiceProvider),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _gradeFromPct(double pct) {
    if (pct >= 90) return 'A+';
    if (pct >= 80) return 'A';
    if (pct >= 70) return 'B+';
    if (pct >= 60) return 'B';
    if (pct >= 50) return 'C';
    if (pct >= 40) return 'D';
    return 'F';
  }

  Color _gradeColor(String grade) {
    switch (grade) {
      case 'A+': return const Color(0xFF059669);
      case 'A':  return const Color(0xFF10B981);
      case 'B+': return _kBlue;
      case 'B':  return const Color(0xFF60A5FA);
      case 'C':  return _kAmber;
      case 'D':  return _kAmber;
      default:   return _kRed;
    }
  }
}

// ── Subject Row Widget ──────────────────────────────────────────────────────

class _SubjectRow extends StatelessWidget {
  final String subject;
  final double? obtained;
  final double? max;
  const _SubjectRow(
      {required this.subject, required this.obtained, required this.max});

  @override
  Widget build(BuildContext context) {
    final pct = (obtained != null && max != null && max! > 0)
        ? obtained! / max! * 100
        : -1.0;
    final barColor = pct >= 75
        ? const Color(0xFF059669)
        : pct >= 50
            ? _kAmber
            : pct >= 0
                ? _kRed
                : Colors.grey;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(subject,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600)),
          ),
          if (obtained != null && max != null) ...[
            Text(
              '${obtained!.toStringAsFixed(0)}/${max!.toStringAsFixed(0)}',
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 60,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: pct / 100,
                  backgroundColor: Colors.grey[200],
                  color: barColor,
                  minHeight: 6,
                ),
              ),
            ),
          ] else
            Text('—', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  Student Report Bottom Sheet  (search → student → tests → report + PDF)
// ══════════════════════════════════════════════════════════════════════════════

class _StudentReportSheet extends StatefulWidget {
  final Student student;
  final dynamic firestoreService;
  const _StudentReportSheet(
      {required this.student, required this.firestoreService});

  @override
  State<_StudentReportSheet> createState() => _StudentReportSheetState();
}

class _StudentReportSheetState extends State<_StudentReportSheet> {
  List<StudentMarks> _allMarks = [];
  StudentMarks? _selectedMarks;
  bool _loading = true;
  bool _pdfLoading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final marks = await widget.firestoreService
        .streamAllStudentMarks(widget.student.studentId)
        .first as List<StudentMarks>;
    marks.sort((a, b) {
      final yearCmp = b.academicYear.compareTo(a.academicYear);
      if (yearCmp != 0) return yearCmp;
      return a.term.compareTo(b.term);
    });
    if (mounted) {
      setState(() {
        _allMarks = marks;
        _loading = false;
      });
    }
  }

  Future<void> _downloadPdf(StudentMarks marks) async {
    setState(() => _pdfLoading = true);
    try {
      final bytes = await _buildPdf(widget.student, marks);
      await Printing.layoutPdf(onLayout: (_) async => bytes);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF error: $e'), backgroundColor: _kRed),
        );
      }
    } finally {
      if (mounted) setState(() => _pdfLoading = false);
    }
  }

  Future<Uint8List> _buildPdf(Student student, StudentMarks marks) async {
    final doc = pw.Document();
    final pct = marks.percentage;
    final grade = _gradeStr(pct);

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: const PdfColor.fromInt(0xFF065F46),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Report Card',
                      style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Academic Year: ${marks.academicYear}  •  Test: ${marks.term}',
                    style: const pw.TextStyle(
                        color: PdfColors.white, fontSize: 11),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 16),

            // Student info
            pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Student Name',
                          style: const pw.TextStyle(
                              color: PdfColors.grey, fontSize: 9)),
                      pw.Text(student.name,
                          style: pw.TextStyle(
                              fontSize: 15, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Overall Grade',
                        style: const pw.TextStyle(
                            color: PdfColors.grey, fontSize: 9)),
                    pw.Text(grade,
                        style: pw.TextStyle(
                            fontSize: 22, fontWeight: pw.FontWeight.bold)),
                    pw.Text('${pct.toStringAsFixed(1)}%',
                        style: const pw.TextStyle(fontSize: 11)),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 4),
            if (student.rollNo.isNotEmpty)
              pw.Text('Roll No: ${student.rollNo}',
                  style: const pw.TextStyle(
                      color: PdfColors.grey, fontSize: 10)),
            pw.SizedBox(height: 16),
            pw.Divider(),
            pw.SizedBox(height: 8),

            // Table header
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                  horizontal: 8, vertical: 6),
              color: const PdfColor.fromInt(0xFF022C22),
              child: pw.Row(
                children: [
                  pw.Expanded(
                      flex: 3,
                      child: pw.Text('Subject',
                          style: pw.TextStyle(
                              color: PdfColors.white,
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 10))),
                  pw.Expanded(
                      child: pw.Text('Obtained',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                              color: PdfColors.white,
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 10))),
                  pw.Expanded(
                      child: pw.Text('Max',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                              color: PdfColors.white,
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 10))),
                  pw.Expanded(
                      child: pw.Text('%',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                              color: PdfColors.white,
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 10))),
                  pw.Expanded(
                      child: pw.Text('Grade',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                              color: PdfColors.white,
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 10))),
                ],
              ),
            ),

            // Subject rows
            ...marks.subjects.asMap().entries.map((e) {
              final idx = e.key;
              final sm = e.value;
              final sPct = sm.maxMarks > 0
                  ? sm.marksObtained / sm.maxMarks * 100
                  : 0.0;
              return pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                    horizontal: 8, vertical: 6),
                color: idx.isEven
                    ? const PdfColor.fromInt(0xFFF0FDF4)
                    : PdfColors.white,
                child: pw.Row(
                  children: [
                    pw.Expanded(
                        flex: 3,
                        child: pw.Text(sm.subject,
                            style:
                                const pw.TextStyle(fontSize: 10))),
                    pw.Expanded(
                        child: pw.Text(
                            sm.marksObtained.toStringAsFixed(0),
                            textAlign: pw.TextAlign.center,
                            style:
                                const pw.TextStyle(fontSize: 10))),
                    pw.Expanded(
                        child: pw.Text(
                            sm.maxMarks.toStringAsFixed(0),
                            textAlign: pw.TextAlign.center,
                            style:
                                const pw.TextStyle(fontSize: 10))),
                    pw.Expanded(
                        child: pw.Text(
                            '${sPct.toStringAsFixed(1)}%',
                            textAlign: pw.TextAlign.center,
                            style:
                                const pw.TextStyle(fontSize: 10))),
                    pw.Expanded(
                        child: pw.Text(sm.grade,
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                                fontSize: 10,
                                fontWeight:
                                    pw.FontWeight.bold))),
                  ],
                ),
              );
            }),

            // Total row
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                  horizontal: 8, vertical: 8),
              color: const PdfColor.fromInt(0xFF065F46),
              child: pw.Row(
                children: [
                  pw.Expanded(
                      flex: 3,
                      child: pw.Text('TOTAL',
                          style: pw.TextStyle(
                              color: PdfColors.white,
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 11))),
                  pw.Expanded(
                      child: pw.Text(
                          marks.totalObtained.toStringAsFixed(0),
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                              color: PdfColors.white,
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 11))),
                  pw.Expanded(
                      child: pw.Text(
                          marks.totalMax.toStringAsFixed(0),
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                              color: PdfColors.white,
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 11))),
                  pw.Expanded(
                      child: pw.Text(
                          '${pct.toStringAsFixed(1)}%',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                              color: PdfColors.white,
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 11))),
                  pw.Expanded(
                      child: pw.Text(grade,
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                              color: PdfColors.white,
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 11))),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return doc.save();
  }

  String _gradeStr(double pct) {
    if (pct >= 90) return 'A+';
    if (pct >= 80) return 'A';
    if (pct >= 70) return 'B+';
    if (pct >= 60) return 'B';
    if (pct >= 50) return 'C';
    if (pct >= 40) return 'D';
    return 'F';
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle + header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: _kPrimary.withValues(alpha: 0.12),
                        child: Text(
                          widget.student.name.isNotEmpty
                              ? widget.student.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                              color: _kPrimary,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.student.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16)),
                            if (widget.student.rollNo.isNotEmpty)
                              Text('Roll: ${widget.student.rollNo}',
                                  style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Content
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: _kPrimary))
                  : _allMarks.isEmpty
                      ? Center(
                          child: Text(
                            'No test results found',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        )
                      : _selectedMarks == null
                          ? _buildTestPicker(ctrl)
                          : _buildReportView(ctrl),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestPicker(ScrollController ctrl) {
    return ListView.builder(
      controller: ctrl,
      padding: const EdgeInsets.all(16),
      itemCount: _allMarks.length,
      itemBuilder: (_, i) {
        final m = _allMarks[i];
        return GestureDetector(
          onTap: () => setState(() => _selectedMarks = m),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _kBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _kBlue.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _kBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.quiz_rounded,
                      color: _kBlue, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m.term,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14)),
                      Text(
                        '${m.subjects.length} subject${m.subjects.length != 1 ? 's' : ''}  •  ${m.totalObtained.toStringAsFixed(0)}/${m.totalMax.toStringAsFixed(0)}  •  ${m.percentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                            color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: _kBlue, size: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReportView(ScrollController ctrl) {
    final m = _selectedMarks!;
    final pct = m.percentage;
    final grade = _gradeStr(pct);

    Color gradeColor;
    switch (grade) {
      case 'A+': gradeColor = const Color(0xFF059669); break;
      case 'A':  gradeColor = const Color(0xFF10B981); break;
      case 'B+': gradeColor = _kBlue; break;
      case 'B':  gradeColor = const Color(0xFF60A5FA); break;
      case 'C':  gradeColor = _kAmber; break;
      case 'D':  gradeColor = _kAmber; break;
      default:   gradeColor = _kRed;
    }

    return ListView(
      controller: ctrl,
      padding: const EdgeInsets.all(16),
      children: [
        // Back to test list
        GestureDetector(
          onTap: () => setState(() => _selectedMarks = null),
          child: Row(
            children: [
              const Icon(Icons.arrow_back_ios_rounded,
                  size: 14, color: _kPrimary),
              const SizedBox(width: 4),
              Text('All Tests',
                  style: const TextStyle(
                      color: _kPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Summary card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_kDark, gradeColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(m.term,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(
                        '${m.totalObtained.toStringAsFixed(0)}/${m.totalMax.toStringAsFixed(0)} marks',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(grade,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 28)),
                  Text('${pct.toStringAsFixed(1)}%',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Subject breakdown
        ...m.subjects.map((sm) {
          final sPct = sm.maxMarks > 0
              ? sm.marksObtained / sm.maxMarks * 100
              : 0.0;
          final barColor = sPct >= 75
              ? const Color(0xFF059669)
              : sPct >= 50
                  ? _kAmber
                  : _kRed;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: Colors.grey.withValues(alpha: 0.12)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(sm.subject,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13)),
                    ),
                    Text(
                      '${sm.marksObtained.toStringAsFixed(0)}/${sm.maxMarks.toStringAsFixed(0)}',
                      style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: barColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${sPct.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: barColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: sPct / 100,
                    backgroundColor: Colors.grey[200],
                    color: barColor,
                    minHeight: 5,
                  ),
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: 8),
        // Download PDF button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _pdfLoading ? null : () => _downloadPdf(m),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kDark,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            icon: _pdfLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.picture_as_pdf_rounded, size: 20),
            label: Text(
              _pdfLoading ? 'Generating PDF...' : 'Download Report Card PDF',
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
