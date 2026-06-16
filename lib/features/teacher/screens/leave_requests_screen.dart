import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/models/leave_request.dart';

const _kPrimary = Color(0xFF065F46);
const _kRed     = Color(0xFFEF4444);
const _kAmber   = Color(0xFFF59E0B);
const _kBg      = Color(0xFFF0FDF4);
const _kBlue    = Color(0xFF3B82F6);

class LeaveRequestsScreen extends ConsumerStatefulWidget {
  final String schoolId;
  final String teacherUid;
  final bool embeddedMode;
  /// classIds where this teacher is the CLASS teacher — only these can approve/reject
  final List<String> classTeacherClassIds;

  const LeaveRequestsScreen({
    super.key,
    required this.schoolId,
    required this.teacherUid,
    this.embeddedMode = false,
    this.classTeacherClassIds = const [],
  });

  @override
  ConsumerState<LeaveRequestsScreen> createState() =>
      _LeaveRequestsScreenState();
}

class _LeaveRequestsScreenState extends ConsumerState<LeaveRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fs = ref.watch(firestoreServiceProvider);

    // Stream student names for the whole school so we can resolve IDs for
    // older records that were saved before studentName was stored on the model.
    return StreamBuilder<Map<String, String>>(
      stream: fs.streamStudentNameMapForSchool(widget.schoolId),
      builder: (ctx, nameSnap) {
        final nameMap = nameSnap.data ?? {};

        return StreamBuilder<List<LeaveRequest>>(
          stream: fs.streamLeavesForSchool(widget.schoolId),
          builder: (ctx, snap) {
            final all = snap.data ?? [];
            final pending  = all.where((r) => r.status == LeaveStatus.PENDING).toList();
            final resolved = all.where((r) => r.status != LeaveStatus.PENDING).toList();

            if (widget.embeddedMode) {
              return DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    TabBar(
                      controller: _tabCtrl,
                      indicatorColor: _kPrimary,
                      labelColor: _kPrimary,
                      unselectedLabelColor: Colors.grey,
                      tabs: [
                        Tab(text: 'Pending (${pending.length})'),
                        Tab(text: 'History'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabCtrl,
                        children: [
                          _buildList(pending, fs, nameMap),
                          _buildList(resolved, fs, nameMap),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            return Scaffold(
              backgroundColor: _kBg,
              appBar: AppBar(
                backgroundColor: const Color(0xFF065F46),
                foregroundColor: Colors.white,
                title: const Text('Leave Requests',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                bottom: TabBar(
                  controller: _tabCtrl,
                  indicatorColor: _kPrimary,
                  labelColor: _kAmber,
                  unselectedLabelColor: Colors.white54,
                  tabs: [
                    Tab(text: 'Pending (${pending.length})'),
                    Tab(text: 'History'),
                  ],
                ),
              ),
              body: TabBarView(
                controller: _tabCtrl,
                children: [
                  _buildList(pending, fs, nameMap),
                  _buildList(resolved, fs, nameMap),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildList(List<LeaveRequest> requests, dynamic fs,
      Map<String, String> nameMap) {
    // Pattern I — improved empty state
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.event_available_rounded,
                  size: 40, color: _kPrimary),
            ),
            const SizedBox(height: 16),
            const Text(
              'No leave requests',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'All clear for this period',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (_, i) {
        final req = requests[i];
        final canApprove = widget.classTeacherClassIds.contains(req.classId);
        // Prefer stored name; fall back to live lookup for older records
        final studentName = req.studentName.isNotEmpty
            ? req.studentName
            : (nameMap[req.studentId] ?? '');
        return _LeaveCard(
          // Key ensures state (note field) is not reused across different requests
          key: ValueKey(req.requestId),
          request:      req,
          studentName:  studentName,
          teacherUid:   widget.teacherUid,
          canApprove:   canApprove,
          onDecision: (status, note) async {
            await fs.reviewLeave(
              req.requestId,
              status,
              widget.teacherUid,
              note: note,
            );
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(status == LeaveStatus.APPROVED
                      ? 'Leave approved'
                      : 'Leave rejected'),
                  backgroundColor:
                      status == LeaveStatus.APPROVED ? _kPrimary : _kRed,
                ),
              );
            }
          },
        );
      },
    );
  }
}

class _LeaveCard extends StatefulWidget {
  final LeaveRequest request;
  final String studentName;
  final String teacherUid;
  final bool canApprove;
  final void Function(LeaveStatus, String) onDecision;

  const _LeaveCard({
    super.key,
    required this.request,
    required this.studentName,
    required this.teacherUid,
    required this.onDecision,
    this.canApprove = true,
  });

  @override
  State<_LeaveCard> createState() => _LeaveCardState();
}

class _LeaveCardState extends State<_LeaveCard> {
  bool _expanded = false;
  final _noteCtrl = TextEditingController();
  bool _acting = false;

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final req  = widget.request;
    final days = req.durationDays;
    final isAbsentLetter = req.isAbsentLetter;

    // Resolved name comes from parent (_buildList resolves via live lookup map)
    final displayName = widget.studentName.isNotEmpty
        ? widget.studentName
        : 'Student ${req.studentId.substring(0, 6)}';

    // Pattern B — left border accent on leave request cards
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(
            color: isAbsentLetter ? _kBlue : _kAmber,
            width: 4,
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
      child: Column(
        children: [
          // Absent-letter banner
          if (isAbsentLetter)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: _kBlue.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_rounded, size: 15, color: _kBlue),
                  const SizedBox(width: 6),
                  const Text(
                    'Leave Letter — student was marked Absent',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _kBlue,
                    ),
                  ),
                ],
              ),
            ),

          // Header
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Container(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: (isAbsentLetter ? _kBlue : _kAmber)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isAbsentLetter
                          ? Icons.assignment_late_rounded
                          : Icons.event_busy_rounded,
                      color: isAbsentLetter ? _kBlue : _kAmber,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${DateFormat('dd MMM').format(req.fromDate)} → '
                          '${DateFormat('dd MMM yyyy').format(req.toDate)}'
                          '  ($days day${days > 1 ? 's' : ''})',
                          style: TextStyle(
                              color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  _statusBadge(req.status),
                  const SizedBox(width: 6),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),
          ),

          // Expanded details
          if (_expanded)
            Container(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 8),
                  _detailRow('Reason', req.reason),
                  if (req.attachmentUrl.isNotEmpty)
                    _detailRow('Attachment', 'View attachment'),
                  const SizedBox(height: 12),

                  if (req.status == LeaveStatus.PENDING && widget.canApprove) ...[
                    // Absent letters: only show Approve (already absent — can't reject)
                    if (isAbsentLetter) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: _kBlue.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: _kBlue.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline,
                                size: 14, color: _kBlue),
                            const SizedBox(width: 6),
                            const Expanded(
                              child: Text(
                                'Student was already absent — only Acknowledge is available',
                                style: TextStyle(
                                    fontSize: 11, color: _kBlue),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _noteCtrl,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'Add review note (optional)',
                          hintStyle: TextStyle(
                              color: Colors.grey[400], fontSize: 13),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _acting
                              ? null
                              : () {
                                  setState(() => _acting = true);
                                  widget.onDecision(
                                    LeaveStatus.APPROVED,
                                    _noteCtrl.text,
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _kBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Acknowledge',
                              style:
                                  TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ] else ...[
                      // Normal leave: note + Reject / Approve
                      TextField(
                        controller: _noteCtrl,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'Add review note (optional)',
                          hintStyle: TextStyle(
                              color: Colors.grey[400], fontSize: 13),
                          filled: true,
                          fillColor: const Color(0xFFF0FDF4),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: _kPrimary.withValues(alpha: 0.3)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: _kPrimary.withValues(alpha: 0.3)),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _acting
                                  ? null
                                  : () {
                                      setState(() => _acting = true);
                                      widget.onDecision(
                                        LeaveStatus.REJECTED,
                                        _noteCtrl.text,
                                      );
                                    },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: _kRed,
                                side: const BorderSide(color: _kRed),
                                shape: const StadiumBorder(),
                              ),
                              child: const Text('Reject',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _acting
                                  ? null
                                  : () {
                                      setState(() => _acting = true);
                                      widget.onDecision(
                                        LeaveStatus.APPROVED,
                                        _noteCtrl.text,
                                      );
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _kPrimary,
                                foregroundColor: Colors.white,
                                shape: const StadiumBorder(),
                              ),
                              child: const Text('Approve',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ] else if (req.status == LeaveStatus.PENDING && !widget.canApprove)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline,
                              size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 6),
                          Text(
                            'Only the class teacher can approve this leave',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ),

                  // Show review note for resolved leaves
                  if (req.status != LeaveStatus.PENDING &&
                      req.reviewNote.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _detailRow('Note', req.reviewNote),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _statusBadge(LeaveStatus status) {
    final (label, color) = switch (status) {
      LeaveStatus.APPROVED => ('APPROVED', _kPrimary),
      LeaveStatus.REJECTED => ('REJECTED', _kRed),
      _ => ('PENDING', _kAmber),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontSize: 10, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
