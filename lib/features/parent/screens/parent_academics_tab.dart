import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/models/student.dart';
import '../../../core/models/lesson_plan.dart';
import '../../../core/providers/core_providers.dart';
import '../parent_dashboard.dart';
import 'parent_lesson_screen.dart';
import 'parent_timetable_screen.dart';
import 'study_materials_screen.dart';
import 'report_card_screen.dart';

class ParentAcademicsTab extends ConsumerStatefulWidget {
  final Student student;
  const ParentAcademicsTab({super.key, required this.student});

  @override
  ConsumerState<ParentAcademicsTab> createState() =>
      _ParentAcademicsTabState();
}

class _ParentAcademicsTabState extends ConsumerState<ParentAcademicsTab> {
  late DateTime _lessonDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _lessonDate = now.hour >= 9
        ? DateTime(now.year, now.month, now.day)
        : DateTime(now.year, now.month, now.day - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kParentBg,
      appBar: AppBar(
        backgroundColor: kParentDark,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Text('Academics',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          const ChildSwitcherBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
            // Quick nav tiles
            Row(
              children: [
                Expanded(
                  child: _NavTile(
                    icon: Icons.schedule_rounded,
                    label: 'Time Table',
                    color: const Color(0xFF059669),
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ParentTimetableScreen(
                                student: widget.student))),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _NavTile(
                    icon: Icons.folder_open_rounded,
                    label: 'Notes & Files',
                    color: const Color(0xFF3B82F6),
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => StudyMaterialsScreen(
                                student: widget.student))),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _NavTile(
                    icon: Icons.assignment_rounded,
                    label: 'Report Card',
                    color: const Color(0xFFD97706),
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ReportCardScreen(
                                student: widget.student))),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Lesson of the day section
            _buildLessonSection(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonSection(BuildContext context) {
    final fs = ref.watch(firestoreServiceProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header with date navigator
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [kParentDark, Color(0xFF7C2D12)],
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_stories_rounded,
                      color: kParentAmber, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    "Lesson Plan",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ParentLessonScreen(
                                student: widget.student))),
                    child: Text(
                      'Full View',
                      style: TextStyle(
                        color: kParentAmber.withValues(alpha: 0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Date selector row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => setState(() => _lessonDate =
                        _lessonDate.subtract(const Duration(days: 1))),
                    icon: const Icon(Icons.chevron_left_rounded,
                        color: Colors.white),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _lessonDate,
                        firstDate: DateTime(2024),
                        lastDate: DateTime.now()
                            .add(const Duration(days: 1)),
                        builder: (ctx, child) => Theme(
                          data: ThemeData.light().copyWith(
                            colorScheme: const ColorScheme.light(
                                primary: kParentPrimary),
                          ),
                          child: child!,
                        ),
                      );
                      if (picked != null) {
                        setState(() => _lessonDate = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded,
                              color: kParentAmber, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            _isToday(_lessonDate)
                                ? 'Today'
                                : DateFormat('MMM d, EEE')
                                    .format(_lessonDate),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      final next = _lessonDate
                          .add(const Duration(days: 1));
                      if (!next.isAfter(DateTime.now())) {
                        setState(() => _lessonDate = next);
                      }
                    },
                    icon: const Icon(Icons.chevron_right_rounded,
                        color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        StreamBuilder<List<LessonPlan>>(
          stream: fs.streamLessonPlansForClass(
              widget.student.classId,
              date: _lessonDate),
          builder: (ctx, snap) {
            final plans = snap.data ?? [];
            if (plans.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Colors.grey[400], size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'No lesson plans posted for this day',
                      style: TextStyle(
                          color: Colors.grey[500], fontSize: 13),
                    ),
                  ],
                ),
              );
            }
            return Column(
              children: plans.map((p) => GestureDetector(
                onTap: () => Navigator.push(
                  ctx,
                  MaterialPageRoute(
                    builder: (_) => ParentLessonScreen(
                      student: widget.student,
                      initialDate: p.date,
                    ),
                  ),
                ),
                child: _CompactLessonCard(plan: p),
              )).toList(),
            );
          },
        ),
      ],
    );
  }

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _NavTile(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactLessonCard extends StatelessWidget {
  final LessonPlan plan;
  const _CompactLessonCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: kParentAmber),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: kParentAmber.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.auto_stories_rounded,
                            color: kParentAmber, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plan.subject,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: kParentDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              plan.topicsCovered,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                            if (plan.homework.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.assignment_rounded,
                                      size: 12, color: kParentPrimary),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'HW: ${plan.homework}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: kParentPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
