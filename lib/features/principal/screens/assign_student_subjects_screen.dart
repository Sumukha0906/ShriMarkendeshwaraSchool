import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/models/class_model.dart';
import '../../../core/models/student.dart';

class AssignStudentSubjectsScreen extends ConsumerStatefulWidget {
  final ClassModel classModel;

  const AssignStudentSubjectsScreen({super.key, required this.classModel});

  @override
  ConsumerState<AssignStudentSubjectsScreen> createState() =>
      _AssignStudentSubjectsScreenState();
}

class _AssignStudentSubjectsScreenState
    extends ConsumerState<AssignStudentSubjectsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Student> _students = [];
  // subjectName → Set of EXCLUDED student IDs (not assigned)
  final Map<String, Set<String>> _excludedBySubject = {};
  bool _loading = true;
  bool _saving = false;

  List<String> get _subjects =>
      widget.classModel.subjectTeachers.map((st) => st.subject).toList();

  static const _blue = Color(0xFF3B82F6);
  static const _dark = Color(0xFF1D4ED8);
  static const _bg   = Color(0xFFF5F6FA);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: _subjects.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final fs = ref.read(firestoreServiceProvider);
    try {
      // Load students
      final students =
          await fs.streamStudentsByClass(widget.classModel.classId).first;
      setState(() => _students = students);

      // Load existing enrollments
      for (final subject in _subjects) {
        final docId = _enrollmentDocId(subject);
        final doc = await fs.getSubjectEnrollment(docId);
        if (doc != null) {
          _excludedBySubject[subject] = Set<String>.from(
              (doc['excludedStudentIds'] as List<dynamic>?)?.cast<String>() ??
                  []);
        } else {
          _excludedBySubject[subject] = {};
        }
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  String _enrollmentDocId(String subject) {
    final safeSub = subject.toLowerCase().replaceAll(' ', '_');
    return '${widget.classModel.classId}_$safeSub';
  }

  bool _isEnrolled(String subject, String studentId) {
    return !(_excludedBySubject[subject]?.contains(studentId) ?? false);
  }

  void _toggleStudent(String subject, String studentId) {
    setState(() {
      final excluded = _excludedBySubject[subject] ?? {};
      if (excluded.contains(studentId)) {
        excluded.remove(studentId);
      } else {
        excluded.add(studentId);
      }
      _excludedBySubject[subject] = excluded;
    });
  }

  void _selectAll(String subject) {
    setState(() => _excludedBySubject[subject] = {});
  }

  void _deselectAll(String subject) {
    setState(() {
      _excludedBySubject[subject] =
          _students.map((s) => s.studentId).toSet();
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final fs = ref.read(firestoreServiceProvider);
    try {
      for (final subject in _subjects) {
        final docId = _enrollmentDocId(subject);
        final excluded = (_excludedBySubject[subject] ?? {}).toList();
        await fs.saveSubjectEnrollment(
          docId: docId,
          classId: widget.classModel.classId,
          schoolId: widget.classModel.schoolId,
          subjectName: subject,
          excludedStudentIds: excluded,
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Subject enrollments saved!'),
            backgroundColor: _blue,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_subjects.isEmpty) {
      return Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: _dark,
          foregroundColor: Colors.white,
          title: const Text('Assign Subjects to Students',
              style: TextStyle(fontWeight: FontWeight.w700)),
        ),
        body: const Center(
          child: Text(
            'No subjects assigned to this class yet.\nPlease assign subject teachers first.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _dark,
        foregroundColor: Colors.white,
        title: Text('Subjects — ${widget.classModel.displayName}',
            style: const TextStyle(fontWeight: FontWeight.w700)),
        bottom: _subjects.length > 1
            ? TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor:
                    Colors.white.withValues(alpha: 0.55),
                labelStyle: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 13),
                tabs: _subjects.map((s) => Tab(text: s)).toList(),
              )
            : null,
        actions: [
          if (!_saving)
            TextButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_rounded,
                  color: Colors.white, size: 18),
              label: const Text('Assign',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700)),
            )
          else
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: _blue))
          : _subjects.length > 1
              ? TabBarView(
                  controller: _tabController,
                  children: _subjects.map(_buildSubjectTab).toList(),
                )
              : _buildSubjectTab(_subjects.first),
    );
  }

  Widget _buildSubjectTab(String subject) {
    final enrolled = _students.where(
        (s) => _isEnrolled(subject, s.studentId)).length;

    return Column(
      children: [
        // Info banner
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _blue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: _blue.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  color: _blue, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '$enrolled / ${_students.length} students enrolled in $subject',
                  style: const TextStyle(
                      color: _blue,
                      fontWeight: FontWeight.w600,
                      fontSize: 13),
                ),
              ),
              TextButton(
                onPressed: () => _selectAll(subject),
                child: const Text('All',
                    style: TextStyle(color: _blue, fontSize: 12)),
              ),
              TextButton(
                onPressed: () => _deselectAll(subject),
                child: Text('None',
                    style: TextStyle(
                        color: Colors.grey[500], fontSize: 12)),
              ),
            ],
          ),
        ),
        // Student list
        Expanded(
          child: _students.isEmpty
              ? const Center(
                  child: Text('No students in this class',
                      style: TextStyle(color: Colors.grey)))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: _students.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 8),
                  itemBuilder: (ctx, i) {
                    final s = _students[i];
                    final isEnrolled =
                        _isEnrolled(subject, s.studentId);
                    return InkWell(
                      onTap: () =>
                          _toggleStudent(subject, s.studentId),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isEnrolled
                              ? Colors.white
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isEnrolled
                                ? _blue.withValues(alpha: 0.2)
                                : Colors.grey[300]!,
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: isEnrolled
                                  ? _blue.withValues(alpha: 0.12)
                                  : Colors.grey[200],
                              child: Text(
                                s.name.isNotEmpty
                                    ? s.name[0].toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  color: isEnrolled
                                      ? _blue
                                      : Colors.grey[400],
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: isEnrolled
                                          ? const Color(0xFF0A0F1E)
                                          : Colors.grey[400],
                                    ),
                                  ),
                                  if (s.rollNo.isNotEmpty)
                                    Text(
                                      'Roll: ${s.rollNo}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Icon(
                              isEnrolled
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_unchecked_rounded,
                              color: isEnrolled ? _blue : Colors.grey[300],
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
