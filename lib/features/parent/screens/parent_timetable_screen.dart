import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/models/student.dart';
import '../../../core/models/timetable.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/firestore_service.dart';
import '../parent_dashboard.dart';

class ParentTimetableScreen extends ConsumerStatefulWidget {
  final Student student;
  const ParentTimetableScreen({super.key, required this.student});

  @override
  ConsumerState<ParentTimetableScreen> createState() =>
      _ParentTimetableScreenState();
}

class _ParentTimetableScreenState
    extends ConsumerState<ParentTimetableScreen> {
  // Keys must match what ManageTimetableScreen stores: full day names
  static const _days    = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  static const _dayTabs = ['MON',    'TUE',     'WED',       'THU',       'FRI',    'SAT'];

  Set<String> _excludedSubjects = {};
  bool _enrollmentLoaded = false;

  String get _todayKey {
    final wd = DateTime.now().weekday;
    if (wd == DateTime.monday)    return 'Monday';
    if (wd == DateTime.tuesday)   return 'Tuesday';
    if (wd == DateTime.wednesday) return 'Wednesday';
    if (wd == DateTime.thursday)  return 'Thursday';
    if (wd == DateTime.friday)    return 'Friday';
    if (wd == DateTime.saturday)  return 'Saturday';
    return 'Monday';
  }

  @override
  void initState() {
    super.initState();
    _loadEnrollments();
  }

  Future<void> _loadEnrollments() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('subjectEnrollments')
          .where('classId', isEqualTo: widget.student.classId)
          .get();

      final excluded = <String>{};
      for (final doc in snap.docs) {
        final data = doc.data();
        final subjectName = data['subjectName'] as String? ?? '';
        final excludedIds =
            (data['excludedStudentIds'] as List<dynamic>?)?.cast<String>() ?? [];
        if (excludedIds.contains(widget.student.studentId)) {
          excluded.add(subjectName);
        }
      }
      if (mounted) {
        setState(() {
          _excludedSubjects = excluded;
          _enrollmentLoaded = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _enrollmentLoaded = true);
    }
  }

  List<Period> _filterPeriods(List<Period> all) {
    if (_excludedSubjects.isEmpty) return all;
    return all.where((p) => !_excludedSubjects.contains(p.subject)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final fs = ref.watch(firestoreServiceProvider);

    return DefaultTabController(
      length: _days.length,
      initialIndex: _days.indexOf(_todayKey).clamp(0, _days.length - 1),
      child: Scaffold(
        backgroundColor: kParentBg,
        appBar: AppBar(
          backgroundColor: kParentDark,
          foregroundColor: Colors.white,
          title: const Text('Time Table',
              style: TextStyle(fontWeight: FontWeight.w700)),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: kParentAmber,
            labelColor: kParentAmber,
            unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
            labelStyle: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: 13),
            tabs: _dayTabs.map((d) => Tab(text: d)).toList(),
          ),
        ),
        body: widget.student.classId.isEmpty
            ? const Center(
                child: Text('No class assigned to this student.',
                    style: TextStyle(color: Colors.grey)))
            : StreamBuilder<Timetable?>(
          stream: fs.streamTimetable(widget.student.classId),
          builder: (ctx, snap) {
            if (snap.connectionState == ConnectionState.waiting ||
                !_enrollmentLoaded) {
              return const Center(
                  child: CircularProgressIndicator(color: kParentPrimary));
            }
            if (snap.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Could not load timetable.\n${snap.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ),
              );
            }
            final timetable = snap.data;

            return TabBarView(
              children: _days.map((day) {
                final allPeriods = timetable?.periodsForDay(day) ?? [];
                final periods = _filterPeriods(allPeriods);
                if (periods.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.schedule_rounded,
                            size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'No periods on $day',
                          style: TextStyle(
                              color: Colors.grey[500], fontSize: 15),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: periods.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (ctx, i) => _PeriodCard(
                    period: periods[i],
                    index: i,
                    fs: fs,
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}

class _PeriodCard extends StatelessWidget {
  final Period period;
  final int index;
  final FirestoreService fs;
  const _PeriodCard(
      {required this.period, required this.index, required this.fs});

  static const _subjectColors = [
    Color(0xFFD97706), Color(0xFFD97706), Color(0xFF059669),
    Color(0xFF3B82F6), Color(0xFFF59E0B), Color(0xFFEC4899),
  ];

  @override
  Widget build(BuildContext context) {
    final color = _subjectColors[index % _subjectColors.length];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          // Period number + color stripe
          Container(
            width: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(16)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Text(
                  '${period.periodNumber}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                Text(
                  'Per.',
                  style: TextStyle(fontSize: 9, color: color),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    period.subject,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: kParentDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  FutureBuilder<UserModel?>(
                    future: period.teacherUid.isNotEmpty
                        ? fs.getUser(period.teacherUid)
                        : null,
                    builder: (ctx, s) => Text(
                      s.data?.name ?? 'Teacher',
                      style: TextStyle(
                          color: Colors.grey[600], fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    period.startTime,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  period.endTime,
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey[400]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
