import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/models/class_model.dart';
import '../../../core/models/lesson_plan.dart';
import '../../../core/services/notification_service.dart';

const _kPrimary = Color(0xFF065F46);
const _kDark    = Color(0xFF022C22);
const _kBg      = Color(0xFFF0FDF4);
const _kRed     = Color(0xFFEF4444);
const _kBlue    = Color(0xFF3B82F6);

class PostLessonPlanScreen extends ConsumerStatefulWidget {
  final String schoolId;
  final String teacherUid;
  final String? preselectedClassId;

  const PostLessonPlanScreen({
    super.key,
    required this.schoolId,
    required this.teacherUid,
    this.preselectedClassId,
  });

  @override
  ConsumerState<PostLessonPlanScreen> createState() =>
      _PostLessonPlanScreenState();
}

class _PostLessonPlanScreenState extends ConsumerState<PostLessonPlanScreen> {
  ClassModel? _selectedClass;
  String _selectedSubject = '';
  List<ClassModel> _myClasses = [];
  List<String> _subjects = [];
  DateTime _selectedDate = DateTime.now();
  bool _loading = false;
  bool _saving = false;

  // File attachments
  List<PlatformFile> _pickedFiles = [];
  double _uploadProgress = 0;

  final _topicsCtrl   = TextEditingController();
  final _homeworkCtrl = TextEditingController();
  final _notesCtrl    = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadClasses());
  }

  @override
  void dispose() {
    _topicsCtrl.dispose();
    _homeworkCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadClasses() async {
    setState(() => _loading = true);
    final fs = ref.read(firestoreServiceProvider);
    try {
      final classes = await fs
          .streamAllClassesForTeacher(widget.schoolId, widget.teacherUid)
          .first;
      setState(() {
        _myClasses = classes;
        if (widget.preselectedClassId != null) {
          _selectedClass = classes.firstWhere(
            (c) => c.classId == widget.preselectedClassId,
            orElse: () => classes.isNotEmpty ? classes.first : classes.first,
          );
        } else if (classes.isNotEmpty) {
          _selectedClass = classes.first;
        }
        _updateSubjects();
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  void _updateSubjects() {
    if (_selectedClass == null) return;
    final teacherSubjects = _selectedClass!.subjectTeachers
        .where((st) => st.teacherUid == widget.teacherUid)
        .map((st) => st.subject)
        .toList();

    if (teacherSubjects.isEmpty) {
      // Class teacher — show all subjects
      _subjects = _selectedClass!.subjectTeachers.map((st) => st.subject).toList();
      if (_subjects.isEmpty) _subjects = ['General'];
    } else {
      _subjects = teacherSubjects;
    }

    _selectedSubject = _subjects.isNotEmpty ? _subjects.first : '';
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg', 'doc', 'docx'],
    );
    if (result != null) {
      setState(() => _pickedFiles = result.files);
    }
  }

  void _removeFile(int index) {
    setState(() => _pickedFiles = [..._pickedFiles]..removeAt(index));
  }

  Future<void> _submit() async {
    if (_selectedClass == null || _selectedSubject.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select class and subject')),
      );
      return;
    }
    if (_topicsCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter topics covered')),
      );
      return;
    }

    setState(() { _saving = true; _uploadProgress = 0; });
    final fs = ref.read(firestoreServiceProvider);

    try {
      // Upload attachments to Firebase Storage first
      final attachmentUrls  = <String>[];
      final attachmentNames = <String>[];

      final storage = FirebaseStorage.instance;
      for (int i = 0; i < _pickedFiles.length; i++) {
        final f = _pickedFiles[i];
        if (f.path == null) continue;
        final file    = File(f.path!);
        final storageRef = storage.ref(
          'lessonPlans/${widget.schoolId}/${DateTime.now().millisecondsSinceEpoch}_${f.name}',
        );
        await storageRef.putFile(file);
        final url = await storageRef.getDownloadURL();
        attachmentUrls.add(url);
        attachmentNames.add(f.name);
        setState(() => _uploadProgress = (i + 1) / _pickedFiles.length);
      }

      final plan = LessonPlan(
        planId:           '',
        schoolId:         widget.schoolId,
        classId:          _selectedClass!.classId,
        teacherUid:       widget.teacherUid,
        subject:          _selectedSubject,
        date:             _selectedDate,
        topicsCovered:    _topicsCtrl.text.trim(),
        homework:         _homeworkCtrl.text.trim(),
        notes:            _notesCtrl.text.trim(),
        notificationSent: false,
        attachmentUrls:   attachmentUrls,
        attachmentNames:  attachmentNames,
      );
      await fs.saveLessonPlan(plan);
      unawaited(_notifyParentsLessonPlan(plan));
      setState(() { _saving = false; _uploadProgress = 0; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lesson plan posted!'),
            backgroundColor: _kPrimary,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() { _saving = false; _uploadProgress = 0; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: _kRed),
        );
      }
    }
  }

  Future<void> _notifyParentsLessonPlan(LessonPlan plan) async {
    try {
      final fs = ref.read(firestoreServiceProvider);
      final students =
          await fs.streamStudentsByClass(plan.classId).first;
      final parentUids = <String>{};
      for (final s in students) {
        if (s.parentUid.isNotEmpty) parentUids.add(s.parentUid);
      }
      if (parentUids.isEmpty) return;
      final dateStr = DateFormat('MMM d').format(plan.date);
      final preview = plan.topicsCovered.length > 70
          ? '${plan.topicsCovered.substring(0, 70)}…'
          : plan.topicsCovered;
      await NotificationService.sendNotification(
        receiverUids: parentUids.toList(),
        title: 'New Lesson Plan — ${plan.subject}',
        body: '$preview ($dateStr)',
        extra: {
          'type':    'LESSON_PLAN',
          'classId': plan.classId,
          'planDate': plan.date.toIso8601String(),
        },
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kDark,
        foregroundColor: Colors.white,
        title: const Text('Post Lesson Plan',
            style: TextStyle(fontWeight: FontWeight.w700)),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _kPrimary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Info card ──
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _kBlue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _kBlue.withValues(alpha: 0.2)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: _kBlue, size: 18),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Lesson plans are visible to principal and parents of students in this class/subject.',
                            style: TextStyle(color: _kBlue, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Class selector ──
                  _sectionLabel('Class'),
                  const SizedBox(height: 8),
                  _dropdown<ClassModel>(
                    value: _selectedClass,
                    items: _myClasses,
                    displayText: (c) => c.displayName,
                    onChanged: (c) {
                      setState(() {
                        _selectedClass = c;
                        _updateSubjects();
                      });
                    },
                    hint: 'Select class',
                  ),
                  const SizedBox(height: 14),

                  // ── Subject selector ──
                  _sectionLabel('Subject'),
                  const SizedBox(height: 8),
                  _subjects.isEmpty
                      ? Text('No subjects found',
                          style: TextStyle(color: Colors.grey[500]))
                      : _dropdown<String>(
                          value: _selectedSubject.isNotEmpty
                              ? _selectedSubject
                              : null,
                          items: _subjects,
                          displayText: (s) => s,
                          onChanged: (s) =>
                              setState(() => _selectedSubject = s ?? ''),
                          hint: 'Select subject',
                        ),
                  const SizedBox(height: 14),

                  // ── Date ──
                  _sectionLabel('Date'),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime.now()
                            .subtract(const Duration(days: 7)),
                        lastDate: DateTime.now()
                            .add(const Duration(days: 14)),
                        builder: (_, child) => Theme(
                          data: ThemeData.light().copyWith(
                            colorScheme:
                                const ColorScheme.light(primary: _kPrimary),
                          ),
                          child: child!,
                        ),
                      );
                      if (picked != null) {
                        setState(() => _selectedDate = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              color: _kPrimary, size: 18),
                          const SizedBox(width: 10),
                          Text(
                            DateFormat('EEEE, dd MMMM yyyy')
                                .format(_selectedDate),
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          const Spacer(),
                          const Icon(Icons.edit_calendar_rounded,
                              color: _kPrimary, size: 18),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Topics covered ──
                  _sectionLabel('Topics Covered *'),
                  const SizedBox(height: 8),
                  _multilineField(
                    _topicsCtrl,
                    'E.g., Chapter 5 - Photosynthesis, Types of leaves...',
                    4,
                  ),
                  const SizedBox(height: 14),

                  // ── Homework ──
                  _sectionLabel('Homework / Assignment'),
                  const SizedBox(height: 8),
                  _multilineField(
                    _homeworkCtrl,
                    'E.g., Solve questions 1-10 from textbook page 45...',
                    3,
                  ),
                  const SizedBox(height: 14),

                  // ── Additional notes ──
                  _sectionLabel('Additional Notes'),
                  const SizedBox(height: 8),
                  _multilineField(
                    _notesCtrl,
                    'Any other notes for students/parents...',
                    3,
                  ),
                  const SizedBox(height: 14),

                  // ── Attachments ──
                  _sectionLabel('Attachments (PDF, PNG, JPG, DOC)'),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _saving ? null : _pickFiles,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _kPrimary.withValues(alpha: 0.4),
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.attach_file_rounded,
                              color: _kPrimary, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            _pickedFiles.isEmpty
                                ? 'Tap to attach files'
                                : '${_pickedFiles.length} file(s) selected',
                            style: TextStyle(
                              color: _pickedFiles.isEmpty
                                  ? Colors.grey[500]
                                  : _kPrimary,
                              fontSize: 14,
                              fontWeight: _pickedFiles.isEmpty
                                  ? FontWeight.normal
                                  : FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          if (_pickedFiles.isEmpty)
                            const Icon(Icons.add_circle_outline_rounded,
                                color: _kPrimary, size: 18),
                        ],
                      ),
                    ),
                  ),
                  if (_pickedFiles.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ...List.generate(_pickedFiles.length, (i) {
                      final f = _pickedFiles[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: _kPrimary.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: _kPrimary.withValues(alpha: 0.15)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _fileIcon(f.extension ?? ''),
                              color: _kPrimary, size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                f.name,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _removeFile(i),
                              child: const Icon(Icons.close_rounded,
                                  color: _kRed, size: 18),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                  if (_saving && _pickedFiles.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _uploadProgress,
                      backgroundColor: Colors.grey[200],
                      color: _kPrimary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Uploading files… ${(_uploadProgress * 100).toInt()}%',
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // ── Submit button ──
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _saving ? null : _submit,
                      icon: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.send_rounded,
                              color: Colors.white),
                      label: Text(
                        _saving ? 'Posting...' : 'Post Lesson Plan',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15),
                      ),
                      // Pattern F — pill/stadium shape
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kPrimary,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  // Pattern G — section header with accent bar
  Widget _sectionLabel(String label) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: _kPrimary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _dropdown<T>({
    required T? value,
    required List<T> items,
    required String Function(T) displayText,
    required void Function(T?) onChanged,
    required String hint,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kPrimary.withValues(alpha: 0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(hint,
              style: TextStyle(color: Colors.grey[400])),
          isExpanded: true,
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(displayText(item)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _multilineField(
      TextEditingController ctrl, String hint, int lines) {
    return TextField(
      controller: ctrl,
      maxLines: lines,
      // Pattern E — radius 16, filled with light bg
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
        filled: true,
        fillColor: const Color(0xFFF0FDF4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _kPrimary.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _kPrimary.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _kPrimary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.all(14),
      ),
    );
  }

  IconData _fileIcon(String ext) {
    switch (ext.toLowerCase()) {
      case 'pdf':  return Icons.picture_as_pdf_rounded;
      case 'png':
      case 'jpg':
      case 'jpeg': return Icons.image_rounded;
      case 'doc':
      case 'docx': return Icons.description_rounded;
      default:     return Icons.insert_drive_file_rounded;
    }
  }
}
