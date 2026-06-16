import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/models/early_pickup.dart';

const _kPrimary = Color(0xFF065F46);
const _kRed     = Color(0xFFEF4444);
const _kAmber   = Color(0xFFF59E0B);
const _kBg      = Color(0xFFF0FDF4);
const _kOrange  = Color(0xFFD97706);

class EarlyPickupScreen extends ConsumerStatefulWidget {
  final String schoolId;
  final String teacherUid;
  final bool embeddedMode;
  /// classIds where this teacher is the CLASS teacher — only these can approve/reject
  final List<String> classTeacherClassIds;

  const EarlyPickupScreen({
    super.key,
    required this.schoolId,
    required this.teacherUid,
    this.embeddedMode = false,
    this.classTeacherClassIds = const [],
  });

  @override
  ConsumerState<EarlyPickupScreen> createState() => _EarlyPickupScreenState();
}

class _EarlyPickupScreenState extends ConsumerState<EarlyPickupScreen>
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

    return StreamBuilder<Map<String, String>>(
      stream: fs.streamStudentNameMapForSchool(widget.schoolId),
      builder: (ctx, nameSnap) {
        final nameMap = nameSnap.data ?? {};

        return StreamBuilder<List<EarlyPickup>>(
          stream: fs.streamAllSchoolPickups(widget.schoolId),
          builder: (ctx, snap) {
            final all      = snap.data ?? [];
            final pending  = all.where((p) => p.status == PickupStatus.PENDING).toList();
            final resolved = all.where((p) => p.status != PickupStatus.PENDING).toList();

            if (widget.embeddedMode) {
              return Column(
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
                        _buildList(ctx, pending, fs, nameMap),
                        _buildList(ctx, resolved, fs, nameMap),
                      ],
                    ),
                  ),
                ],
              );
            }

            return Scaffold(
              backgroundColor: _kBg,
              appBar: AppBar(
                backgroundColor: const Color(0xFF065F46),
                foregroundColor: Colors.white,
                title: const Text('Early Pickup Requests',
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
                  _buildList(ctx, pending, fs, nameMap),
                  _buildList(ctx, resolved, fs, nameMap),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildList(BuildContext ctx, List<EarlyPickup> pickups, dynamic fs,
      Map<String, String> nameMap) {
    if (pickups.isEmpty) {
      return Center(
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
              child: Icon(Icons.directions_car_outlined,
                  size: 38, color: _kPrimary.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 16),
            const Text(
              'No early pickup requests',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pickups.length,
      itemBuilder: (_, i) {
        final pickup = pickups[i];
        final canApprove = widget.classTeacherClassIds.contains(pickup.classId);
        final studentName = pickup.studentName.isNotEmpty
            ? pickup.studentName
            : (nameMap[pickup.studentId] ?? '');
        return _PickupCard(
          key: ValueKey(pickup.requestId),
          pickup:      pickup,
          studentName: studentName,
          teacherUid:  widget.teacherUid,
          canApprove:  canApprove,
          onApprove: canApprove ? () async {
            await fs.approvePickup(pickup.requestId, widget.teacherUid);
            if (ctx.mounted) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(
                  content: Text('Early pickup approved'),
                  backgroundColor: _kPrimary,
                ),
              );
            }
          } : null,
          onReject: canApprove ? () async {
            await fs.rejectPickup(pickup.requestId, widget.teacherUid);
            if (ctx.mounted) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(
                  content: Text('Early pickup rejected'),
                  backgroundColor: _kRed,
                ),
              );
            }
          } : null,
        );
      },
    );
  }
}

class _PickupCard extends StatefulWidget {
  final EarlyPickup pickup;
  final String studentName;
  final String teacherUid;
  final bool canApprove;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const _PickupCard({
    super.key,
    required this.pickup,
    required this.studentName,
    required this.teacherUid,
    this.canApprove = false,
    this.onApprove,
    this.onReject,
  });

  @override
  State<_PickupCard> createState() => _PickupCardState();
}

class _PickupCardState extends State<_PickupCard> {
  (String, Color) _statusBadge(PickupStatus s) {
    switch (s) {
      case PickupStatus.APPROVED:   return ('APPROVED',  const Color(0xFF059669));
      case PickupStatus.REJECTED:   return ('REJECTED',  _kRed);
      case PickupStatus.COMPLETED:  return ('COMPLETED', const Color(0xFF3B82F6));
      default:                      return ('PENDING',   _kAmber);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p         = widget.pickup;
    final collector = p.collectorDetails;
    final (statusLabel, statusColor) = _statusBadge(p.status);

    // Pattern B — left border accent
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: _kOrange, width: 4)),
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
          // ── Header ──
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _kOrange.withValues(alpha: 0.06),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: _kOrange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.directions_car_rounded,
                      color: _kOrange, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.studentName.isNotEmpty
                            ? widget.studentName
                            : 'Early Pickup Request',
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 15),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Pickup at: ${DateFormat('hh:mm a').format(p.pickupTime)}',
                        style: TextStyle(
                            color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 11),
                  ),
                ),
              ],
            ),
          ),

          // ── Details ──
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                if (widget.studentName.isNotEmpty) ...[
                  _infoRow(Icons.person_rounded, 'Student', widget.studentName),
                  const SizedBox(height: 8),
                ],
                _infoRow(Icons.info_outline, 'Reason', p.reason),
                const SizedBox(height: 8),

                // Collector details card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _kOrange.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: _kOrange.withValues(alpha: 0.15)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Person Collecting',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: _kOrange),
                      ),
                      const SizedBox(height: 8),
                      _infoRow(Icons.person, 'Name', collector.name),
                      const SizedBox(height: 4),
                      _infoRow(Icons.family_restroom, 'Relation',
                          collector.relation),
                      const SizedBox(height: 4),
                      _infoRow(Icons.phone, 'Phone', collector.phone),
                      if (collector.photoUrl.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            collector.photoUrl,
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // ── Action Buttons (class teacher only) or info message ──
                if (widget.canApprove && p.status == PickupStatus.PENDING)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: widget.onReject,
                          icon: const Icon(Icons.close_rounded, size: 18),
                          label: const Text('Reject',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _kRed,
                            side: const BorderSide(color: _kRed),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: const StadiumBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: widget.onApprove,
                          icon: const Icon(Icons.check_rounded, size: 18),
                          label: const Text('Approve',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                          // Pattern F — pill shape
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _kPrimary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: const StadiumBorder(),
                          ),
                        ),
                      ),
                    ],
                  )
                else if (!widget.canApprove && p.status == PickupStatus.PENDING)
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
                          'Only the class teacher can approve this request',
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[400]),
        const SizedBox(width: 8),
        SizedBox(
          width: 70,
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
            value.isNotEmpty ? value : '—',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
