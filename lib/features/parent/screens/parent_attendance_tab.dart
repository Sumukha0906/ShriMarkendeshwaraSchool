import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/models/student.dart';
import '../../../core/models/attendance.dart';
import '../../../core/models/leave_request.dart';
import '../../../core/models/early_pickup.dart';
// import '../../../core/models/special_request.dart';
import '../parent_dashboard.dart';
import 'apply_leave_screen.dart';
import 'early_pickup_screen.dart';
// import 'special_request_screen.dart';

class ParentAttendanceTab extends ConsumerStatefulWidget {
  final Student student;
  const ParentAttendanceTab({super.key, required this.student});

  @override
  ConsumerState<ParentAttendanceTab> createState() =>
      _ParentAttendanceTabState();
}

class _ParentAttendanceTabState
    extends ConsumerState<ParentAttendanceTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kParentBg,
      appBar: AppBar(
        backgroundColor: kParentDark,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Text('Attendance & Requests',
            style: TextStyle(fontWeight: FontWeight.w700)),
        bottom: TabBar(
          controller: _tabCtrl,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: kParentAmber,
          labelColor: kParentAmber,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          tabs: const [
            Tab(text: 'Attendance'),
            Tab(text: 'Leave'),
            Tab(text: 'Early Pickup'),
            // Tab(text: 'Special Req.'),
          ],
        ),
      ),
      body: Column(
        children: [
          const ChildSwitcherBar(),
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _AttendanceCalendarTab(
                    student: widget.student,
                    month: _month,
                    onMonthChange: (m) => setState(() => _month = m)),
                _LeaveTab(student: widget.student),
                _PickupTab(student: widget.student),
                // _SpecialReqTab(student: widget.student),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFab(context),
    );
  }

  Widget? _buildFab(BuildContext context) {
    final labels = [
      'Apply Leave',
      'Apply Leave',
      'Request Pickup',
      // 'Special Request',
    ];
    final icons = [
      Icons.event_busy_rounded,
      Icons.event_busy_rounded,
      Icons.directions_car_rounded,
      // Icons.help_outline_rounded,
    ];
    return AnimatedBuilder(
      animation: _tabCtrl,
      builder: (ctx, _) {
        final i = _tabCtrl.index;
        return FloatingActionButton.extended(
          onPressed: () {
            switch (i) {
              case 0:
              case 1:
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            ApplyLeaveScreen(student: widget.student)));
                break;
              case 2:
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => EarlyPickupRequestScreen(
                            student: widget.student)));
                break;
              // case 3:
              //   Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //           builder: (_) =>
              //               SpecialRequestScreen(student: widget.student)));
              //   break;
            }
          },
          backgroundColor: kParentPrimary,
          foregroundColor: Colors.white,
          icon: Icon(icons[i]),
          label: Text(labels[i],
              style: const TextStyle(fontWeight: FontWeight.w700)),
        );
      },
    );
  }
}

// ── Attendance Calendar Tab ───────────────────────────────────
class _AttendanceCalendarTab extends ConsumerWidget {
  final Student student;
  final DateTime month;
  final void Function(DateTime) onMonthChange;

  const _AttendanceCalendarTab({
    required this.student,
    required this.month,
    required this.onMonthChange,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fs = ref.watch(firestoreServiceProvider);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    return Column(
      children: [
        // Month navigator
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: () => onMonthChange(
                    DateTime(month.year, month.month - 1)),
              ),
              Text(
                DateFormat('MMMM yyyy').format(month),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: kParentDark,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: () {
                  final next = DateTime(month.year, month.month + 1);
                  if (!next.isAfter(DateTime.now())) onMonthChange(next);
                },
              ),
            ],
          ),
        ),
        // Legend
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 14,
            runSpacing: 6,
            children: [
              _legend(const Color(0xFF059669), 'Present'),
              _legend(const Color(0xFFEF4444), 'Absent'),
              _legend(const Color(0xFFD97706), 'Leave'),
              _legend(kParentAmber, 'Pending Leave'),
            ],
          ),
        ),
        Expanded(
          child: student.classId.isEmpty
              ? const NoClassPlaceholder()
              : StreamBuilder<List<LeaveRequest>>(
            stream: fs.streamStudentLeaves(student.studentId),
            builder: (ctx, leaveSnap) {
              final leaves = leaveSnap.data ?? [];
              // Build leaveMap: day → best LeaveStatus for this month
              // Priority: APPROVED > PENDING > REJECTED
              final leaveMap = <int, LeaveStatus>{};
              final monthStart = DateTime(month.year, month.month, 1);
              final monthEnd   = DateTime(month.year, month.month, daysInMonth);
              for (final leave in leaves) {
                final from = DateTime(
                    leave.fromDate.year, leave.fromDate.month, leave.fromDate.day);
                final to   = DateTime(
                    leave.toDate.year, leave.toDate.month, leave.toDate.day);
                if (to.isBefore(monthStart) || from.isAfter(monthEnd)) continue;
                for (int day = 1; day <= daysInMonth; day++) {
                  final date = DateTime(month.year, month.month, day);
                  if (!date.isBefore(from) && !date.isAfter(to)) {
                    final existing = leaveMap[day];
                    // Keep APPROVED over anything; keep PENDING over REJECTED
                    if (existing == null ||
                        (existing != LeaveStatus.APPROVED &&
                            leave.status == LeaveStatus.APPROVED) ||
                        (existing == LeaveStatus.REJECTED &&
                            leave.status == LeaveStatus.PENDING)) {
                      leaveMap[day] = leave.status;
                    }
                  }
                }
              }

              return StreamBuilder<List<AttendanceSession>>(
                stream: fs.streamStudentMonthAttendance(student.classId, month),
                builder: (ctx2, snap) {
                  final sessions = snap.data ?? [];
                  // Build statusMap: day → AttendanceStatus
                  final statusMap = <int, AttendanceStatus>{};
                  for (final s in sessions) {
                    final record = s.records.where(
                        (r) => r.studentId == student.studentId);
                    if (record.isNotEmpty) {
                      statusMap[s.date.day] = record.first.status;
                    }
                  }

                  final present = statusMap.values
                      .where((s) => s == AttendanceStatus.PRESENT).length;
                  final absent = statusMap.values
                      .where((s) => s == AttendanceStatus.ABSENT).length;
                  // Leave count: attendance LEAVE sessions + approved leave days
                  // without an attendance record (e.g. future approved leaves)
                  int onLeave = 0;
                  for (int day = 1; day <= daysInMonth; day++) {
                    if (statusMap[day] == AttendanceStatus.LEAVE) {
                      onLeave++;
                    } else if (statusMap[day] == null &&
                        leaveMap[day] == LeaveStatus.APPROVED) {
                      onLeave++;
                    }
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _statBox('$present', 'Present',
                                const Color(0xFF059669)),
                            _statBox('$absent', 'Absent',
                                const Color(0xFFEF4444)),
                            _statBox('$onLeave', 'Leave',
                                const Color(0xFFD97706)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _CalendarGrid(
                          month: month,
                          statusMap: statusMap,
                          leaveMap: leaveMap,
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _legend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(fontSize: 10, color: Colors.grey[600])),
      ],
    );
  }

  Widget _statBox(String value, String label, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  final DateTime month;
  final Map<int, AttendanceStatus> statusMap;
  final Map<int, LeaveStatus> leaveMap;
  const _CalendarGrid({
    required this.month,
    required this.statusMap,
    this.leaveMap = const {},
  });

  @override
  Widget build(BuildContext context) {
    final daysInMonth =
        DateTime(month.year, month.month + 1, 0).day;
    final firstWeekday =
        DateTime(month.year, month.month, 1).weekday; // 1=Mon

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          // Day headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                .map((d) => SizedBox(
                      width: 36,
                      child: Center(
                        child: Text(d,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: kParentDark,
                            )),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          // Day cells
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: daysInMonth + firstWeekday - 1,
            itemBuilder: (ctx, i) {
              if (i < firstWeekday - 1) return const SizedBox();
              final day = i - firstWeekday + 2;
              final status = statusMap[day];
              final leaveStatus = leaveMap[day];
              // Attendance record takes priority; fall back to leave request color
              final Color color;
              final bool hasIndicator;
              if (status != null) {
                color = _statusColor(status);
                hasIndicator = true;
              } else if (leaveStatus != null) {
                color = _leaveStatusColor(leaveStatus);
                hasIndicator = true;
              } else {
                color = Colors.grey;
                hasIndicator = false;
              }

              return Container(
                decoration: BoxDecoration(
                  color: color.withValues(alpha: hasIndicator ? 0.15 : 0),
                  shape: BoxShape.circle,
                  border: hasIndicator
                      ? Border.all(color: color.withValues(alpha: 0.3))
                      : null,
                ),
                child: Center(
                  child: Text(
                    '$day',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: hasIndicator
                          ? FontWeight.w700
                          : FontWeight.w400,
                      color: hasIndicator ? color : Colors.grey[500],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Color _statusColor(AttendanceStatus? s) {
    switch (s) {
      case AttendanceStatus.PRESENT: return const Color(0xFF059669);
      case AttendanceStatus.ABSENT:  return const Color(0xFFEF4444);
      case AttendanceStatus.LATE:    return const Color(0xFFEF4444);
      case AttendanceStatus.LEAVE:   return const Color(0xFFD97706);
      default:                       return Colors.grey;
    }
  }

  Color _leaveStatusColor(LeaveStatus s) {
    switch (s) {
      case LeaveStatus.APPROVED: return const Color(0xFFD97706);
      case LeaveStatus.REJECTED: return const Color(0xFFEF4444);
      default:                   return kParentAmber; // PENDING
    }
  }
}

// ── Leave Requests Tab ────────────────────────────────────────
class _LeaveTab extends ConsumerWidget {
  final Student student;
  const _LeaveTab({required this.student});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fs = ref.watch(firestoreServiceProvider);

    return StreamBuilder<List<LeaveRequest>>(
      stream: fs.streamStudentLeaves(student.studentId),
      builder: (ctx, snap) {
        final leaves = snap.data ?? [];
        if (leaves.isEmpty) {
          return _emptyState(Icons.event_busy_rounded,
              'No leave requests yet', 'Tap + to apply for leave');
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: leaves.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (ctx, i) => _LeaveCard(leave: leaves[i]),
        );
      },
    );
  }
}

class _LeaveCard extends StatelessWidget {
  final LeaveRequest leave;
  const _LeaveCard({required this.leave});

  @override
  Widget build(BuildContext context) {
    final (statusLabel, statusColor) = _statusTheme(leave.status);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: statusColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${DateFormat('MMM d').format(leave.fromDate)} – '
                '${DateFormat('MMM d').format(leave.toDate)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: kParentDark,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(leave.reason,
              style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          if (leave.reviewNote.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.comment_outlined,
                    size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    leave.reviewNote,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  (String, Color) _statusTheme(LeaveStatus s) {
    switch (s) {
      case LeaveStatus.APPROVED:
        return ('Approved', const Color(0xFF059669));
      case LeaveStatus.REJECTED:
        return ('Rejected', const Color(0xFFEF4444));
      default:
        return ('Pending', kParentAmber);
    }
  }
}

// ── Early Pickup Tab ──────────────────────────────────────────
class _PickupTab extends ConsumerWidget {
  final Student student;
  const _PickupTab({required this.student});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fs = ref.watch(firestoreServiceProvider);

    return StreamBuilder<List<EarlyPickup>>(
      stream: fs.streamStudentPickups(student.studentId),
      builder: (ctx, snap) {
        final pickups = snap.data ?? [];
        if (pickups.isEmpty) {
          return _emptyState(Icons.directions_car_rounded,
              'No early pickup requests', 'Tap + to request early pickup');
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: pickups.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (ctx, i) => _PickupCard(pickup: pickups[i]),
        );
      },
    );
  }
}

class _PickupCard extends StatelessWidget {
  final EarlyPickup pickup;
  const _PickupCard({required this.pickup});

  @override
  Widget build(BuildContext context) {
    final (statusLabel, statusColor) = _statusTheme(pickup.status);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.access_time_rounded,
                      color: kParentPrimary, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('h:mm a').format(pickup.pickupTime),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: kParentDark,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(pickup.reason,
              style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                '${pickup.collectorDetails.name} (${pickup.collectorDetails.relation})',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  (String, Color) _statusTheme(PickupStatus s) {
    switch (s) {
      case PickupStatus.APPROVED:
        return ('Approved', const Color(0xFF059669));
      case PickupStatus.REJECTED:
        return ('Rejected', const Color(0xFFEF4444));
      case PickupStatus.COMPLETED:
        return ('Completed', const Color(0xFF3B82F6));
      default:
        return ('Pending', kParentAmber);
    }
  }
}

// ── Special Requests Tab (disabled) ──────────────────────────
// class _SpecialReqTab extends ConsumerWidget {
//   final Student student;
//   const _SpecialReqTab({required this.student});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final fs = ref.watch(firestoreServiceProvider);
//
//     return StreamBuilder<List<SpecialRequest>>(
//       stream: fs.streamStudentSpecialRequests(student.studentId),
//       builder: (ctx, snap) {
//         final reqs = snap.data ?? [];
//         if (reqs.isEmpty) {
//           return _emptyState(Icons.help_outline_rounded,
//               'No special requests yet', 'Tap + to send a request to a teacher');
//         }
//         return ListView.separated(
//           padding: const EdgeInsets.all(16),
//           itemCount: reqs.length,
//           separatorBuilder: (_, __) => const SizedBox(height: 10),
//           itemBuilder: (ctx, i) => _SpecialReqCard(request: reqs[i]),
//         );
//       },
//     );
//   }
// }
//
// class _SpecialReqCard extends StatelessWidget {
//   final SpecialRequest request;
//   const _SpecialReqCard({required this.request});
//
//   @override
//   Widget build(BuildContext context) {
//     final statusColor = _statusColor(request.status.name);
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: statusColor.withValues(alpha: 0.3)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Expanded(
//                 child: Text(
//                   request.subject,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.w700,
//                     fontSize: 14,
//                     color: kParentDark,
//                   ),
//                 ),
//               ),
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                     horizontal: 8, vertical: 3),
//                 decoration: BoxDecoration(
//                   color: statusColor.withValues(alpha: 0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Text(
//                   request.status.name,
//                   style: TextStyle(
//                       fontSize: 10,
//                       fontWeight: FontWeight.w700,
//                       color: statusColor),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 4),
//           Text(
//             'To: ${request.targetTeacherName}',
//             style: TextStyle(color: Colors.grey[500], fontSize: 12),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             request.description,
//             maxLines: 2,
//             overflow: TextOverflow.ellipsis,
//             style: TextStyle(color: Colors.grey[700], fontSize: 13),
//           ),
//           if (request.responseNote.isNotEmpty) ...[
//             const SizedBox(height: 8),
//             Container(
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: statusColor.withValues(alpha: 0.05),
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(
//                     color: statusColor.withValues(alpha: 0.2)),
//               ),
//               child: Row(
//                 children: [
//                   Icon(Icons.reply_rounded,
//                       size: 14, color: statusColor),
//                   const SizedBox(width: 6),
//                   Expanded(
//                     child: Text(
//                       request.responseNote,
//                       style: TextStyle(
//                           fontSize: 12, color: Colors.grey[700]),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
//
//   Color _statusColor(String s) {
//     switch (s) {
//       case 'APPROVED':     return const Color(0xFF059669);
//       case 'REJECTED':     return const Color(0xFFEF4444);
//       case 'ACKNOWLEDGED': return const Color(0xFF3B82F6);
//       default:             return kParentAmber;
//     }
//   }
// }

Widget _emptyState(IconData icon, String title, String sub) {
  const kPrimary = Color(0xFF065F46);
  const kBg      = Color(0xFFF0FDF4);
  const kNavy    = Color(0xFF0F172A);
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80, height: 80,
          decoration: const BoxDecoration(shape: BoxShape.circle, color: kBg),
          child: Icon(icon, size: 36, color: kPrimary),
        ),
        const SizedBox(height: 16),
        Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kNavy)),
        const SizedBox(height: 6),
        Text(sub,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
      ],
    ),
  );
}
