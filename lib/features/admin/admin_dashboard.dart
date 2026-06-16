import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../core/constants/firestore_constants.dart';
import '../../core/providers/core_providers.dart';
import '../../core/services/notification_service.dart';
import '../../core/models/user_model.dart';
import 'screens/manage_classes_screen.dart';
import 'screens/admin_students_screen.dart';
import 'screens/fee_management_screen.dart';
import '../../features/teacher/screens/edit_profile_screen.dart';
import '../../features/teacher/screens/class_announcement_screen.dart';

// ─── Admin theme (Deep Indigo) ────────────────────────────────────────────────
const _kPrimary = Color(0xFF065F46); // indigo-600
const _kDark    = Color(0xFF022C22); // indigo-900
const _kAccent  = Color(0xFFD97706); // violet-600
const _kBg      = Color(0xFFF0FDF4); // indigo-50
const _kNavy    = Color(0xFF0A0F1E);
const _kGreen   = Color(0xFF059669);
const _kRed     = Color(0xFFEF4444);
const _kAmber   = Color(0xFFF59E0B);
const _kBlue    = Color(0xFF3B82F6);

const _kExpenseCategories = [
  'Salaries', 'Utilities', 'Maintenance', 'Supplies',
  'Events', 'Infrastructure', 'Transport', 'Other',
];


// ─────────────────────────────────────────────────────────────────────────────
class AdminDashboard extends ConsumerStatefulWidget {
  /// When true the user is ADMINISTRATOR: all admin views enabled but fee
  /// writing (recording payments / setting fees) is hidden.
  final bool readOnlyFees;
  const AdminDashboard({super.key, this.readOnlyFees = false});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;

  // Stats
  int _totalStudents   = 0;
  int _presentToday    = 0;
  int _absentToday     = 0;
  double _feePending   = 0;
  double _feeCollected = 0;
  bool _statsLoading   = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadStats());
  }

  Future<void> _loadStats() async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;

    final today    = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd   = todayStart.add(const Duration(days: 1));
    try {
      // Total students
      final studentCountResult = await FirebaseFirestore.instance
          .collection(FSC.students)
          .where('schoolId', isEqualTo: user.schoolId)
          .where('isActive', isEqualTo: true)
          .count()
          .get();
      final totalStudents = studentCountResult.count ?? 0;

      // Today's attendance — read from attendance/{classId}/sessions (same path teachers write to)
      int present = 0;
      int absent  = 0;
      try {
        final classSnap = await FirebaseFirestore.instance
            .collection(FSC.classes)
            .where('schoolId', isEqualTo: user.schoolId)
            .get();
        for (final classDoc in classSnap.docs) {
          final sessSnap = await FirebaseFirestore.instance
              .collection(FSC.attendance)
              .doc(classDoc.id)
              .collection(FSC.sessions)
              .where('date',
                  isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart),
                  isLessThan: Timestamp.fromDate(todayEnd))
              .limit(1)
              .get();
          if (sessSnap.docs.isEmpty) continue;
          final records = sessSnap.docs.first.data()['records'] as List<dynamic>? ?? [];
          for (final r in records) {
            final status = (r as Map<String, dynamic>)['status'] as String?;
            if (status == 'PRESENT') { present++; }
            else if (status == 'ABSENT' || status == 'LEAVE') { absent++; }
          }
        }
      } catch (_) {}

      // Fee pending + collected — all years (matches website behaviour)
      double pending   = 0;
      double collected = 0;
      try {
        final feeSnap = await FirebaseFirestore.instance
            .collection(FSC.fees)
            .where('schoolId', isEqualTo: user.schoolId)
            .get();
        for (final doc in feeSnap.docs) {
          pending   += ((doc.data()['totalPending'] as num?) ?? 0).toDouble();
          collected += ((doc.data()['totalPaid']    as num?) ?? 0).toDouble();
        }
      } catch (_) {}

      if (mounted) {
        setState(() {
          _totalStudents = totalStudents;
          _presentToday  = present;
          _absentToday   = absent;
          _feePending    = pending;
          _feeCollected  = collected;
          _statsLoading  = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _statsLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.value;

    ref.listen(currentUserProvider, (_, next) {
      if (next.value != null && _statsLoading) _loadStats();
    });

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _kBg,
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: KeyedSubtree(
            key: ValueKey(_selectedIndex),
            child: _buildBody(user),
          ),
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildBody(UserModel? user) {
    switch (_selectedIndex) {
      case 0:
        return _HomeTab(
          user: user,
          totalStudents: _totalStudents,
          presentToday: _presentToday,
          absentToday: _absentToday,
          feePending: _feePending,
          feeCollected: _feeCollected,
          statsLoading: _statsLoading,
          onRefresh: _loadStats,
          onTabChange: (i) => setState(() => _selectedIndex = i),
          readOnlyFees: widget.readOnlyFees,
        );
      case 1:
        return const AdminStudentsScreen();
      case 2:
        return _FinanceTab(user: user, readOnlyFees: widget.readOnlyFees);
      case 3:
        return _FrontDeskTab(user: user);
      case 4:
        return const ManageClassesScreen();
      case 5:
        return _ProfileTab(user: user);
      default:
        return _HomeTab(
          user: user,
          totalStudents: _totalStudents,
          presentToday: _presentToday,
          absentToday: _absentToday,
          feePending: _feePending,
          feeCollected: _feeCollected,
          statsLoading: _statsLoading,
          onRefresh: _loadStats,
          onTabChange: (i) => setState(() => _selectedIndex = i),
          readOnlyFees: widget.readOnlyFees,
        );
    }
  }

  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.people_rounded, 'label': 'Students'},
      {'icon': Icons.account_balance_wallet_rounded, 'label': 'Finance'},
      {'icon': Icons.support_agent_rounded, 'label': 'Front Desk'},
      {'icon': Icons.class_rounded, 'label': 'Classes'},
      {'icon': Icons.person_rounded, 'label': 'Profile'},
    ];

    // Pattern D — top border accent on selected tab instead of bubble
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((entry) {
              final index    = entry.key;
              final item     = entry.value;
              final selected = _selectedIndex == index;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedIndex = index);
                    if (index == 0) _loadStats();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: selected
                          ? const Border(top: BorderSide(color: _kPrimary, width: 3))
                          : const Border(top: BorderSide(color: Colors.transparent, width: 3)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item['icon'] as IconData,
                          color: selected ? _kPrimary : Colors.grey.shade400,
                          size: 22,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item['label'] as String,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                            color: selected ? _kPrimary : Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// TAB 1 — HOME
// ═══════════════════════════════════════════════════════════════════════════
class _HomeTab extends ConsumerStatefulWidget {
  final UserModel? user;
  final int totalStudents;
  final int presentToday;
  final int absentToday;
  final double feePending;
  final double feeCollected;
  final bool statsLoading;
  final Future<void> Function() onRefresh;
  final void Function(int) onTabChange;
  final bool readOnlyFees;

  const _HomeTab({
    required this.user,
    required this.totalStudents,
    required this.presentToday,
    required this.absentToday,
    required this.feePending,
    required this.feeCollected,
    required this.statsLoading,
    required this.onRefresh,
    required this.onTabChange,
    this.readOnlyFees = false,
  });

  @override
  ConsumerState<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<_HomeTab> {
  /// Fee route depends on role: ADMINISTRATOR gets read-only view.
  String get _feePath =>
      widget.readOnlyFees ? '/administrator/fees' : '/admin/fees';

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: widget.onRefresh,
        color: _kPrimary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(user)),
            SliverToBoxAdapter(child: _buildStatsGrid()),
            SliverToBoxAdapter(child: _buildQuickActions()),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(UserModel? user) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';
    final now = DateTime.now();
    final dateStr = _formatDate(now);

    // Pattern J — decorative circular overlay on header
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF022C22), _kDark],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            right: 30,
            top: 40,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _kAccent.withValues(alpha: 0.08),
              ),
            ),
          ),
          Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                      colors: [_kPrimary, _kAccent]),
                ),
                child: Center(
                  child: Text(
                    user?.name.isNotEmpty == true
                        ? user!.name[0].toUpperCase()
                        : 'A',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                    Text(
                      user?.name ?? 'Admin',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              // Role badge
              Flexible(
                fit: FlexFit.loose,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _kPrimary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    user?.role == UserRole.ADMINISTRATOR
                        ? 'ADMINISTRATOR'
                        : 'ADMIN',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Date chip
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF6EE7B7),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
          ),   // Column
        ],     // Stack children
      ),       // Stack
    );         // Container
  }

  Widget _buildStatsGrid() {
    final loading = widget.statsLoading;
    final fmt = NumberFormat('##,##,##0', 'en_IN');

    final stats = [
      _StatData(
        label: 'Present Today',
        value: loading ? '—' : '${widget.presentToday}',
        icon: Icons.check_circle_rounded,
        color: _kGreen,
        bgColor: const Color(0xFFECFDF5),
        onTap: widget.presentToday > 0 ? () => _showPresentList() : null,
      ),
      _StatData(
        label: 'Absent Today',
        value: loading ? '—' : '${widget.absentToday}',
        icon: Icons.cancel_rounded,
        color: _kRed,
        bgColor: const Color(0xFFFEF2F2),
        onTap: widget.absentToday > 0
            ? () => _showAbsentList()
            : null,
      ),
      _StatData(
        label: 'Fee Pending',
        value: loading ? '—' : '₹ ${fmt.format(widget.feePending)}',
        icon: Icons.pending_actions_rounded,
        color: _kAmber,
        bgColor: const Color(0xFFFFFBEB),
        onTap: () => context.push(_feePath),
      ),
      _StatData(
        label: 'Fee Collected',
        value: loading ? '—' : '₹ ${fmt.format(widget.feeCollected)}',
        icon: Icons.payments_rounded,
        color: _kGreen,
        bgColor: const Color(0xFFECFDF5),
        onTap: widget.feeCollected > 0 ? () => _showFeeCollectedList() : null,
      ),
      _StatData(
        label: 'Total Students',
        value: loading ? '—' : '${widget.totalStudents}',
        icon: Icons.people_rounded,
        color: _kPrimary,
        bgColor: const Color(0xFFF0FDF4),
        onTap: () => widget.onTabChange(1),
      ),
    ];

    // Pattern C — horizontal ListView instead of GridView
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
      child: SizedBox(
        height: 140,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: stats.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, i) => SizedBox(
            width: 130,
            child: _StatCard(data: stats[i]),
          ),
        ),
      ),
    );
  }

  void _showPresentList() {
    final user = widget.user;
    if (user == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _PresentListSheet(schoolId: user.schoolId),
    );
  }

  void _showAbsentList() {
    final user = widget.user;
    if (user == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _AbsentListSheet(schoolId: user.schoolId),
    );
  }

  void _showFeeCollectedList() {
    final user = widget.user;
    if (user == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _FeeCollectedSheet(schoolId: user.schoolId),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pattern G — section header with accent bar
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: _kPrimary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: _kNavy,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _QuickAction(
                  label: 'Classes',
                  icon: Icons.class_rounded,
                  color: _kBlue,
                  onTap: () {
                    // Navigate to classes using Navigator push
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ManageClassesScreen()),
                    );
                  },
                ),
                const SizedBox(width: 10),
                _QuickAction(
                  label: 'Fee Mgmt',
                  icon: Icons.payments_rounded,
                  color: _kAmber,
                  onTap: () => context.push(_feePath),
                ),
                const SizedBox(width: 10),
                _QuickAction(
                  label: 'Add Expense',
                  icon: Icons.add_card_rounded,
                  color: _kGreen,
                  onTap: () {
                    final u = widget.user;
                    if (u == null) return;
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20))),
                      builder: (_) => _AddExpenseSheet(user: u),
                    );
                  },
                ),
                const SizedBox(width: 10),
                _QuickAction(
                  label: 'All Students',
                  icon: Icons.people_rounded,
                  color: _kAccent,
                  onTap: () => widget.onTabChange(1),
                ),
                const SizedBox(width: 10),
                _QuickAction(
                  label: 'Announce',
                  icon: Icons.campaign_rounded,
                  color: _kRed,
                  onTap: () {
                    final u = widget.user;
                    if (u == null) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ClassAnnouncementScreen(
                            schoolId: u.schoolId,
                            teacherUid: u.uid,
                            schoolWideOnly: true,
                            showAllAnnouncements: !widget.readOnlyFees,
                          )),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    const days = [
      'Monday', 'Tuesday', 'Wednesday',
      'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

// ─── Attendance list bottom sheet (Present / Absent) ─────────────────────────
class _AbsentListSheet extends StatelessWidget {
  final String schoolId;
  const _AbsentListSheet({required this.schoolId});

  @override
  Widget build(BuildContext context) => _AttendanceListSheet(
        schoolId: schoolId,
        showPresent: false,
      );
}

class _PresentListSheet extends StatelessWidget {
  final String schoolId;
  const _PresentListSheet({required this.schoolId});

  @override
  Widget build(BuildContext context) => _AttendanceListSheet(
        schoolId: schoolId,
        showPresent: true,
      );
}

// ─── Fee Collected bottom sheet ───────────────────────────────────────────────
class _FeeCollectedSheet extends StatefulWidget {
  final String schoolId;
  const _FeeCollectedSheet({required this.schoolId});

  @override
  State<_FeeCollectedSheet> createState() => _FeeCollectedSheetState();
}

class _FeeCollectedSheetState extends State<_FeeCollectedSheet> {
  List<Map<String, dynamic>> _rows = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection(FSC.fees)
          .where('schoolId', isEqualTo: widget.schoolId)
          .get();
      final rows = <Map<String, dynamic>>[];
      for (final doc in snap.docs) {
        final d = doc.data();
        final paid = ((d['totalPaid'] as num?) ?? 0).toDouble();
        if (paid <= 0) continue; // only show students who've paid something
        rows.add({
          'name':         d['studentName'] ?? 'Student',
          'className':    d['className'] ?? '',
          'academicYear': d['academicYear'] ?? '',
          'paid':         paid,
          'status':       d['status'] ?? '',
        });
      }
      rows.sort((a, b) =>
          (b['paid'] as double).compareTo(a['paid'] as double));
      if (mounted) setState(() { _rows = rows; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('##,##,##0', 'en_IN');
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (_, ctrl) => Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Fee Collected',
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          if (_loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_rows.isEmpty)
            const Expanded(
                child: Center(child: Text('No collected fees found')))
          else
            Expanded(
              child: ListView.separated(
                controller: ctrl,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _rows.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final r = _rows[i];
                  final isPaid = r['status'] == 'paid';
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 0, vertical: 4),
                    leading: CircleAvatar(
                      backgroundColor:
                          isPaid ? const Color(0xFFECFDF5) : const Color(0xFFFFFBEB),
                      child: Icon(
                        isPaid
                            ? Icons.check_circle_rounded
                            : Icons.incomplete_circle_rounded,
                        color: isPaid ? _kGreen : _kAmber,
                        size: 20,
                      ),
                    ),
                    title: Text(r['name'] as String,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text(
                      [
                        if ((r['className'] as String).isNotEmpty)
                          r['className'] as String,
                        r['academicYear'] as String,
                        isPaid ? 'Paid' : 'Partial',
                      ].join('  •  '),
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade500),
                    ),
                    trailing: Text(
                      '₹ ${fmt.format(r['paid'])}',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: _kGreen),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _AttendanceListSheet extends StatefulWidget {
  final String schoolId;
  final bool   showPresent;
  const _AttendanceListSheet(
      {required this.schoolId, required this.showPresent});

  @override
  State<_AttendanceListSheet> createState() => _AttendanceListSheetState();
}

class _AttendanceListSheetState extends State<_AttendanceListSheet> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  // {studentId: {name, className}}
  final _rows = <Map<String, String>>[];
  bool _loading = true;
  String? _classFilter; // classId
  final _classNames = <String, String>{}; // classId → displayName

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final db    = FirebaseFirestore.instance;
      final today = DateTime.now();
      final start = DateTime(today.year, today.month, today.day);
      final end   = start.add(const Duration(days: 1));

      // Load classes
      final classSnap = await db
          .collection(FSC.classes)
          .where('schoolId', isEqualTo: widget.schoolId)
          .get();
      final classMap = <String, String>{};
      for (final d in classSnap.docs) {
        classMap[d.id] = d.data()['name'] as String? ?? d.id;
      }
      _classNames
        ..clear()
        ..addAll(classMap);

      // Collect studentIds per class
      final rows = <Map<String, String>>[];
      final allStudentIds = <String>[];

      for (final classDoc in classSnap.docs) {
        final sessSnap = await db
            .collection(FSC.attendance)
            .doc(classDoc.id)
            .collection(FSC.sessions)
            .where('date',
                isGreaterThanOrEqualTo: Timestamp.fromDate(start),
                isLessThan: Timestamp.fromDate(end))
            .limit(1)
            .get();
        if (sessSnap.docs.isEmpty) continue;
        final records = sessSnap.docs.first.data()['records'] as List<dynamic>? ?? [];
        for (final r in records) {
          final rec    = r as Map<String, dynamic>;
          final status = rec['status'] as String? ?? '';
          final match  = widget.showPresent
              ? status == 'PRESENT'
              : (status == 'ABSENT' || status == 'LEAVE');
          if (match) {
            final sid = rec['studentId'] as String? ?? '';
            if (sid.isNotEmpty) {
              allStudentIds.add(sid);
              rows.add({'studentId': sid, 'classId': classDoc.id});
            }
          }
        }
      }

      // Batch-fetch student names
      final nameMap = <String, String>{};
      for (var i = 0; i < allStudentIds.length; i += 10) {
        final chunk = allStudentIds.sublist(
            i, i + 10 > allStudentIds.length ? allStudentIds.length : i + 10);
        final snap = await db
            .collection(FSC.students)
            .where(FieldPath.documentId, whereIn: chunk)
            .get();
        for (final d in snap.docs) {
          nameMap[d.id] = d.data()['name'] as String? ?? '—';
        }
      }

      // Build final rows with names
      final finalRows = rows
          .map((r) => {
                'studentId': r['studentId']!,
                'name':      nameMap[r['studentId']] ?? '—',
                'classId':   r['classId']!,
                'className': classMap[r['classId']] ?? r['classId']!,
              })
          .toList()
        ..sort((a, b) => a['name']!.compareTo(b['name']!));

      if (mounted) setState(() { _rows ..clear() ..addAll(finalRows); _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.showPresent ? 'Present Today' : 'Absent Today';
    final color = widget.showPresent ? _kGreen : _kRed;

    final filtered = _rows.where((r) {
      final nameMatch = _query.isEmpty || r['name']!.toLowerCase().contains(_query);
      final classMatch = _classFilter == null || r['classId'] == _classFilter;
      return nameMatch && classMatch;
    }).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize:     0.4,
      maxChildSize:     0.95,
      expand: false,
      builder: (ctx, scrollCtrl) => Column(
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          // Title row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(title,
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: _kNavy)),
                ),
                if (!_loading)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8)),
                    child: Text('${filtered.length}',
                        style: TextStyle(
                            fontSize: 12,
                            color: color,
                            fontWeight: FontWeight.w700)),
                  ),
              ],
            ),
          ),
          // Search + class filter row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _query = v.toLowerCase()),
                    decoration: InputDecoration(
                      hintText: 'Search student…',
                      prefixIcon: const Icon(Icons.search_rounded, size: 18),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      isDense: true,
                    ),
                  ),
                ),
                if (_classNames.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      value: _classFilter,
                      hint: const Text('Class',
                          style: TextStyle(fontSize: 12)),
                      items: [
                        const DropdownMenuItem<String?>(
                            value: null, child: Text('All', style: TextStyle(fontSize: 12))),
                        ..._classNames.entries.map((e) => DropdownMenuItem<String?>(
                            value: e.key,
                            child: Text(e.value,
                                style: const TextStyle(fontSize: 12)))),
                      ],
                      onChanged: (v) => setState(() => _classFilter = v),
                      borderRadius: BorderRadius.circular(10),
                      style: const TextStyle(
                          color: _kNavy, fontSize: 12),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _loading
                ? Center(child: CircularProgressIndicator(color: color))
                : filtered.isEmpty
                    ? Center(
                        child: Text(
                          _query.isNotEmpty || _classFilter != null
                              ? 'No match found'
                              : widget.showPresent
                                  ? 'No present students recorded today'
                                  : 'No absent students recorded today',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollCtrl,
                        itemCount: filtered.length,
                        itemBuilder: (_, i) {
                          final row  = filtered[i];
                          final name = row['name']!;
                          final cls  = row['className']!;
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: color.withValues(alpha: 0.1),
                              child: Text(
                                name.isNotEmpty ? name[0].toUpperCase() : 'S',
                                style: TextStyle(
                                    color: color, fontWeight: FontWeight.w700),
                              ),
                            ),
                            title:    Text(name),
                            subtitle: Text(cls,
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey.shade500)),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// TAB 3 — FINANCE
// ═══════════════════════════════════════════════════════════════════════════
class _FinanceTab extends ConsumerStatefulWidget {
  final UserModel? user;
  final bool readOnlyFees;
  const _FinanceTab({required this.user, this.readOnlyFees = false});

  @override
  ConsumerState<_FinanceTab> createState() => _FinanceTabState();
}

class _FinanceTabState extends ConsumerState<_FinanceTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.user == null) return const SizedBox.shrink();
    final user = widget.user!;

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kDark,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Text('Finance',
            style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          if (!widget.readOnlyFees)
            IconButton(
              icon: const Icon(Icons.add_rounded),
              tooltip: 'Add Expense',
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20))),
                builder: (_) => _AddExpenseSheet(user: user),
              ),
            ),
        ],
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: _kAmber,
          labelColor: _kAmber,
          unselectedLabelColor: Colors.white60,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          tabs: const [
            Tab(text: 'Pending Fees'),
            Tab(text: 'Expenses'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _PendingFeesTab(user: user, readOnlyFees: widget.readOnlyFees),
          _MyExpensesTab(user: user, readOnly: widget.readOnlyFees),
        ],
      ),
    );
  }
}

// ── Pending Fees ──────────────────────────────────────────────────────────────
class _PendingFeesTab extends ConsumerWidget {
  final UserModel user;
  final bool readOnlyFees;
  const _PendingFeesTab({required this.user, this.readOnlyFees = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fs = ref.read(firestoreServiceProvider);
    final now = DateTime.now();
    final startYear = now.month >= 4 ? now.year : now.year - 1;
    final academicYear =
        '$startYear-${(startYear + 1).toString().substring(2)}';

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: fs.streamStudentsWithPendingFees(user.schoolId, academicYear),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: _kPrimary));
        }
        final fees = snap.data ?? [];
        if (fees.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_outline_rounded,
                    size: 52, color: _kGreen),
                const SizedBox(height: 12),
                const Text('No pending fees!',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _kNavy)),
                Text('All students are up to date',
                    style: TextStyle(
                        fontSize: 13, color: Colors.grey.shade500)),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: fees.length,
          itemBuilder: (_, i) {
            final f = fees[i];
            final studentName =
                (f['studentName'] as String?) ?? 'Student';
            final pending =
                ((f['totalPending'] as num?) ?? 0).toDouble();
            final paid = ((f['totalPaid'] as num?) ?? 0).toDouble();
            final fmt = NumberFormat('##,##,##0', 'en_IN');
            final total = paid + pending;
            final pct = total > 0 ? (paid / total) : 0.0;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(studentName,
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: _kNavy)),
                            Text(
                                (f['className'] as String?) ?? '',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('₹ ${fmt.format(pending)}',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: _kAmber)),
                          const Text('pending',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      backgroundColor: Colors.grey.shade200,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(_kGreen),
                      minHeight: 5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          final studentId = (f['studentId'] as String?) ?? '';
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FeeManagementScreen(
                                schoolId: user.schoolId,
                                adminUid: user.uid,
                                adminName: user.name,
                                showSetFeeOption: false,
                                canApplyFee: false,
                                canEditComponents: false,
                                readOnly: true,
                                initialStudentId: studentId,
                                initialStudentName: studentName,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.visibility_rounded,
                            size: 16),
                        label: const Text('Details'),
                        style: TextButton.styleFrom(
                            foregroundColor: _kPrimary,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10)),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Reminder sent to parent'),
                              backgroundColor: _kGreen,
                            ),
                          );
                        },
                        icon: const Icon(
                            Icons.notifications_active_rounded,
                            size: 16),
                        label: const Text('Notify'),
                        style: TextButton.styleFrom(
                            foregroundColor: _kAmber,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10)),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ── All Expenses Tab (school-wide) ────────────────────────────────────────────
class _MyExpensesTab extends ConsumerWidget {
  final UserModel user;
  final bool readOnly;
  const _MyExpensesTab({required this.user, this.readOnly = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fs = ref.read(firestoreServiceProvider);
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: readOnly
          ? fs.streamRecentExpensesByUser(user.schoolId, user.uid)
          : fs.streamAllExpensesBySchool(user.schoolId),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: _kPrimary));
        }
        final expenses = snap.data ?? [];
        if (expenses.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.receipt_long_rounded,
                    size: 52, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                Text('No expenses added yet',
                    style: TextStyle(
                        fontSize: 15, color: Colors.grey.shade500)),
                if (!readOnly) ...[
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20))),
                      builder: (_) => _AddExpenseSheet(user: user),
                    ),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add Expense'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: _kPrimary,
                        foregroundColor: Colors.white),
                  ),
                ],
              ],
            ),
          );
        }

        final fmt = NumberFormat('##,##,##0', 'en_IN');
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: expenses.length,
          itemBuilder: (_, i) {
            final e = expenses[i];
            final amount = ((e['amount'] as num?) ?? 0).toDouble();
            final category = (e['category'] as String?) ?? 'Other';
            final description = (e['description'] as String?) ?? '';
            final ts = e['createdAt'] as Timestamp?;
            final dateStr = ts != null
                ? DateFormat('dd MMM yyyy').format(ts.toDate())
                : '—';

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: ListTile(
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: _kGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.receipt_rounded,
                      color: _kGreen, size: 20),
                ),
                title: Text(category,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: _kNavy)),
                subtitle: Text(
                  [
                    if (description.isNotEmpty) description,
                    if ((e['addedByName'] as String? ?? '').isNotEmpty)
                      'By ${e['addedByName']}',
                    dateStr,
                  ].join(' · '),
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.shade500),
                ),
                trailing: Text(
                  '₹ ${fmt.format(amount)}',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _kNavy),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ─── Add Expense Sheet ────────────────────────────────────────────────────────
class _AddExpenseSheet extends ConsumerStatefulWidget {
  final UserModel user;
  const _AddExpenseSheet({required this.user});

  @override
  ConsumerState<_AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends ConsumerState<_AddExpenseSheet> {
  String _category = _kExpenseCategories.first;
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amtStr = _amountCtrl.text.trim();
    if (amtStr.isEmpty) {
      setState(() => _error = 'Enter amount');
      return;
    }
    final amount = double.tryParse(amtStr);
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Enter a valid amount');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final fs = ref.read(firestoreServiceProvider);
      await fs.addExpense({
        'schoolId': widget.user.schoolId,
        'amount': amount,
        'category': _category,
        'description': _descCtrl.text.trim(),
        'date': Timestamp.fromDate(_date),
        'addedByUid': widget.user.uid,
        'addedByName': widget.user.name,
        'status': 'ADDED',
      });
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expense added'),
            backgroundColor: _kGreen,
          ),
        );
      }
    } catch (e) {
      setState(() => _error = 'Failed: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text('Add Expense',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _kNavy)),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Category',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _kNavy)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _kExpenseCategories.map((cat) {
                final sel = _category == cat;
                return GestureDetector(
                  onTap: () => setState(() => _category = cat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: sel
                          ? _kPrimary
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(cat,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: sel
                                ? Colors.white
                                : Colors.grey.shade700)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount (₹)',
                prefixIcon: const Icon(Icons.currency_rupee_rounded,
                    color: _kPrimary),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: _kPrimary),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              decoration: InputDecoration(
                labelText: 'Description (optional)',
                prefixIcon: const Icon(Icons.notes_rounded,
                    color: _kPrimary),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: _kPrimary),
                ),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  builder: (ctx, child) => Theme(
                    data: ThemeData.light().copyWith(
                      colorScheme: const ColorScheme.light(
                          primary: _kPrimary),
                    ),
                    child: child!,
                  ),
                );
                if (picked != null) setState(() => _date = picked);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        color: _kPrimary, size: 18),
                    const SizedBox(width: 10),
                    Text(
                      DateFormat('dd MMM yyyy').format(_date),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!,
                  style: const TextStyle(
                      color: _kRed, fontSize: 12)),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPrimary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white))
                    : const Text('Save Expense',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15)),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// TAB 4 — FRONT DESK
// ═══════════════════════════════════════════════════════════════════════════
class _FrontDeskTab extends ConsumerWidget {
  final UserModel? user;
  const _FrontDeskTab({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kDark,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Text('Front Desk',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: _VisitorsTab(user: user!),
    );
  }
}

// ── Visitors Tab ──────────────────────────────────────────────────────────────
class _VisitorsTab extends ConsumerStatefulWidget {
  final UserModel user;
  const _VisitorsTab({required this.user});

  @override
  ConsumerState<_VisitorsTab> createState() => _VisitorsTabState();
}

class _VisitorsTabState extends ConsumerState<_VisitorsTab> {
  late final Stream<List<Map<String, dynamic>>> _visitorsStream;

  @override
  void initState() {
    super.initState();
    _visitorsStream = ref.read(firestoreServiceProvider)
        .streamTodayVisitors(widget.user.schoolId);
  }

  Future<void> _addVisitor() async {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final purposeCtrl = TextEditingController();
    final hostCtrl = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) {
          bool saving = false;
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Log Visitor',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _kNavy)),
                  const SizedBox(height: 16),
                  _FormField(
                      ctrl: nameCtrl,
                      label: 'Visitor Name',
                      icon: Icons.person_rounded),
                  const SizedBox(height: 12),
                  _FormField(
                      ctrl: phoneCtrl,
                      label: 'Phone Number',
                      icon: Icons.phone_rounded,
                      keyboardType: TextInputType.phone),
                  const SizedBox(height: 12),
                  _FormField(
                      ctrl: purposeCtrl,
                      label: 'Purpose of Visit',
                      icon: Icons.info_rounded),
                  const SizedBox(height: 12),
                  _FormField(
                      ctrl: hostCtrl,
                      label: 'Host (Teacher/Staff Name)',
                      icon: Icons.badge_rounded),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                              if (saving) return;
                              setSt(() => saving = true);
                              try {
                                final fs = ref.read(
                                    firestoreServiceProvider);
                                await fs.logVisitor({
                                  'schoolId': widget.user.schoolId,
                                  'name': nameCtrl.text.trim(),
                                  'phone': phoneCtrl.text.trim(),
                                  'purpose': purposeCtrl.text.trim(),
                                  'hostName': hostCtrl.text.trim(),
                                  'checkIn':
                                      FieldValue.serverTimestamp(),
                                  'visitDate': DateTime.now()
                                      .toIso8601String()
                                      .substring(0, 10),
                                  'loggedByUid': widget.user.uid,
                                });
                                if (ctx.mounted) {
                                  Navigator.pop(ctx);
                                }
                              } finally {
                                setSt(() => saving = false);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: _kPrimary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12))),
                      child: const Text('Log Visitor',
                          style: TextStyle(
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addVisitor,
        backgroundColor: _kPrimary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Visitor'),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _visitorsStream,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: _kPrimary));
          }
          final visitors = snap.data ?? [];
          if (visitors.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person_off_rounded,
                      size: 52, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text('No visitors today',
                      style: TextStyle(
                          fontSize: 15, color: Colors.grey.shade500)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: visitors.length,
            itemBuilder: (_, i) {
              final v = visitors[i];
              final name = (v['name'] as String?) ?? '—';
              final phone = (v['phone'] as String?) ?? '—';
              final purpose = (v['purpose'] as String?) ?? '—';
              final hostName = (v['hostName'] as String?) ?? '—';
              final visitorId = v['visitorId'] as String;
              final checkIn = v['checkIn'] as Timestamp?;
              final checkOut = v['checkOut'] as Timestamp?;
              final checkInStr = checkIn != null
                  ? DateFormat('hh:mm a').format(checkIn.toDate())
                  : '—';
              final isCheckedOut = checkOut != null;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isCheckedOut
                        ? Colors.grey.shade200
                        : _kGreen.withValues(alpha: 0.3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(name,
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: _kNavy)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: (isCheckedOut
                                    ? Colors.grey
                                    : _kGreen)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isCheckedOut ? 'Checked Out' : 'Inside',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isCheckedOut
                                  ? Colors.grey
                                  : _kGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('$phone · $purpose',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600)),
                    Text('Host: $hostName · In: $checkInStr',
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500)),
                    if (!isCheckedOut) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () async {
                            final fs = ref.read(firestoreServiceProvider);
                            await fs.checkOutVisitor(visitorId);
                          },
                          icon: const Icon(
                              Icons.exit_to_app_rounded,
                              size: 16),
                          label: const Text('Check Out'),
                          style: TextButton.styleFrom(
                              foregroundColor: _kPrimary,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10)),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// TAB 5 — PROFILE
// ═══════════════════════════════════════════════════════════════════════════
class _ProfileTab extends ConsumerWidget {
  final UserModel? user;
  const _ProfileTab({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasChildren = ref.watch(hasLinkedStudentsProvider).value ?? false;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Avatar
            Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                    colors: [_kPrimary, _kAccent]),
              ),
              child: Center(
                child: Text(
                  user?.name.isNotEmpty == true
                      ? user!.name[0].toUpperCase()
                      : 'A',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 34,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              user?.name ?? 'Admin',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: _kNavy,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: _kPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                user?.role == UserRole.ADMINISTRATOR
                    ? 'ADMINISTRATOR'
                    : 'ADMIN',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _kPrimary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 6),
            if (user?.phone.isNotEmpty == true)
              Text(
                user!.phone,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              ),
            const SizedBox(height: 36),
            if (user != null)
              Builder(builder: (context) {
                final u = user!;
                return Column(
                  children: [
                    _ProfileOption(
                      icon: Icons.edit_rounded,
                      label: 'Edit Profile',
                      color: _kPrimary,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                EditProfileScreen(user: u)),
                      ),
                    ),
                  ],
                );
              }),
            if (hasChildren) ...[
              const SizedBox(height: 12),
              _ProfileOption(
                icon: Icons.swap_horiz_rounded,
                label: 'Switch to Parent View',
                color: const Color(0xFFD97706),
                onTap: () {
                  ref.read(parentModeProvider.notifier).state = true;
                  context.go('/parent');
                },
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final router = GoRouter.of(context);
                  ref.read(parentModeProvider.notifier).state = false;
                  await NotificationService.signOut();
                  router.go('/login');
                },
                icon: const Icon(Icons.logout_rounded,
                    color: _kRed),
                label: const Text(
                  'Sign Out',
                  style: TextStyle(
                      color: _kRed, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: _kRed),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ProfileOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          label,
          style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: _kNavy),
        ),
        trailing: Icon(Icons.chevron_right_rounded,
            color: Colors.grey.shade400),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

// ─── Shared form field widget ─────────────────────────────────────────────────
class _FormField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;

  const _FormField({
    required this.ctrl,
    required this.label,
    required this.icon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: _kPrimary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kPrimary),
        ),
      ),
    );
  }
}

// ─── Stat Card ────────────────────────────────────────────────────────────────
class _StatData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final VoidCallback? onTap;

  const _StatData({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
    this.onTap,
  });
}

class _StatCard extends StatelessWidget {
  final _StatData data;
  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: data.onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: data.bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  Icon(data.icon, color: data.color, size: 20),
            ),
            const Spacer(),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                data.value,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: data.color,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              data.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Quick Action tile ────────────────────────────────────────────────────────
class _QuickAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
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
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: _kNavy,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
