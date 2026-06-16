import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/models/class_model.dart';
import '../../../core/models/student.dart';
import '../../../core/models/attendance.dart';
import '../../../core/utils/app_logger.dart';

const _kPrimary = Color(0xFF065F46);
const _kDark    = Color(0xFF022C22);
const _kBg      = Color(0xFFF0FDF4);
const _kRed     = Color(0xFFEF4444);
const _kAmber   = Color(0xFFF59E0B);

class MarkAttendanceScreen extends ConsumerStatefulWidget {
  final String schoolId;
  final String teacherUid;
  final String? preselectedClassId;

  const MarkAttendanceScreen({
    super.key,
    required this.schoolId,
    required this.teacherUid,
    this.preselectedClassId,
  });

  @override
  ConsumerState<MarkAttendanceScreen> createState() =>
      _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends ConsumerState<MarkAttendanceScreen> {
  ClassModel? _selectedClass;
  List<Student> _students = [];
  AttendanceSession? _existingSession;
  Map<String, AttendanceStatus> _statuses = {};
  Map<String, String> _notes = {};
  bool _loading = false;
  bool _saving = false;
  bool _isSubstitute = false;
  DateTime _selectedDate = DateTime.now();
  List<ClassModel> _allClasses = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadClasses());
  }

  Future<void> _loadClasses() async {
    final fs = ref.read(firestoreServiceProvider);
    try {
      final classes = await fs
          .streamAllClassesForTeacher(widget.schoolId, widget.teacherUid)
          .first;
      // Also get all school classes for substitute marking
      final allClasses =
          await fs.streamSchoolClasses(widget.schoolId).first;
      setState(() {
        _allClasses = allClasses;
        if (widget.preselectedClassId != null) {
          _selectedClass = classes.firstWhere(
            (c) => c.classId == widget.preselectedClassId,
            orElse: () => classes.isNotEmpty ? classes.first : allClasses.first,
          );
        } else if (classes.isNotEmpty) {
          _selectedClass = classes.first;
        }
      });
      if (_selectedClass != null) await _loadAttendance();
    } catch (e) {
      _showError('Failed to load classes');
    }
  }

  Future<void> _loadAttendance() async {
    if (_selectedClass == null) return;
    setState(() => _loading = true);

    final fs = ref.read(firestoreServiceProvider);
    try {
      // fetchStudentsByClass forces a server read, bypassing stale local cache
      // so students added from the website appear immediately.
      final students = await fs.fetchStudentsByClass(_selectedClass!.classId);
      final session = await fs.getAttendanceSession(
          _selectedClass!.classId, _selectedDate);

      // Get student IDs with approved leave covering the selected date
      final approvedLeaveIds = await fs.getApprovedLeaveStudentIdsForDate(
          _selectedClass!.classId, _selectedDate);

      final statuses = <String, AttendanceStatus>{};
      final notes    = <String, String>{};

      for (final s in students) {
        if (session != null) {
          final record =
              session.records.where((r) => r.studentId == s.studentId).firstOrNull;
          statuses[s.studentId] = record?.status ?? AttendanceStatus.PRESENT;
          notes[s.studentId]    = record?.note ?? '';
        } else {
          // Pre-fill LEAVE only for students with an approved leave on this date
          statuses[s.studentId] = approvedLeaveIds.contains(s.studentId)
              ? AttendanceStatus.LEAVE
              : AttendanceStatus.PRESENT;
          notes[s.studentId] = '';
        }
      }

      setState(() {
        _students        = students;
        _existingSession = session;
        _statuses        = statuses;
        _notes           = notes;
        _loading         = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      _showError('Failed to load attendance');
    }
  }

  Future<void> _saveAttendance() async {
    if (_selectedClass == null || _students.isEmpty) return;
    AppLogger.i('Attendance', 'Saving attendance class=${_selectedClass!.classId} students=${_students.length}');
    setState(() => _saving = true);

    final fs = ref.read(firestoreServiceProvider);
    final user = ref.read(currentUserProvider).value;

    try {
      final records = _students.map((s) {
        return AttendanceRecord(
          studentId: s.studentId,
          status: _statuses[s.studentId] ?? AttendanceStatus.PRESENT,
          note: _notes[s.studentId] ?? '',
        );
      }).toList();

      if (_existingSession == null) {
        // New session
        final session = AttendanceSession(
          sessionId: '',
          classId:   _selectedClass!.classId,
          schoolId:  widget.schoolId,
          date:      _selectedDate,
          markedBy:  widget.teacherUid,
          markedAt:  DateTime.now(),
          records:   records,
        );
        await fs.saveAttendanceSession(session);
      } else {
        // Find changed students
        final changedIds = <String>[];
        for (final s in _students) {
          final oldRecord = _existingSession!.records
              .where((r) => r.studentId == s.studentId)
              .firstOrNull;
          if (oldRecord?.status != _statuses[s.studentId]) {
            changedIds.add(s.studentId);
          }
        }

        final updatedSession = _existingSession!.copyWith(
          records:  records,
          markedBy: widget.teacherUid,
          markedAt: DateTime.now(),
        );
        await fs.updateAttendanceWithChanges(
          session:          updatedSession,
          changedStudentIds: changedIds,
          teacherName:      user?.name ?? 'Teacher',
        );
      }

      // Notify parents in background (non-blocking)
      final className = _selectedClass?.displayName ?? '';
      final teacherName = user?.name ?? 'Teacher';
      final savedSession = _existingSession == null
          ? AttendanceSession(
              sessionId: '',
              classId:   _selectedClass!.classId,
              schoolId:  widget.schoolId,
              date:      _selectedDate,
              markedBy:  widget.teacherUid,
              records:   records,
            )
          : _existingSession!.copyWith(records: records);
      fs.notifyParentsAttendance(
        session:     savedSession,
        className:   className,
        teacherName: teacherName,
      );

      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Attendance saved successfully!'),
            backgroundColor: _kPrimary,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _saving = false);
      _showError('Failed to save attendance: $e');
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: _kRed),
    );
  }

  int get _presentCount =>
      _statuses.values.where((s) => s == AttendanceStatus.PRESENT).length;
  int get _absentCount =>
      _statuses.values.where((s) => s == AttendanceStatus.ABSENT).length;
  int get _leaveCount =>
      _statuses.values.where((s) => s == AttendanceStatus.LEAVE).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: _kDark,
            foregroundColor: Colors.white,
            expandedHeight: 120,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                _existingSession != null ? 'Edit Attendance' : 'Mark Attendance',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF065F46), _kDark],
                  ),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                ),
              ),
            ),
          ),

          // ── Class Selector ──
          SliverToBoxAdapter(child: _buildClassSelector()),

          // ── Date Selector ──
          SliverToBoxAdapter(child: _buildDateSelector()),

          // ── Substitute Toggle ──
          SliverToBoxAdapter(child: _buildSubstituteSection()),

          // ── Stats Bar ──
          if (_students.isNotEmpty)
            SliverToBoxAdapter(child: _buildStatsBar()),

          // ── Mark All Row ──
          if (_students.isNotEmpty)
            SliverToBoxAdapter(child: _buildMarkAllRow()),

          // ── Students List ──
          if (_loading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(48),
                child: Center(child: CircularProgressIndicator(color: _kPrimary)),
              ),
            )
          else if (_students.isEmpty)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(48),
                  child: Text('No students in this class'),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => _StudentAttendanceTile(
                  student:  _students[i],
                  status:   _statuses[_students[i].studentId] ?? AttendanceStatus.PRESENT,
                  note:     _notes[_students[i].studentId] ?? '',
                  onStatusChanged: (s) =>
                      setState(() => _statuses[_students[i].studentId] = s),
                  onNoteChanged: (n) =>
                      setState(() => _notes[_students[i].studentId] = n),
                ),
                childCount: _students.length,
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),

      // ── Save FAB ──
      floatingActionButton: _students.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _saving ? null : _saveAttendance,
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
                _saving ? 'Saving...' : 'Save Attendance',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700),
              ),
            )
          : null,
    );
  }

  Widget _buildClassSelector() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kPrimary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.class_, color: _kPrimary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<ClassModel>(
                value: _selectedClass,
                hint: const Text('Select Class'),
                isExpanded: true,
                items: (_isSubstitute ? _allClasses : _allClasses)
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(c.displayName),
                        ))
                    .toList(),
                onChanged: (c) {
                  setState(() {
                    _selectedClass = c;
                    _students = [];
                    _statuses = {};
                    _notes = {};
                    _existingSession = null;
                  });
                  _loadAttendance();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime.now().subtract(const Duration(days: 30)),
          lastDate: DateTime.now(),
          builder: (_, child) => Theme(
            data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(primary: _kPrimary),
            ),
            child: child!,
          ),
        );
        if (picked != null && picked != _selectedDate) {
          setState(() => _selectedDate = picked);
          await _loadAttendance();
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kPrimary.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: _kPrimary, size: 18),
            const SizedBox(width: 10),
            Text(
              DateFormat('EEEE, dd MMMM yyyy').format(_selectedDate),
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const Spacer(),
            const Icon(Icons.edit_calendar_rounded, color: _kPrimary, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildSubstituteSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.swap_horiz_rounded, color: _kAmber, size: 20),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Marking as Substitute Teacher',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          Switch(
            value: _isSubstitute,
            onChanged: (v) => setState(() => _isSubstitute = v),
            activeColor: _kAmber,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [_kDark, _kPrimary]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statChip('Present', '$_presentCount', Colors.green[300]!),
          _statChip('Absent', '$_absentCount', _kRed),
          _statChip('Leave', '$_leaveCount', Colors.blue[300]!),
          _statChip('Total', '${_students.length}', Colors.white),
        ],
      ),
    );
  }

  Widget _statChip(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
              color: color, fontWeight: FontWeight.w800, fontSize: 18),
        ),
        Text(
          label,
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7), fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildMarkAllRow() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Row(
        children: [
          Text(
            'Mark All:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(width: 10),
          ...[
            ('Present', AttendanceStatus.PRESENT, _kPrimary),
            ('Absent', AttendanceStatus.ABSENT, _kRed),
          ].map((t) => GestureDetector(
                onTap: () => setState(() {
                  for (final s in _students) {
                    _statuses[s.studentId] = t.$2;
                  }
                }),
                child: Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: t.$3.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: t.$3.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    t.$1,
                    style: TextStyle(
                        color: t.$3,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

class _StudentAttendanceTile extends StatelessWidget {
  final Student student;
  final AttendanceStatus status;
  final String note;
  final void Function(AttendanceStatus) onStatusChanged;
  final void Function(String) onNoteChanged;

  const _StudentAttendanceTile({
    required this.student,
    required this.status,
    required this.note,
    required this.onStatusChanged,
    required this.onNoteChanged,
  });

  Color get _statusColor {
    switch (status) {
      case AttendanceStatus.PRESENT: return _kPrimary;
      case AttendanceStatus.ABSENT:  return _kRed;
      case AttendanceStatus.LATE:    return _kRed;
      case AttendanceStatus.LEAVE:   return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pattern B — left border accent
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: _statusColor, width: 4),
          top: BorderSide(color: _statusColor.withValues(alpha: 0.15), width: 1),
          right: BorderSide(color: _statusColor.withValues(alpha: 0.15), width: 1),
          bottom: BorderSide(color: _statusColor.withValues(alpha: 0.15), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                // Roll number
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      student.rollNo.isNotEmpty ? student.rollNo : '–',
                      style: TextStyle(
                        color: _statusColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    student.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
                // Status buttons
                _statusBtn(AttendanceStatus.PRESENT, 'P', _kPrimary),
                const SizedBox(width: 4),
                _statusBtn(AttendanceStatus.ABSENT, 'A', _kRed),
                const SizedBox(width: 4),
                _statusBtn(AttendanceStatus.LEAVE, 'Lv', Colors.blue),
              ],
            ),
          ),
          // Note field (only show if absent or late)
          if (status == AttendanceStatus.ABSENT)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: TextField(
                controller: TextEditingController(text: note)
                  ..selection = TextSelection.collapsed(offset: note.length),
                onChanged: onNoteChanged,
                decoration: InputDecoration(
                  hintText: 'Add note (optional)',
                  hintStyle:
                      TextStyle(color: Colors.grey[400], fontSize: 12),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                        color: _statusColor.withValues(alpha: 0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                        color: _statusColor.withValues(alpha: 0.2)),
                  ),
                ),
                style: const TextStyle(fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _statusBtn(AttendanceStatus s, String label, Color color) {
    final selected = status == s;
    return GestureDetector(
      onTap: () => onStatusChanged(s),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? color : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected ? color : color.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : color,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
