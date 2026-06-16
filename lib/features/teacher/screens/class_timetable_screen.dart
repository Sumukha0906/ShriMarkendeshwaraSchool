import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/models/class_model.dart';
import '../../../core/models/timetable.dart';

const _kPrimary = Color(0xFF065F46);
const _kDark    = Color(0xFF022C22);
const _kBg      = Color(0xFFF0FDF4);
const _kAmber   = Color(0xFFF59E0B);

class ClassTimetableScreen extends ConsumerStatefulWidget {
  final ClassModel cls;
  final String teacherUid;

  const ClassTimetableScreen({
    super.key,
    required this.cls,
    required this.teacherUid,
  });

  @override
  ConsumerState<ClassTimetableScreen> createState() =>
      _ClassTimetableScreenState();
}

class _ClassTimetableScreenState extends ConsumerState<ClassTimetableScreen> {
  final _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  String _selectedDay = 'Monday';

  @override
  Widget build(BuildContext context) {
    final fs = ref.watch(firestoreServiceProvider);

    return Scaffold(
      backgroundColor: _kBg,
      // Pattern A — rounded bottom AppBar
      appBar: AppBar(
        backgroundColor: _kDark,
        foregroundColor: Colors.white,
        title: Text(
          'Timetable — ${widget.cls.displayName}',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: StreamBuilder<Timetable?>(
        stream: fs.streamTimetable(widget.cls.classId),
        builder: (ctx, snap) {
          final timetable = snap.data;

          return Column(
            children: [
              // Day selector
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: _days.map((day) {
                      final selected = _selectedDay == day;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedDay = day),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected ? _kPrimary : _kBg,
                            borderRadius: BorderRadius.circular(8),
                            border: selected
                                ? null
                                : Border.all(color: Colors.grey.shade200),
                          ),
                          child: Text(
                            day.substring(0, 3),
                            style: TextStyle(
                              color: selected ? Colors.white : Colors.grey[700],
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // Periods
              Expanded(
                child: timetable == null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _kPrimary.withValues(alpha: 0.08),
                              ),
                              child: Icon(Icons.schedule_rounded,
                                  size: 38, color: _kPrimary.withValues(alpha: 0.5)),
                            ),
                            const SizedBox(height: 16),
                            const Text('No timetable set for this class'),
                          ],
                        ),
                      )
                    : _buildDayPeriods(ctx, timetable),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDayPeriods(BuildContext context, Timetable timetable) {
    final periods = timetable.periodsForDay(_selectedDay);
    if (periods.isEmpty) {
      return Center(
        child: Text(
          'No periods on $_selectedDay',
          style: TextStyle(color: Colors.grey[500]),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: periods.length,
      itemBuilder: (_, i) {
        final period = periods[i];
        final isMyPeriod = period.teacherUid == widget.teacherUid ||
            period.substituteTeacherUid == widget.teacherUid;

        // Pattern H — top accent stripe on timetable cards
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border(
              top: BorderSide(
                color: isMyPeriod ? _kPrimary : Colors.grey.shade300,
                width: 3,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Period number
              Container(
                width: 50,
                height: 70,
                decoration: BoxDecoration(
                  color: isMyPeriod
                      ? _kPrimary
                      : Colors.grey[100],
                  borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(12)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${period.periodNumber}',
                      style: TextStyle(
                        color: isMyPeriod ? Colors.white : Colors.grey[600],
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'Per.',
                      style: TextStyle(
                        color: isMyPeriod
                            ? Colors.white.withValues(alpha: 0.7)
                            : Colors.grey[400],
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),

              // Subject & time
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        period.subject,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${period.startTime} — ${period.endTime}',
                        style: TextStyle(
                            color: Colors.grey[500], fontSize: 12),
                      ),
                      if (period.substituteTeacherUid.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _kAmber.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Substitute assigned',
                              style: TextStyle(
                                color: _kAmber,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Mark substitute button
              if (isMyPeriod || period.teacherUid == widget.teacherUid)
                GestureDetector(
                  onTap: () => _showSubstituteDialog(context, period),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _kAmber.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: _kAmber.withValues(alpha: 0.3)),
                      ),
                      child: const Text(
                        'Sub',
                        style: TextStyle(
                          color: _kAmber,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showSubstituteDialog(BuildContext context, Period period) {
    final commentCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Mark Substitute / Add Note',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${period.subject} • Period ${period.periodNumber}',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: commentCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Add a note (e.g., "I took this class today as substitute for...")',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () async {
              final fs = ref.read(firestoreServiceProvider);
              final user = ref.read(currentUserProvider).value;
              await fs.addSubstituteComment(
                classId:          widget.cls.classId,
                day:              _selectedDay,
                periodNumber:     period.periodNumber,
                substituteUid:    widget.teacherUid,
                substituteName:   user?.name ?? 'Teacher',
                originalTeacherUid: period.teacherUid,
                comment:          commentCtrl.text.trim(),
                date:             DateTime.now(),
              );
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Substitute note added'),
                    backgroundColor: _kPrimary,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: _kPrimary),
            child: const Text('Save',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
