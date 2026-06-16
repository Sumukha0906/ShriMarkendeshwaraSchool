import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/models/class_model.dart';
import '../../../core/models/timetable.dart';
import '../../../core/models/user_model.dart';

const _blue  = Color(0xFF3B82F6);
const _dark  = Color(0xFF1D4ED8);
const _bg    = Color(0xFFF0F7FF);
const _amber = Color(0xFFF59E0B);
const _red   = Color(0xFFEF4444);

const _days  = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

class ManageTimetableScreen extends ConsumerStatefulWidget {
  final ClassModel cls;

  const ManageTimetableScreen({super.key, required this.cls});

  @override
  ConsumerState<ManageTimetableScreen> createState() =>
      _ManageTimetableScreenState();
}

class _ManageTimetableScreenState
    extends ConsumerState<ManageTimetableScreen> {
  String _selectedDay = 'Monday';
  bool   _saving      = false;

  // ── Save helpers ──────────────────────────────────────────────

  Future<void> _saveTimetable(Timetable t) async {
    setState(() => _saving = true);
    try {
      final fs   = ref.read(firestoreServiceProvider);
      final user = ref.read(currentUserProvider).value;
      final updated = t.copyWith(
        updatedAt: DateTime.now(),
        updatedBy: user?.name ?? '',
      );
      await fs.saveTimetable(updated);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error saving: $e'),
              backgroundColor: _red),
        );
      }
    }
    setState(() => _saving = false);
  }

  Future<void> _addOrEditPeriod(
      Timetable current, Period? existing) async {
    final schoolId = ref.read(currentUserProvider).value?.schoolId ?? '';
    final allTeachers = await ref
        .read(firestoreServiceProvider)
        .streamSchoolTeachers(schoolId)
        .first;

    // Build list of available subjects from class teachers
    final subjects = <String>{};
    for (final st in widget.cls.subjectTeachers) {
      subjects.add(st.subject);
    }

    if (!mounted) return;
    final result = await showModalBottomSheet<Period>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _PeriodFormSheet(
        existing:    existing,
        subjects:    subjects.toList()..sort(),
        teachers:    allTeachers,
        classModel:  widget.cls,
        existingPeriods: current.periodsForDay(_selectedDay),
      ),
    );

    if (result == null) return;

    // Build updated schedule
    final dayPeriods = List<Period>.from(current.periodsForDay(_selectedDay));
    if (existing != null) {
      final idx = dayPeriods
          .indexWhere((p) => p.periodNumber == existing.periodNumber);
      if (idx >= 0) {
        dayPeriods[idx] = result;
      } else {
        dayPeriods.add(result);
      }
    } else {
      dayPeriods.add(result);
    }
    dayPeriods.sort((a, b) => a.periodNumber.compareTo(b.periodNumber));

    final newSchedule =
        Map<String, List<Period>>.from(current.schedule);
    newSchedule[_selectedDay] = dayPeriods;

    await _saveTimetable(current.copyWith(schedule: newSchedule));
  }

  Future<void> _deletePeriod(Timetable current, Period period) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Period?',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text(
            'Delete Period ${period.periodNumber} (${period.subject})?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: _red),
            child: const Text('Delete',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    final dayPeriods = List<Period>.from(current.periodsForDay(_selectedDay))
      ..removeWhere((p) => p.periodNumber == period.periodNumber);
    final newSchedule =
        Map<String, List<Period>>.from(current.schedule);
    newSchedule[_selectedDay] = dayPeriods;

    await _saveTimetable(current.copyWith(schedule: newSchedule));
  }

  @override
  Widget build(BuildContext context) {
    final fs = ref.watch(firestoreServiceProvider);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _dark,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.cls.displayName,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 16)),
            const Text('Manage Timetable',
                style: TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2)),
            ),
        ],
      ),
      body: StreamBuilder<Timetable?>(
        stream: fs.streamTimetable(widget.cls.classId),
        builder: (ctx, snap) {
          final timetable = snap.data ??
              Timetable(
                classId:  widget.cls.classId,
                schoolId: widget.cls.schoolId,
              );

          return Column(
            children: [
              // ── Day selector ────────────────────────────────
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: _days.map((day) {
                      final selected = _selectedDay == day;
                      final count =
                          timetable.periodsForDay(day).length;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedDay = day),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected
                                ? _dark
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Text(
                                day.substring(0, 3),
                                style: TextStyle(
                                  color: selected
                                      ? Colors.white
                                      : Colors.grey[700],
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              if (count > 0) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? Colors.white.withValues(alpha: 0.25)
                                        : _blue.withValues(alpha: 0.15),
                                    borderRadius:
                                        BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '$count',
                                    style: TextStyle(
                                      color: selected
                                          ? Colors.white
                                          : _blue,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // ── Periods list ─────────────────────────────────
              Expanded(
                child: _buildDayView(timetable),
              ),
            ],
          );
        },
      ),
      floatingActionButton: StreamBuilder<Timetable?>(
        stream: fs.streamTimetable(widget.cls.classId),
        builder: (ctx, snap) {
          final timetable = snap.data ??
              Timetable(
                classId:  widget.cls.classId,
                schoolId: widget.cls.schoolId,
              );
          return FloatingActionButton.extended(
            onPressed: () => _addOrEditPeriod(timetable, null),
            backgroundColor: _dark,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Add Period',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          );
        },
      ),
    );
  }

  Widget _buildDayView(Timetable timetable) {
    final periods = timetable.periodsForDay(_selectedDay);
    final fs = ref.watch(firestoreServiceProvider);

    if (periods.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.schedule_rounded,
                size: 56, color: _blue.withValues(alpha: 0.25)),
            const SizedBox(height: 16),
            Text(
              'No periods on $_selectedDay',
              style: TextStyle(color: Colors.grey[500], fontSize: 15),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: () => _addOrEditPeriod(timetable, null),
              icon: const Icon(Icons.add, color: _blue),
              label: const Text('Add First Period',
                  style: TextStyle(color: _blue, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: periods.length,
      itemBuilder: (_, i) {
        final p = periods[i];

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _blue.withValues(alpha: 0.12)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
              ),
            ],
          ),
          child: Row(
            children: [
              // Period number tab
              Container(
                width: 52,
                height: 72,
                decoration: BoxDecoration(
                  color: _dark,
                  borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(14)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${p.periodNumber}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                    const Text('Per.',
                        style: TextStyle(
                            color: Colors.white70, fontSize: 9)),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              p.subject,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${p.startTime} – ${p.endTime}',
                              style: const TextStyle(
                                  color: _blue,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      FutureBuilder<UserModel?>(
                        future: fs.getUser(p.teacherUid),
                        builder: (_, snap) {
                          final name = snap.data?.name ?? '...';
                          return Row(
                            children: [
                              Icon(Icons.person_outline,
                                  size: 13,
                                  color: Colors.grey[400]),
                              const SizedBox(width: 4),
                              Text(name,
                                  style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 12)),
                            ],
                          );
                        },
                      ),
                      if (p.substituteTeacherUid.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _amber.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('Substitute assigned',
                                style: TextStyle(
                                    color: _amber,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Edit / delete
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon:
                        const Icon(Icons.edit_rounded, color: _blue, size: 18),
                    onPressed: () => _addOrEditPeriod(timetable, p),
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    icon:
                        const Icon(Icons.delete_rounded, color: _red, size: 18),
                    onPressed: () => _deletePeriod(timetable, p),
                    tooltip: 'Delete',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Period form bottom sheet
// ═══════════════════════════════════════════════════════════════
class _PeriodFormSheet extends StatefulWidget {
  final Period?        existing;
  final List<String>   subjects;
  final List<UserModel> teachers;
  final ClassModel     classModel;
  final List<Period>   existingPeriods;

  const _PeriodFormSheet({
    required this.existing,
    required this.subjects,
    required this.teachers,
    required this.classModel,
    required this.existingPeriods,
  });

  @override
  State<_PeriodFormSheet> createState() => _PeriodFormSheetState();
}

class _PeriodFormSheetState extends State<_PeriodFormSheet> {
  late int          _periodNumber;
  late String       _subject;
  late String       _teacherUid;
  late String       _startTime;
  late String       _endTime;
  bool              _useCustomSubject = false;
  final _customCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _periodNumber = e.periodNumber;
      _teacherUid   = e.teacherUid;
      _startTime    = e.startTime;
      _endTime      = e.endTime;

      // Check if subject is in predefined list
      if (widget.subjects.contains(e.subject)) {
        _subject = e.subject;
        _useCustomSubject = false;
      } else {
        _subject          = '';
        _useCustomSubject = true;
        _customCtrl.text  = e.subject;
      }
    } else {
      // Next period number
      final usedNumbers = widget.existingPeriods
          .map((p) => p.periodNumber)
          .toSet();
      int next = 1;
      while (usedNumbers.contains(next)) next++;
      _periodNumber     = next;
      _subject          = widget.subjects.isNotEmpty ? widget.subjects.first : '';
      _teacherUid       = _autoTeacher();
      _startTime        = '08:00 AM';
      _endTime          = '08:45 AM';
    }
  }

  String _autoTeacher() {
    // If subject matches a subject teacher, auto-select that teacher
    if (_subject.isNotEmpty) {
      final match = widget.classModel.subjectTeachers
          .where((st) => st.subject == _subject)
          .firstOrNull;
      if (match != null) return match.teacherUid;
    }
    // Fallback to class teacher
    if (widget.classModel.classTeacherUid.isNotEmpty) {
      return widget.classModel.classTeacherUid;
    }
    return widget.teachers.isNotEmpty ? widget.teachers.first.uid : '';
  }

  Future<void> _pickTime(bool isStart) async {
    final current = _parseTime(isStart ? _startTime : _endTime);
    final picked = await showTimePicker(
      context: context,
      initialTime: current,
    );
    if (picked == null) return;
    final formatted = _formatTime(picked);
    setState(() {
      if (isStart) _startTime = formatted;
      else          _endTime   = formatted;
    });
  }

  TimeOfDay _parseTime(String t) {
    try {
      final parts = t.split(' ');
      final hm    = parts[0].split(':');
      var h = int.parse(hm[0]);
      final m = int.parse(hm[1]);
      if (parts[1] == 'PM' && h != 12) h += 12;
      if (parts[1] == 'AM' && h == 12) h = 0;
      return TimeOfDay(hour: h, minute: m);
    } catch (_) {
      return const TimeOfDay(hour: 8, minute: 0);
    }
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  @override
  void dispose() {
    _customCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;

    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
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
            const SizedBox(height: 20),

            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: _dark.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.schedule_rounded,
                      color: _dark, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  isEdit ? 'Edit Period' : 'Add Period',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Period number
            _label('Period Number'),
            DropdownButtonFormField<int>(
              value: _periodNumber,
              decoration: _inputDeco(''),
              items: List.generate(12, (i) => i + 1)
                  .map((n) => DropdownMenuItem(
                      value: n, child: Text('Period $n')))
                  .toList(),
              onChanged: (v) => setState(() => _periodNumber = v!),
            ),
            const SizedBox(height: 14),

            // Subject
            _label('Subject'),
            if (widget.subjects.isNotEmpty) ...[
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _useCustomSubject ? null : (_subject.isEmpty ? null : _subject),
                      hint: const Text('Select subject'),
                      decoration: _inputDeco(''),
                      items: [
                        ...widget.subjects.map((s) =>
                            DropdownMenuItem(value: s, child: Text(s))),
                        const DropdownMenuItem(
                            value: '__custom__',
                            child: Text('Other (type manually)')),
                      ],
                      onChanged: (v) {
                        if (v == '__custom__') {
                          setState(() {
                            _useCustomSubject = true;
                            _subject = '';
                          });
                        } else if (v != null) {
                          setState(() {
                            _useCustomSubject = false;
                            _subject = v;
                            _teacherUid = _autoTeacher();
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
            if (_useCustomSubject || widget.subjects.isEmpty) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _customCtrl,
                decoration: _inputDeco('Type subject name...'),
                textCapitalization: TextCapitalization.words,
              ),
            ],
            const SizedBox(height: 14),

            // Teacher
            _label('Teacher'),
            DropdownButtonFormField<String>(
              value: _teacherUid.isEmpty ? null : _teacherUid,
              hint: const Text('Select teacher'),
              decoration: _inputDeco(''),
              items: widget.teachers
                  .map((t) => DropdownMenuItem(
                      value: t.uid, child: Text(t.name)))
                  .toList(),
              onChanged: (v) => setState(() => _teacherUid = v ?? ''),
            ),
            const SizedBox(height: 14),

            // Time
            _label('Time'),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _pickTime(true),
                    child: _timeBox('Start', _startTime),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text('to',
                      style: TextStyle(
                          color: Colors.grey[400],
                          fontWeight: FontWeight.w500)),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _pickTime(false),
                    child: _timeBox('End', _endTime),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Save
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final subject = (_useCustomSubject || widget.subjects.isEmpty)
                      ? _customCtrl.text.trim()
                      : _subject;
                  if (subject.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a subject name')));
                    return;
                  }
                  if (_teacherUid.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select a teacher')));
                    return;
                  }

                  Navigator.pop(
                    context,
                    Period(
                      periodNumber: _periodNumber,
                      subject:      subject,
                      teacherUid:   _teacherUid,
                      startTime:    _startTime,
                      endTime:      _endTime,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _dark,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  isEdit ? 'Update Period' : 'Add Period',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: Colors.grey[600])),
      );

  InputDecoration _inputDeco(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey[200]!)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey[200]!)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      );

  Widget _timeBox(String label, String time) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style:
                    TextStyle(fontSize: 10, color: Colors.grey[500])),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.access_time_rounded,
                    size: 14, color: _dark),
                const SizedBox(width: 4),
                Text(time,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: _dark)),
              ],
            ),
          ],
        ),
      );
}
