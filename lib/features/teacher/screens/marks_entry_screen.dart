import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/models/class_model.dart';
import '../../../core/models/student.dart';
import '../../../core/models/marks.dart';
import '../../../core/services/notification_service.dart';

const _kPrimary = Color(0xFF065F46);
const _kDark    = Color(0xFF022C22);
const _kBg      = Color(0xFFF0FDF4);
const _kRed     = Color(0xFFEF4444);

class MarksEntryScreen extends ConsumerStatefulWidget {
  final String schoolId;
  final String teacherUid;
  final String? preselectedClassId;

  const MarksEntryScreen({
    super.key,
    required this.schoolId,
    required this.teacherUid,
    this.preselectedClassId,
  });

  @override
  ConsumerState<MarksEntryScreen> createState() => _MarksEntryScreenState();
}

class _MarksEntryScreenState extends ConsumerState<MarksEntryScreen> {
  List<ClassModel> _classes = [];
  ClassModel? _selectedClass;
  List<Student> _students = [];
  String _selectedSubject = '';
  double _maxMarks = 100;
  bool _loading = false;
  bool _saving  = false;
  final String _academicYear = '2026-27';

  // Exam description replaces the old term dropdown
  final _examDescCtrl = TextEditingController();
  bool _examDescError = false;

  // marks[studentId] = obtained marks
  final Map<String, TextEditingController> _marksCtrls = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadClasses());
  }

  @override
  void dispose() {
    _examDescCtrl.dispose();
    for (final c in _marksCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadClasses() async {
    setState(() => _loading = true);
    final fs = ref.read(firestoreServiceProvider);
    final classes = await fs
        .streamAllClassesForTeacher(widget.schoolId, widget.teacherUid)
        .first;
    setState(() {
      _classes = classes;
      if (widget.preselectedClassId != null) {
        _selectedClass = classes.firstWhere(
          (c) => c.classId == widget.preselectedClassId,
          orElse: () => classes.isNotEmpty ? classes.first : classes.first,
        );
      } else if (classes.isNotEmpty) {
        _selectedClass = classes.first;
      }
      _updateSubject();
      _loading = false;
    });
    if (_selectedClass != null) await _loadStudents();
  }

  void _updateSubject() {
    if (_selectedClass == null) return;
    final subs = _selectedClass!.subjectTeachers
        .where((st) => st.teacherUid == widget.teacherUid)
        .map((st) => st.subject)
        .toList();
    if (subs.isEmpty) {
      // Class teacher — pick first subject
      final all = _selectedClass!.subjectTeachers.map((st) => st.subject).toList();
      _selectedSubject = all.isNotEmpty ? all.first : 'General';
    } else {
      _selectedSubject = subs.first;
    }
  }

  Future<void> _loadStudents() async {
    if (_selectedClass == null) return;
    setState(() => _loading = true);
    final fs = ref.read(firestoreServiceProvider);
    final students =
        await fs.streamStudentsByClass(_selectedClass!.classId).first;

    // Clear old controllers
    for (final c in _marksCtrls.values) {
      c.dispose();
    }
    _marksCtrls.clear();

    // Load existing marks for each student (using exam description as term key)
    final termKey = _examDescCtrl.text.trim();
    for (final s in students) {
      String value = '';
      if (termKey.isNotEmpty) {
        final existing = await fs.getStudentMarks(
            s.studentId, _academicYear, termKey);
        if (existing != null) {
          final subjectMark = existing.subjects
              .where((sm) => sm.subject == _selectedSubject)
              .firstOrNull;
          value = subjectMark?.marksObtained.toString() ?? '';
        }
      }
      _marksCtrls[s.studentId] = TextEditingController(text: value);
    }

    setState(() {
      _students = students;
      _loading  = false;
    });
  }

  Future<void> _saveMarks() async {
    final termKey = _examDescCtrl.text.trim();
    if (termKey.isEmpty) {
      setState(() => _examDescError = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter what this result is about (e.g. Term 1, Unit Test)'),
          backgroundColor: _kRed,
        ),
      );
      return;
    }
    setState(() { _saving = true; _examDescError = false; });
    final fs = ref.read(firestoreServiceProvider);

    try {
      final savedStudents = <Student>[];
      final savedMarksMap = <String, double>{}; // studentId → obtained

      for (final s in _students) {
        final text = _marksCtrls[s.studentId]?.text.trim() ?? '';
        if (text.isEmpty) continue;
        final obtained = double.tryParse(text) ?? 0;

        // Check if existing marks exist to merge
        final existing =
            await fs.getStudentMarks(s.studentId, _academicYear, termKey);

        List<SubjectMark> subjects;
        if (existing != null) {
          final others = existing.subjects
              .where((sm) => sm.subject != _selectedSubject)
              .toList();
          subjects = [
            ...others,
            SubjectMark(
              subject:       _selectedSubject,
              marksObtained: obtained,
              maxMarks:      _maxMarks,
              grade:         _computeGrade(obtained, _maxMarks),
            ),
          ];
        } else {
          subjects = [
            SubjectMark(
              subject:       _selectedSubject,
              marksObtained: obtained,
              maxMarks:      _maxMarks,
              grade:         _computeGrade(obtained, _maxMarks),
            ),
          ];
        }

        final marks = StudentMarks(
          studentId:    s.studentId,
          classId:      s.classId,
          schoolId:     widget.schoolId,
          academicYear: _academicYear,
          term:         termKey,
          subjects:     subjects,
          updatedBy:    widget.teacherUid,
          updatedAt:    DateTime.now(),
          isPublished:  true,
        );
        await fs.saveMarks(marks);
        savedStudents.add(s);
        savedMarksMap[s.studentId] = obtained;
      }

      // Notify parents for each student whose marks were saved
      _notifyParentsMarksPublished(savedStudents, savedMarksMap, termKey);

      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Marks saved & parents notified!'),
            backgroundColor: _kPrimary,
          ),
        );
      }
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: _kRed),
        );
      }
    }
  }

  /// Send in-app notification to each student's parent after marks are saved.
  void _notifyParentsMarksPublished(
    List<Student> students,
    Map<String, double> obtainedMap,
    String termKey,
  ) async {
    try {
      for (final s in students) {
        final obtained = obtainedMap[s.studentId] ?? 0;
        final grade    = _computeGrade(obtained, _maxMarks);
        final title    = '📊 $termKey Results Published';
        final body     = '${s.name} scored ${obtained.toStringAsFixed(0)}/'
            '${_maxMarks.toStringAsFixed(0)} in $_selectedSubject (Grade: $grade)';
        final extra    = {
          'type':      'MARKS_PUBLISHED',
          'studentId': s.studentId,
          'subject':   _selectedSubject,
          'term':      termKey,
        };

        final uids = <String>{};
        if (s.parentUid.isNotEmpty) uids.add(s.parentUid);

        if (uids.isNotEmpty) {
          await NotificationService.sendNotification(
            receiverUids: uids.toList(),
            title: title,
            body:  body,
            extra: extra,
          );
        }
      }
    } catch (_) {
      // Non-critical — marks are already saved
    }
  }

  String _computeGrade(double obtained, double max) {
    if (max == 0) return 'N/A';
    final pct = (obtained / max) * 100;
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
    return Scaffold(
      backgroundColor: _kBg,
      // Pattern A — rounded bottom AppBar
      appBar: AppBar(
        backgroundColor: _kDark,
        foregroundColor: Colors.white,
        title: const Text('Enter Marks',
            style: TextStyle(fontWeight: FontWeight.w700)),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _kPrimary))
          : Column(
              children: [
                // ── Filters ──
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      // Class selector
                      _dropdown<ClassModel>(
                        value: _selectedClass,
                        items: _classes,
                        display: (c) => c.displayName,
                        onChanged: (c) async {
                          setState(() {
                            _selectedClass = c;
                            _updateSubject();
                          });
                          await _loadStudents();
                        },
                        hint: 'Select Class',
                      ),
                      const SizedBox(height: 8),
                      // Exam description (replaces term dropdown)
                      TextField(
                        controller: _examDescCtrl,
                        decoration: InputDecoration(
                          // Pattern E — radius 16, filled
                          hintText: 'What is this result about? e.g. Term 1, Monthly Test, Unit Test...',
                          hintStyle: TextStyle(
                              color: Colors.grey[400], fontSize: 12),
                          errorText: _examDescError
                              ? 'This field is required'
                              : null,
                          isDense: true,
                          filled: true,
                          fillColor: const Color(0xFFF0FDF4),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: _kPrimary.withValues(alpha: 0.3))),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: _kPrimary.withValues(alpha: 0.3))),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                                color: _kPrimary, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          prefixIcon: const Icon(Icons.assignment_outlined,
                              size: 18, color: _kPrimary),
                        ),
                        onChanged: (_) {
                          if (_examDescError) {
                            setState(() => _examDescError = false);
                          }
                        },
                        onSubmitted: (_) async => _loadStudents(),
                      ),
                      const SizedBox(height: 8),
                      // Subject + Max marks
                      Row(
                        children: [
                          Expanded(child: _buildSubjectSelector()),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 100,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Max Marks',
                                isDense: true,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                              ),
                              onChanged: (v) {
                                _maxMarks = double.tryParse(v) ?? 100;
                              },
                              controller: TextEditingController(
                                  text: _maxMarks.toString()),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Students list ──
                Expanded(
                  child: _students.isEmpty
                      ? const Center(
                          child: Text('No students found'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _students.length,
                          itemBuilder: (_, i) {
                            final s = _students[i];
                            return _MarksRow(
                              student:    s,
                              controller: _marksCtrls[s.studentId]!,
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: _students.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _saving ? null : _saveMarks,
              backgroundColor: _kPrimary,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.save_rounded, color: Colors.white),
              label: Text(
                _saving ? 'Saving...' : 'Save All Marks',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700),
              ),
            )
          : null,
    );
  }

  Widget _buildSubjectSelector() {
    if (_selectedClass == null) return const SizedBox();
    final allSubs = _selectedClass!.subjectTeachers
        .map((st) => st.subject)
        .toList();
    if (allSubs.isEmpty) {
      return Text('Subject: General',
          style: TextStyle(color: Colors.grey[600], fontSize: 13));
    }
    return _dropdown<String>(
      value: _selectedSubject.isNotEmpty ? _selectedSubject : null,
      items: allSubs,
      display: (s) => s,
      onChanged: (s) async {
        setState(() => _selectedSubject = s ?? '');
        await _loadStudents();
      },
      hint: 'Subject',
    );
  }

  Widget _dropdown<T>({
    required T? value,
    required List<T> items,
    required String Function(T) display,
    required void Function(T?) onChanged,
    required String hint,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(hint, style: TextStyle(color: Colors.grey[400], fontSize: 13)),
          isExpanded: true,
          items: items.map((i) => DropdownMenuItem(
            value: i,
            child: Text(display(i), style: const TextStyle(fontSize: 13)),
          )).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _MarksRow extends StatelessWidget {
  final Student student;
  final TextEditingController controller;

  const _MarksRow({
    required this.student,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: _kPrimary, width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            // Roll number badge
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _kPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  student.rollNo.isNotEmpty ? student.rollNo : '#',
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
                student.name,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
            // Marks input
            SizedBox(
              width: 80,
              child: TextField(
                controller: controller,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: '—',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  isDense: true,
                  filled: true,
                  fillColor: const Color(0xFFF0FDF4),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: _kPrimary.withValues(alpha: 0.3))),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: _kPrimary.withValues(alpha: 0.2))),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: _kPrimary),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
