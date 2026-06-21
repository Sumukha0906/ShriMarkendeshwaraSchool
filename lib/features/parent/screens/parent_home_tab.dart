import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/models/student.dart';
import '../../../core/models/leave_request.dart';
import 'parent_notification_bell.dart';
import '../../../core/models/attendance.dart';
import '../../../core/models/announcement.dart';
import '../../../core/models/lesson_plan.dart';
import '../../../core/models/fee.dart';
import '../parent_dashboard.dart';
import 'apply_leave_screen.dart';
import 'early_pickup_screen.dart';
import 'parent_lesson_screen.dart';
import 'parent_timetable_screen.dart';
import 'announcements_screen.dart';

class ParentHomeTab extends ConsumerWidget {
  final Student student;
  final List<Student> allChildren;
  final int selectedIndex;

  const ParentHomeTab({
    super.key,
    required this.student,
    required this.allChildren,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(context, ref),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Multi-child selector
                if (allChildren.length > 1) ...[
                  _buildChildSelector(context, ref),
                  const SizedBox(height: 16),
                ],

                // Today's attendance card
                _TodayAttendanceCard(student: student),
                const SizedBox(height: 16),

                // Quick actions
                _buildQuickActions(context, ref),
                const SizedBox(height: 20),

                // Today's lesson preview
                _TodayLessonPreview(student: student),
                const SizedBox(height: 20),

                // Fee due card
                _FeeStatusCard(student: student),
                const SizedBox(height: 20),

                // Recent announcements
                _RecentAnnouncements(student: student),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(BuildContext context, WidgetRef ref) {
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      backgroundColor: kParentDark,
      foregroundColor: Colors.white,
      automaticallyImplyLeading: false,
      actions: [
        ParentNotificationBell(student: student),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [kParentDark, Color(0xFF7C2D12)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: kParentPrimary.withValues(alpha: 0.2),
                          border: Border.all(
                            color: kParentAmber.withValues(alpha: 0.6),
                            width: 2,
                          ),
                        ),
                        child: student.photoUrl.isNotEmpty
                            ? ClipOval(child: Image.network(student.photoUrl, fit: BoxFit.cover))
                            : const Icon(Icons.person_rounded,
                                color: kParentAmber, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              student.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'Roll No: ${student.rollNo.isEmpty ? "N/A" : student.rollNo}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.65),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Amber badge for today's date
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: kParentAmber.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: kParentAmber.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          DateFormat('EEE, MMM d').format(DateTime.now()),
                          style: const TextStyle(
                            color: kParentAmber,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChildSelector(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Child',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: allChildren.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (ctx, i) {
              final c = allChildren[i];
              final isSelected = i == selectedIndex;
              return GestureDetector(
                onTap: () =>
                    ref.read(selectedChildIndexProvider.notifier).state = i,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? kParentPrimary : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected
                          ? kParentPrimary
                          : Colors.grey[300]!,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: kParentPrimary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : [],
                  ),
                  child: Text(
                    c.name.split(' ').first,
                    style: TextStyle(
                      color:
                          isSelected ? Colors.white : Colors.grey[700],
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, WidgetRef ref) {
    final actions = [
      _QuickAction(
        icon: Icons.event_busy_rounded,
        label: 'Apply\nLeave',
        color: const Color(0xFFD97706),
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => ApplyLeaveScreen(student: student))),
      ),
      _QuickAction(
        icon: Icons.directions_car_rounded,
        label: 'Early\nPickup',
        color: kParentPrimary,
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => EarlyPickupRequestScreen(student: student))),
      ),
      _QuickAction(
        icon: Icons.book_outlined,
        label: "Today's\nLesson",
        color: kParentAmber,
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => ParentLessonScreen(student: student))),
      ),
      _QuickAction(
        icon: Icons.schedule_rounded,
        label: 'Time\nTable',
        color: const Color(0xFF059669),
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => ParentTimetableScreen(student: student))),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Container(width: 4, height: 20, decoration: BoxDecoration(color: kParentPrimary, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          const Text('Quick Actions', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: kParentDark, letterSpacing: -0.3)),
        ]),
        const SizedBox(height: 12),
        Row(
          children: actions
              .map((a) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _buildQuickActionTile(a),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildQuickActionTile(_QuickAction action) {
    return GestureDetector(
      onTap: action.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: action.color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: action.color.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: action.color.withValues(alpha: 0.15),
              ),
              child: Icon(action.icon, color: action.color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              action.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: action.color,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});
}

// ── Today Attendance Card ─────────────────────────────────────
class _TodayAttendanceCard extends ConsumerWidget {
  final Student student;
  const _TodayAttendanceCard({required this.student});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fs = ref.watch(firestoreServiceProvider);
    final today = DateTime.now();

    return StreamBuilder<AttendanceSession?>(
      stream: student.classId.isEmpty
          ? const Stream.empty()
          : fs.streamAttendanceSession(student.classId, today),
      builder: (ctx, snap) {
        final session = snap.data;
        AttendanceStatus? myStatus;
        if (session != null) {
          final record = session.records.where(
            (r) => r.studentId == student.studentId,
          );
          if (record.isNotEmpty) myStatus = record.first.status;
        }

        final (label, color, icon, bgColor) = _statusTheme(myStatus);

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color, color.withValues(alpha: 0.7)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Today's Attendance",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (session?.markedAt != null)
                          Text(
                            'Marked at ${DateFormat('hh:mm a').format(session!.markedAt!)}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    DateFormat('d\nMMM').format(today),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            // ── Submit leave letter when absent ─────────────
            if (myStatus == AttendanceStatus.ABSENT)
              StreamBuilder<List<LeaveRequest>>(
                stream: fs.streamStudentLeaves(student.studentId),
                builder: (ctx2, leaveSnap) {
                  final today = DateTime.now();
                  final alreadySubmitted = (leaveSnap.data ?? []).any((r) =>
                    r.fromDate.year == today.year &&
                    r.fromDate.month == today.month &&
                    r.fromDate.day == today.day);

                  return Column(
                    children: [
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: alreadySubmitted
                            ? ElevatedButton.icon(
                                onPressed: null,
                                icon: const Icon(Icons.check_circle_outline,
                                    size: 17, color: Colors.white),
                                label: const Text('Leave Letter Submitted',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF059669),
                                  disabledBackgroundColor: const Color(0xFF059669),
                                  disabledForegroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14)),
                                ),
                              )
                            : ElevatedButton.icon(
                                onPressed: () => Navigator.push(
                                  ctx2,
                                  MaterialPageRoute(
                                      builder: (_) => ApplyLeaveScreen(
                                          student: student,
                                          isAbsentLetter: true)),
                                ),
                                icon: const Icon(Icons.edit_document, size: 17,
                                    color: Colors.white),
                                label: const Text('Submit Leave Letter',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFEF4444),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14)),
                                ),
                              ),
                      ),
                    ],
                  );
                },
              ),
          ],
        );
      },
    );
  }

  (String, Color, IconData, Color) _statusTheme(AttendanceStatus? s) {
    switch (s) {
      case AttendanceStatus.PRESENT:
        return ('Present', const Color(0xFF059669), Icons.check_circle_rounded,
            const Color(0xFFD1FAE5));
      case AttendanceStatus.ABSENT:
        return ('Absent', const Color(0xFFEF4444), Icons.cancel_rounded,
            const Color(0xFFFEE2E2));
      case AttendanceStatus.LATE:
        return ('Absent', const Color(0xFFEF4444), Icons.cancel_rounded,
            const Color(0xFFFEE2E2));
      case AttendanceStatus.LEAVE:
        return ('On Leave', const Color(0xFFD97706), Icons.beach_access_rounded,
            const Color(0xFFEDE9FE));
      default:
        return ('Not Marked', const Color(0xFF94A3B8), Icons.help_outline_rounded,
            const Color(0xFFF1F5F9));
    }
  }
}

// ── Today Lesson Preview ──────────────────────────────────────
class _TodayLessonPreview extends ConsumerWidget {
  final Student student;
  const _TodayLessonPreview({required this.student});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fs = ref.watch(firestoreServiceProvider);
    // Show today's date after 9 AM, tomorrow before 9 AM
    final now = DateTime.now();
    final lessonDate = now.hour >= 9
        ? DateTime(now.year, now.month, now.day)
        : DateTime(now.year, now.month, now.day - 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Container(width: 4, height: 20, decoration: BoxDecoration(color: kParentPrimary, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 8),
              const Text("Today's Lesson", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: kParentDark, letterSpacing: -0.3)),
            ]),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ParentLessonScreen(student: student)),
              ),
              child: const Text(
                'See All',
                style: TextStyle(
                  fontSize: 12,
                  color: kParentPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<LessonPlan>>(
          stream: student.classId.isEmpty
              ? const Stream.empty()
              : fs.streamLessonPlansForClass(student.classId, date: lessonDate),
          builder: (ctx, snap) {
            final plans = snap.data ?? [];
            if (plans.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.menu_book_outlined,
                        color: Colors.grey[400], size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'No lesson plans posted yet',
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                    ),
                  ],
                ),
              );
            }
            return Column(
              children: plans.take(3).map((plan) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: kParentAmber.withValues(alpha: 0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: kParentAmber.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.auto_stories_rounded,
                            color: kParentAmber, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plan.subject,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: kParentDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              plan.topicsCovered,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[600]),
                            ),
                            if (plan.homework.isNotEmpty)
                              Text(
                                'HW: ${plan.homework}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: kParentPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

// ── Fee Status Card ───────────────────────────────────────────
class _FeeStatusCard extends ConsumerWidget {
  final Student student;
  const _FeeStatusCard({required this.student});

  static String _currentAcademicYear() => '2026-27';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fs = ref.watch(firestoreServiceProvider);
    final year = _currentAcademicYear();

    return StreamBuilder<Fee?>(
      stream: fs.streamStudentFee(student.studentId, year),
      builder: (ctx, snap) {
        final fee = snap.data;
        if (fee == null || fee.totalPending <= 0) return const SizedBox.shrink();

        return Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF0FDF4), Color(0xFFD1FAE5)],
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(height: 3, color: kParentAmber),
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: kParentAmber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.account_balance_wallet_rounded,
                    color: kParentAmber, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fee Due',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF92400E),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '₹${fee.totalPending.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF92400E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Recent Announcements ──────────────────────────────────────
class _RecentAnnouncements extends ConsumerWidget {
  final Student student;
  const _RecentAnnouncements({required this.student});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fs   = ref.watch(firestoreServiceProvider);
    final user = ref.watch(currentUserProvider).value;
    final myUid = user?.uid ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Container(width: 4, height: 20, decoration: BoxDecoration(color: kParentPrimary, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 8),
              const Text('Announcements', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: kParentDark, letterSpacing: -0.3)),
            ]),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => AnnouncementsScreen(student: student)),
              ),
              child: const Text(
                'See All',
                style: TextStyle(
                  fontSize: 12,
                  color: kParentPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<Announcement>>(
          stream: fs.streamAnnouncementsForParent(
              student.schoolId, student.classId),
          builder: (ctx, snap) {
            if (snap.hasError) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline,
                        color: Colors.red.shade300, size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Could not load: ${snap.error}',
                        style: TextStyle(
                            color: Colors.grey[600], fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }
            final list = (snap.data ?? []).take(3).toList();
            if (list.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.campaign_outlined,
                        color: Colors.grey[400], size: 24),
                    const SizedBox(width: 10),
                    Text(
                      'No announcements yet',
                      style: TextStyle(color: Colors.grey[500], fontSize: 13),
                    ),
                  ],
                ),
              );
            }
            return Column(
              children: list.map((a) {
                final hasAcked = a.hasUserAcked(myUid);
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: hasAcked
                          ? Colors.grey[200]!
                          : kParentPrimary.withValues(alpha: 0.3),
                      width: hasAcked ? 1 : 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: kParentPrimary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.campaign_rounded,
                                color: kParentPrimary, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  a.title,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: kParentDark,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  a.body,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                          if (hasAcked)
                            const Icon(Icons.done_all_rounded,
                                color: Color(0xFF059669), size: 16),
                        ],
                      ),
                      if (!hasAcked) ...[
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: myUid.isEmpty
                                ? null
                                : () => fs.acknowledgeAnnouncement(
                                    a.announcementId, myUid),
                            icon: const Icon(Icons.done_rounded, size: 14),
                            label: const Text('Acknowledge',
                                style: TextStyle(fontSize: 12)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: kParentPrimary,
                              side: const BorderSide(color: kParentPrimary),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 6),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

