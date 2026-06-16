import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../core/providers/core_providers.dart';
import '../../core/services/notification_service.dart';
import '../../core/models/user_model.dart';
import '../../core/constants/firestore_constants.dart';
import 'screens/manage_students_screen.dart';
import '../admin/screens/fee_management_screen.dart';
import '../teacher/screens/edit_profile_screen.dart';
import '../teacher/screens/class_announcement_screen.dart';

// ─── Helpers ─────────────────────────────────────────────────────────────────
String _currentAcademicYear() {
  final now = DateTime.now();
  final startYear = now.month >= 4 ? now.year : now.year - 1;
  return '$startYear-${(startYear + 1).toString().substring(2)}';
}

// ─── Theme colours ──────────────────────────────────────────────────────────
const _kPrimary = Color(0xFFDC2626); // rose-600
const _kDark    = Color(0xFF7F1D1D); // rose-900
const _kBg      = Color(0xFFFFF1F2); // rose-50
const _kAmber   = Color(0xFFF59E0B);
const _kGreen   = Color(0xFF059669);
const _kBlue    = Color(0xFF3B82F6);
const _kNavy    = Color(0xFF0A0F1E);

// ─── Expense categories ─────────────────────────────────────────────────────
const _kExpenseCategories = [
  'Salaries', 'Utilities', 'Maintenance', 'Supplies',
  'Events', 'Infrastructure', 'Transport', 'Other',
];

// ─── Roles that are NOT staff ─────────────────────────────────────────────────
const _kNonStaffRoles = {'PARENT', 'MANAGEMENT', 'SUPER_ADMIN'};

// ═══════════════════════════════════════════════════════════════════════════
class ManagementDashboard extends ConsumerStatefulWidget {
  const ManagementDashboard({super.key});

  @override
  ConsumerState<ManagementDashboard> createState() =>
      _ManagementDashboardState();
}

class _ManagementDashboardState extends ConsumerState<ManagementDashboard> {
  int _selectedIndex = 0;

  // ── Real-time stats ─────────────────────────────────────────────────────
  int    _studentCount    = 0;
  int    _classCount      = 0;
  int    _staffCount      = 0;
  double _monthlyExpenses = 0;

  StreamSubscription? _studentsSub;
  StreamSubscription? _classesSub;
  StreamSubscription? _staffSub;
  StreamSubscription? _expensesSub;
  // Track whether streams have been set up to avoid re-subscribing on rebuilds
  String? _streamSchoolId;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _studentsSub?.cancel();
    _classesSub?.cancel();
    _staffSub?.cancel();
    _expensesSub?.cancel();
    super.dispose();
  }

  // Called from build() once user data is available
  void _setupStreams(String schoolId) {
    if (_streamSchoolId == schoolId) return; // already set up for this school
    _streamSchoolId = schoolId;
    _studentsSub?.cancel();
    _classesSub?.cancel();
    _staffSub?.cancel();
    _expensesSub?.cancel();

    final db = FirebaseFirestore.instance;

    _studentsSub = db
        .collection(FSC.students)
        .where('schoolId', isEqualTo: schoolId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .listen(
          (snap) => setState(() => _studentCount = snap.docs.length),
          onError: (_) {},
        );

    // Classes: no isActive filter to avoid index issues; count in Dart
    _classesSub = db
        .collection(FSC.classes)
        .where('schoolId', isEqualTo: schoolId)
        .snapshots()
        .listen(
          (snap) {
            final count = snap.docs
                .where((d) =>
                    (d.data() as Map)['isActive'] != false)
                .length;
            setState(() => _classCount = count);
          },
          onError: (_) {},
        );

    _staffSub = db
        .collection(FSC.users)
        .where('schoolId', isEqualTo: schoolId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .listen(
          (snap) {
            final count = snap.docs
                .where((d) {
                  final role = (d.data() as Map)['role'] as String?;
                  return !_kNonStaffRoles.contains(role);
                })
                .length;
            setState(() => _staffCount = count);
          },
          onError: (_) {},
        );

    // Expenses: no date inequality filter to avoid composite index requirement.
    // Filter by current month in Dart.
    _expensesSub = db
        .collection('expenses')
        .where('schoolId', isEqualTo: schoolId)
        .snapshots()
        .listen(
          (snap) {
            final now          = DateTime.now();
            final startOfMonth = DateTime(now.year, now.month, 1);
            double total = 0;
            for (final d in snap.docs) {
              final date =
                  (d.data()['date'] as Timestamp?)?.toDate();
              if (date != null && !date.isBefore(startOfMonth)) {
                total += ((d.data()['amount'] as num?) ?? 0).toDouble();
              }
            }
            setState(() => _monthlyExpenses = total);
          },
          onError: (_) {},
        );
  }

  void _onTabChange(int tab) => setState(() => _selectedIndex = tab);

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    return userAsync.when(
      loading: () => const Scaffold(
        backgroundColor: _kBg,
        body: Center(child: CircularProgressIndicator(color: _kPrimary)),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: _kBg,
        body: Center(child: Text('Error: $e')),
      ),
      data: (user) {
        // Set up real-time streams as soon as user data is available
        if (user != null) {
          WidgetsBinding.instance.addPostFrameCallback(
              (_) { if (mounted) _setupStreams(user.schoolId); });
        }
        return Scaffold(
        backgroundColor: _kBg,
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            _HomeTab(
              user:            user,
              studentCount:    _studentCount,
              classCount:      _classCount,
              staffCount:      _staffCount,
              monthlyExpenses: _monthlyExpenses,
              onTabChange:     _onTabChange,
            ),
            _StaffTab(user: user),
            _FinanceTab(user: user),
            if (user != null)
              ClassAnnouncementScreen(
                schoolId:             user.schoolId,
                teacherUid:           user.uid,
                schoolWideOnly:       true,
                showAllAnnouncements: true,
              )
            else
              const SizedBox.shrink(),
            _ProfileTab(user: user),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (i) => setState(() => _selectedIndex = i),
          backgroundColor: Colors.white,
          indicatorColor: _kPrimary.withValues(alpha: 0.12),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded, color: _kPrimary),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_outline_rounded),
              selectedIcon: Icon(Icons.people_rounded, color: _kPrimary),
              label: 'Staff',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_outlined),
              selectedIcon:
                  Icon(Icons.account_balance_wallet_rounded, color: _kPrimary),
              label: 'Finance',
            ),
            NavigationDestination(
              icon: Icon(Icons.campaign_outlined),
              selectedIcon: Icon(Icons.campaign_rounded, color: _kPrimary),
              label: 'Announce',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded, color: _kPrimary),
              label: 'Profile',
            ),
          ],
        ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  HOME TAB
// ═══════════════════════════════════════════════════════════════════════════
class _HomeTab extends StatelessWidget {
  final UserModel? user;
  final int    studentCount;
  final int    classCount;
  final int    staffCount;
  final double monthlyExpenses;
  final void Function(int) onTabChange;

  const _HomeTab({
    required this.user,
    required this.studentCount,
    required this.classCount,
    required this.staffCount,
    required this.monthlyExpenses,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    final hour     = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good morning' : hour < 17 ? 'Good afternoon' : 'Good evening';
    final initials = user?.name.isNotEmpty == true
        ? user!.name.trim().split(' ').take(2).map((w) => w[0].toUpperCase()).join()
        : 'M';

    return SafeArea(
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // ── Header ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end:   Alignment.bottomRight,
                  colors: [_kDark, _kPrimary],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft:  Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(initials,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(greeting,
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white.withValues(alpha: 0.6))),
                            Text(user?.name ?? 'Management',
                                style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('Management',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _miniStat('Students', '$studentCount', Icons.school_rounded),
                      _miniStat('Classes',  '$classCount',   Icons.class_rounded),
                      _miniStat('Staff',    '$staffCount',   Icons.people_rounded),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Fee Overview card (clickable) ──────────────────────────
                if (user != null)
                  _FeeOverviewCard(schoolId: user!.schoolId),
                const SizedBox(height: 16),

                // ── Monthly expenses banner ────────────────────────────────
                _ExpenseBanner(monthlyExpenses: monthlyExpenses),
                const SizedBox(height: 20),

                // ── Quick actions ──────────────────────────────────────────
                _sectionLabel('Quick Actions'),
                const SizedBox(height: 12),
                _QuickActionsGrid(user: user, onTabChange: onTabChange),
                const SizedBox(height: 24),

                // ── Recent expenses ────────────────────────────────────────
                _sectionLabel('Recent Expenses'),
                const SizedBox(height: 12),
                if (user != null) _RecentExpenses(schoolId: user!.schoolId),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16)),
            Text(label,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 10)),
          ],
        ),
      ),
    );
  }

  static Widget _sectionLabel(String label) => Text(label,
      style: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w700, color: _kNavy));
}

// ── Fee Overview Card ─────────────────────────────────────────────────────────
class _FeeOverviewCard extends StatelessWidget {
  final String schoolId;
  const _FeeOverviewCard({required this.schoolId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(FSC.fees)
          .where('schoolId', isEqualTo: schoolId)
          .snapshots(),
      builder: (ctx, snap) {
        double collected = 0, pending = 0;
        final docs = snap.data?.docs ?? [];
        for (final d in docs) {
          final data = d.data() as Map<String, dynamic>;
          collected += ((data['totalPaid']    as num?) ?? 0).toDouble();
          pending   += ((data['totalPending'] as num?) ?? 0).toDouble();
        }
        final fmt = NumberFormat('##,##,##0', 'en_IN');

        return GestureDetector(
          onTap: () => _showFeeDetail(context, docs, collected, pending),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF064E3B), Color(0xFF059669)],
                begin: Alignment.topLeft,
                end:   Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.account_balance_rounded,
                          color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Fee Overview — All Students',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('Details',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _feeStatCol(
                          'Collected',
                          '₹${fmt.format(collected)}',
                          Icons.check_circle_rounded),
                    ),
                    Container(
                        width: 1, height: 36,
                        color: Colors.white.withValues(alpha: 0.2)),
                    Expanded(
                      child: _feeStatCol(
                          'Pending',
                          '₹${fmt.format(pending)}',
                          Icons.pending_rounded),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _feeStatCol(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800)),
        Text(label,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65),
                fontSize: 10)),
      ],
    );
  }

  void _showFeeDetail(BuildContext context,
      List<QueryDocumentSnapshot> docs,
      double collected,
      double pending) {
    // Deduplicate by studentId: if a student has multiple fee records
    // (e.g. one created by mobile, one by website before ID normalisation),
    // keep only the first occurrence so the detail sheet shows the correct count.
    final seen = <String>{};
    final dedupedDocs = docs.where((d) {
      final data = d.data() as Map<String, dynamic>;
      final sid  = (data['studentId'] as String?) ?? d.id;
      return seen.add(sid);
    }).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _FeeDetailSheet(
          docs: dedupedDocs, collected: collected, pending: pending),
    );
  }
}

// ── Fee Detail Sheet ──────────────────────────────────────────────────────────
class _FeeDetailSheet extends StatelessWidget {
  final List<QueryDocumentSnapshot> docs;
  final double collected;
  final double pending;
  const _FeeDetailSheet(
      {required this.docs, required this.collected, required this.pending});

  @override
  Widget build(BuildContext context) {
    final fmt   = NumberFormat('##,##,##0', 'en_IN');
    final total = collected + pending;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (_, ctrl) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Fee Summary',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: _kNavy)),
            const SizedBox(height: 16),
            // Summary row
            Row(
              children: [
                _summaryCard('Total',    '₹${fmt.format(total)}',     _kNavy),
                const SizedBox(width: 10),
                _summaryCard('Collected','₹${fmt.format(collected)}', _kGreen),
                const SizedBox(width: 10),
                _summaryCard('Pending',  '₹${fmt.format(pending)}',   _kAmber),
              ],
            ),
            const SizedBox(height: 16),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: total > 0 ? collected / total : 0,
                minHeight: 10,
                backgroundColor: _kAmber.withValues(alpha: 0.2),
                color: _kGreen,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              total > 0
                  ? '${(collected / total * 100).toStringAsFixed(1)}% collected'
                  : 'No fee records',
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
            const SizedBox(height: 16),
            // Student list
            Expanded(
              child: docs.isEmpty
                  ? Center(
                      child: Text('No fee records yet',
                          style: TextStyle(
                              color: Colors.grey[400], fontSize: 13)),
                    )
                  : ListView.builder(
                      controller: ctrl,
                      itemCount: docs.length,
                      itemBuilder: (_, i) {
                        final data    = docs[i].data() as Map<String, dynamic>;
                        final name    = (data['studentName'] as String?) ?? 'Student';
                        final paid    = ((data['totalPaid']    as num?) ?? 0).toDouble();
                        final pend    = ((data['totalPending'] as num?) ?? 0).toDouble();
                        final isPaid  = pend <= 0;
                        final color   = isPaid ? _kGreen : _kAmber;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey[100]!),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(name,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: _kNavy)),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('₹${fmt.format(paid)}',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: _kGreen)),
                                  if (pend > 0)
                                    Text('₹${fmt.format(pend)} due',
                                        style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: color)),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: color)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// ── Expense Banner ──────────────────────────────────────────────────────────
class _ExpenseBanner extends StatelessWidget {
  final double monthlyExpenses;
  const _ExpenseBanner({required this.monthlyExpenses});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('##,##,##0', 'en_IN');
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF022C22), Color(0xFF022C22)],
          begin: Alignment.topLeft,
          end:   Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.trending_down_rounded,
                color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '₹ ${fmt.format(monthlyExpenses)}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800),
                ),
                Text(
                  'Total expenses — ${DateFormat('MMMM yyyy').format(DateTime.now())}',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quick Actions Grid ──────────────────────────────────────────────────────
class _QuickActionsGrid extends StatelessWidget {
  final UserModel? user;
  final void Function(int) onTabChange;
  const _QuickActionsGrid({required this.user, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _Action('Staff List',   Icons.people_rounded,             _kBlue,    () => onTabChange(1)),
      _Action('Add Expense',  Icons.add_circle_outline_rounded, _kPrimary, () => _showAddExpense(context, user)),
      _Action('Salary Sheet', Icons.receipt_long_rounded,       _kGreen,   () => onTabChange(2)),
      _Action('Finance',      Icons.bar_chart_rounded,          _kAmber,   () => onTabChange(2)),
      _Action('Students',     Icons.school_rounded,             const Color(0xFFD97706), () => _openStudents(context)),
      _Action('View Fees',    Icons.account_balance_wallet_rounded, const Color(0xFF059669), () => _openFees(context, user)),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:    3,
        childAspectRatio:  1.0,
        crossAxisSpacing:  10,
        mainAxisSpacing:   10,
      ),
      itemCount:   actions.length,
      itemBuilder: (_, i) => _actionChip(actions[i]),
    );
  }

  void _showAddExpense(BuildContext ctx, UserModel? user) {
    if (user == null) return;
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _AddExpenseSheet(user: user),
    );
  }

  void _openStudents(BuildContext ctx) {
    if (user == null) return;
    Navigator.push(
      ctx,
      MaterialPageRoute(
        builder: (_) => ManageStudentsScreen(
          schoolId:     user!.schoolId,
          academicYear: _currentAcademicYear(),
        ),
      ),
    );
  }

  void _openFees(BuildContext ctx, UserModel? u) {
    if (u == null) return;
    Navigator.push(
      ctx,
      MaterialPageRoute(
        builder: (_) => FeeManagementScreen(
          schoolId:          u.schoolId,
          adminUid:          u.uid,
          adminName:         u.name,
          showSetFeeOption:  false,
          canApplyFee:       false,
          canEditComponents: true,
        ),
      ),
    );
  }

  Widget _actionChip(_Action a) {
    return GestureDetector(
      onTap: a.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color:      Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset:     const Offset(0, 2)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color:        a.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(a.icon, color: a.color, size: 22),
            ),
            const SizedBox(height: 7),
            Text(a.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _kNavy)),
          ],
        ),
      ),
    );
  }
}

class _Action {
  final String    label;
  final IconData  icon;
  final Color     color;
  final VoidCallback onTap;
  const _Action(this.label, this.icon, this.color, this.onTap);
}

// ── Recent Expenses ──────────────────────────────────────────────────────────
class _RecentExpenses extends StatelessWidget {
  final String schoolId;
  const _RecentExpenses({required this.schoolId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('expenses')
          .where('schoolId', isEqualTo: schoolId)
          // No limit — all expenses are fetched and sorted client-side so that
          // salary expenses (deterministic IDs like "salary_uid_month") are
          // never excluded by a document-ID-ordered limit cut-off.
          .snapshots(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: _kPrimary));
        }
        var docs = snap.data?.docs ?? [];
        // Sort in Dart to avoid Firestore composite-index requirement
        docs = [...docs]..sort((a, b) {
            final aTs = (a.data() as Map)['date'] as Timestamp?;
            final bTs = (b.data() as Map)['date'] as Timestamp?;
            if (aTs == null && bTs == null) return 0;
            if (aTs == null) return 1;
            if (bTs == null) return -1;
            return bTs.compareTo(aTs);
          });
        final recent = docs.take(5).toList();
        if (recent.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.receipt_long_outlined,
                    color: Colors.grey[300], size: 20),
                const SizedBox(width: 10),
                Text('No expenses recorded yet',
                    style: TextStyle(color: Colors.grey[400], fontSize: 13)),
              ],
            ),
          );
        }
        return Column(
          children: recent
              .map((d) => _ExpenseTile(data: d.data() as Map<String, dynamic>))
              .toList(),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  STAFF TAB
// ═══════════════════════════════════════════════════════════════════════════
class _StaffTab extends ConsumerStatefulWidget {
  final UserModel? user;
  const _StaffTab({required this.user});

  @override
  ConsumerState<_StaffTab> createState() => _StaffTabState();
}

class _StaffTabState extends ConsumerState<_StaffTab> {
  String _filterRole = 'All';
  final _roles       = ['All', 'TEACHER', 'ADMIN', 'PRINCIPAL', 'ADMINISTRATOR'];

  // Staff docs + current month salary map (uid → salary data)
  List<QueryDocumentSnapshot> _staffDocs       = [];
  Map<String, Map<String, dynamic>> _monthSalaries = {};
  StreamSubscription? _staffSub;
  StreamSubscription? _salarySub;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) _setupStreams();
  }

  void _setupStreams() {
    final schoolId  = widget.user!.schoolId;
    final monthKey  = DateFormat('yyyy-MM').format(DateTime.now());
    final db        = FirebaseFirestore.instance;

    _staffSub = db
        .collection(FSC.users)
        .where('schoolId', isEqualTo: schoolId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .listen((snap) {
          setState(() {
            _staffDocs = snap.docs
                .where((d) {
                  final role = (d.data() as Map)['role'] as String?;
                  return !_kNonStaffRoles.contains(role);
                })
                .toList();
          });
        });

    _salarySub = db
        .collection(FSC.staffSalaries)
        .where('schoolId', isEqualTo: schoolId)
        .where('month', isEqualTo: monthKey)
        .snapshots()
        .listen((snap) {
          final map = <String, Map<String, dynamic>>{};
          for (final d in snap.docs) {
            final type = (d.data()['type'] as String?) ?? 'salary';
            if (type != 'salary') continue;
            final uid = (d.data()['uid'] as String?) ?? d.id;
            map[uid] = d.data();
          }
          setState(() => _monthSalaries = map);
        });
  }

  @override
  void dispose() {
    _staffSub?.cancel();
    _salarySub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.user == null) return const SizedBox.shrink();

    var filtered = _staffDocs.where((d) {
      if (_filterRole == 'All') return true;
      return (d.data() as Map)['role'] == _filterRole;
    }).toList();

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kDark,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Text('Staff Management',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          // Role filter chips
          Container(
            height: 48,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _roles.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final r        = _roles[i];
                final selected = _filterRole == r;
                return GestureDetector(
                  onTap: () => setState(() => _filterRole = r),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: selected ? _kPrimary : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(r,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: selected ? Colors.white : Colors.grey[600])),
                  ),
                );
              },
            ),
          ),
          // Staff list
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline_rounded,
                            size: 48, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        Text('No staff found',
                            style: TextStyle(
                                color: Colors.grey[400], fontSize: 14)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final doc  = filtered[i];
                      final data = doc.data() as Map<String, dynamic>;
                      final uid  = doc.id;
                      return _StaffCard(
                        uid:          uid,
                        data:         data,
                        salaryData:   _monthSalaries[uid],
                        onSalaryTap:  () => _showSalarySheet(
                            context, {'uid': uid, ...data}),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showSalarySheet(BuildContext context, Map<String, dynamic> staff) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _SalarySheet(
        staff:      staff,
        schoolId:   widget.user?.schoolId ?? '',
        payerName:  widget.user?.name ?? 'Management',
        payerUid:   widget.user?.uid  ?? '',
        payerRole:  widget.user?.role.name ?? 'MANAGEMENT',
      ),
    );
  }
}

// ── Staff Card ──────────────────────────────────────────────────────────────
class _StaffCard extends StatelessWidget {
  final String uid;
  final Map<String, dynamic> data;
  final Map<String, dynamic>? salaryData; // current month salary, null if none
  final VoidCallback onSalaryTap;
  const _StaffCard({
    required this.uid,
    required this.data,
    required this.salaryData,
    required this.onSalaryTap,
  });

  static const _roleColors = {
    'TEACHER':       Color(0xFFF59E0B),
    'ADMIN':         Color(0xFF059669),
    'PRINCIPAL':     Color(0xFF3B82F6),
    'ADMINISTRATOR': Color(0xFFD97706),
  };

  @override
  Widget build(BuildContext context) {
    final name    = (data['name']  as String?) ?? 'Staff';
    final role    = (data['role']  as String?) ?? 'STAFF';
    final phone   = (data['phone'] as String?) ?? '';
    final color   = _roleColors[role] ?? Colors.grey;
    final initials = name.trim().split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();

    // Salary badge for this month
    String?  salaryStatus;
    if (salaryData != null) {
      salaryStatus = (salaryData!['status'] as String?) ?? 'PENDING';
    }
    final isPaid = salaryStatus == 'PAID';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(initials,
                  style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w800,
                      fontSize: 16)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: _kNavy)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(role,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: color)),
                    ),
                    const SizedBox(width: 6),
                    Text(phone,
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey[500])),
                  ],
                ),
                if (salaryStatus != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: (isPaid ? _kGreen : _kAmber)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isPaid
                          ? 'Salary Paid this month'
                          : 'Salary Pending this month',
                      style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: isPaid ? _kGreen : _kAmber),
                    ),
                  ),
                ],
              ],
            ),
          ),
          GestureDetector(
            onTap: onSalaryTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _kGreen.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _kGreen.withValues(alpha: 0.25)),
              ),
              child: const Text('Salary',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _kGreen)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Salary component row ─────────────────────────────────────────────────────
class _SalaryComponentRow {
  final TextEditingController nameCtrl;
  final TextEditingController amountCtrl;
  _SalaryComponentRow({String name = '', String amount = ''})
      : nameCtrl   = TextEditingController(text: name),
        amountCtrl = TextEditingController(text: amount);
  void dispose() {
    nameCtrl.dispose();
    amountCtrl.dispose();
  }
}

const _kSalaryComponentSuggestions = [
  'Basic',
  'HRA',
  'DA',
  'Medical Allowance',
  'Transport Allowance',
  'Special Allowance',
  'PF Deduction',
  'TDS Deduction',
];

// ── Salary Sheet (multi-step) ────────────────────────────────────────────────
enum _SalaryMode { picker, updateBase, thisMonth, otherPayment }

class _SalarySheet extends StatefulWidget {
  final Map<String, dynamic> staff;
  final String schoolId;
  final String payerName;
  final String payerUid;
  final String payerRole;
  const _SalarySheet({
    required this.staff, required this.schoolId,
    required this.payerName, required this.payerUid, required this.payerRole,
  });

  @override
  State<_SalarySheet> createState() => _SalarySheetState();
}

class _SalarySheetState extends State<_SalarySheet> {
  _SalaryMode _mode         = _SalaryMode.picker;
  // For thisMonth / otherPayment — single payment amount
  final _amountCtrl         = TextEditingController();
  final _notesCtrl          = TextEditingController();
  String _status            = 'PAID';
  bool   _isSaving          = false;
  // Base salary components
  final List<_SalaryComponentRow> _salaryComponents = [];
  double _baseSalary        = 0;
  Map<String, double> _salaryComponentsMap = {};
  bool   _loadingBase       = false;
  // Current month payment history
  double _totalPaidThisMonth = 0;
  List<Map<String, dynamic>> _existingPayments = [];
  final String _month    = DateFormat('MMMM yyyy').format(DateTime.now());
  final String _monthKey = DateFormat('yyyy-MM').format(DateTime.now());

  String get _uid  => (widget.staff['uid']  as String?) ?? '';
  String get _name => (widget.staff['name'] as String?) ?? 'Staff';

  double get _componentTotal => _salaryComponents.fold(0.0, (acc, c) {
    return acc + (double.tryParse(c.amountCtrl.text.trim()) ?? 0.0);
  });

  @override
  void dispose() {
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    for (final c in _salaryComponents) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadBaseSalary() async {
    setState(() => _loadingBase = true);
    try {
      final db = FirebaseFirestore.instance;
      final salaryDocId = '${_uid}_$_monthKey';
      final results = await Future.wait([
        db.collection(FSC.staffSalarySettings).doc('${widget.schoolId}_$_uid').get(),
        db.collection(FSC.staffSalaries).doc(salaryDocId).get(),
      ]);
      final settingsDoc = results[0];
      final monthDoc    = results[1];

      if (settingsDoc.exists) {
        final data  = settingsDoc.data() ?? {};
        final base  = ((data['monthlySalary'] as num?) ?? 0).toDouble();
        final rawComponents = (data['salaryComponents'] as Map<String, dynamic>?) ?? {};
        final components    = rawComponents.map(
            (k, v) => MapEntry(k, (v as num).toDouble()));
        setState(() {
          _baseSalary          = base;
          _salaryComponentsMap = components;
        });
        _salaryComponents.clear();
        if (components.isNotEmpty) {
          for (final e in components.entries) {
            _salaryComponents.add(_SalaryComponentRow(name: e.key, amount: e.value.toStringAsFixed(0)));
          }
        } else {
          _salaryComponents.add(_SalaryComponentRow());
        }
      } else {
        _salaryComponents.add(_SalaryComponentRow());
      }

      if (monthDoc.exists) {
        final md = monthDoc.data() ?? {};
        setState(() {
          _totalPaidThisMonth = ((md['amount'] as num?) ?? 0).toDouble();
          _existingPayments   = (md['payments'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        });
      }
    } catch (_) {
      if (_salaryComponents.isEmpty) _salaryComponents.add(_SalaryComponentRow());
    }
    if (mounted) setState(() => _loadingBase = false);
  }

  Map<String, double> _buildSalaryComponentMap() {
    final map = <String, double>{};
    for (final c in _salaryComponents) {
      final name   = c.nameCtrl.text.trim();
      final amount = double.tryParse(c.amountCtrl.text.trim()) ?? 0.0;
      if (name.isNotEmpty && amount > 0) map[name] = amount;
    }
    return map;
  }

  Future<void> _saveBaseSalary() async {
    final components = _buildSalaryComponentMap();
    if (components.isEmpty) return;
    final total = components.values.fold(0.0, (a, b) => a + b);
    setState(() => _isSaving = true);
    try {
      await FirebaseFirestore.instance
          .collection(FSC.staffSalarySettings)
          .doc('${widget.schoolId}_$_uid')
          .set({
        'uid':              _uid,
        'name':             _name,
        'schoolId':         widget.schoolId,
        'salaryComponents': components,
        'monthlySalary':    total,
        'updatedAt':        Timestamp.now(),
      }, SetOptions(merge: true));
      if (mounted) Navigator.pop(context);
    } catch (_) {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _saveMonthSalary() async {
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount <= 0) return;
    setState(() => _isSaving = true);
    try {
      final db        = FirebaseFirestore.instance;
      final salaryRef = '${_uid}_$_monthKey';
      final role      = (widget.staff['role'] as String?) ?? '';

      // Load existing to compute new total & status
      final existingSnap = await db.collection(FSC.staffSalaries).doc(salaryRef).get();
      final existingTotal = ((existingSnap.data()?['amount'] as num?) ?? 0).toDouble();
      final newTotal      = existingTotal + amount;
      final newStatus     = _baseSalary > 0
          ? (newTotal >= _baseSalary ? 'PAID' : 'PARTIAL')
          : 'PAID';

      final payEntry = {
        'amount':      amount,
        'paidAt':      Timestamp.now(),
        'paidByName':  widget.payerName,
        'paidByUid':   widget.payerUid,
        'notes':       _notesCtrl.text.trim(),
      };

      await db.collection(FSC.staffSalaries).doc(salaryRef).set({
        'uid':        _uid,
        'name':       _name,
        'role':       role,
        'schoolId':   widget.schoolId,
        'month':      _monthKey,
        'type':       'salary',
        'amount':     FieldValue.increment(amount),
        'status':     newStatus,
        'payments':   FieldValue.arrayUnion([payEntry]),
        'updatedAt':  FieldValue.serverTimestamp(),
        'updatedByName': widget.payerName,
        'updatedByUid':  widget.payerUid,
      }, SetOptions(merge: true));

      // Unique expense per payment — prevents overwriting previous entries
      final expenseDocId = 'salary_${_uid}_${_monthKey}_${DateTime.now().millisecondsSinceEpoch}';
      await db.collection('expenses').doc(expenseDocId).set({
        'schoolId':    widget.schoolId,
        'title':       'Salary paid to $_name ($role) by ${widget.payerName}',
        'description': 'Salary: ₹${amount.toStringAsFixed(0)} paid to $_name ($role) by ${widget.payerName} — $_month',
        'amount':      amount,
        'category':    'Salaries',
        'addedByName': widget.payerName,
        'addedByUid':  widget.payerUid,
        'date':        FieldValue.serverTimestamp(),
        'createdAt':   FieldValue.serverTimestamp(),
        'salaryRef':   salaryRef,
      });

      if (mounted) Navigator.pop(context);
    } catch (_) {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _saveOtherPayment() async {
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount <= 0) return;
    setState(() => _isSaving = true);
    try {
      final db    = FirebaseFirestore.instance;
      final notes = _notesCtrl.text.trim();

      final docRef = await db.collection(FSC.staffSalaries).add({
        'uid':        _uid,
        'name':       _name,
        'schoolId':   widget.schoolId,
        'month':      _monthKey,
        'monthLabel': _month,
        'amount':     amount,
        'status':     _status,
        'type':       'other',
        'notes':      notes,
        'updatedAt':  Timestamp.now(),
      });

      // Write to expenses for PAID other payments
      if (_status == 'PAID') {
        final label = notes.isNotEmpty ? notes : 'Other Payment';
        await db.collection('expenses').add({
          'schoolId':    widget.schoolId,
          'title':       '$label: $_name ($_month)',
          'description': '$label: $_name ($_month)',
          'amount':      amount,
          'category':    'Salaries',
          'notes':       notes,
          'addedByName': 'Management',
          'addedByUid':  '',
          'date':        Timestamp.now(),
          'createdAt':   Timestamp.now(),
          'salaryRef':   docRef.id,
        });
      }

      if (mounted) Navigator.pop(context);
    } catch (_) {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: switch (_mode) {
          _SalaryMode.picker       => _buildPicker(),
          _SalaryMode.updateBase   => _buildUpdateBase(),
          _SalaryMode.thisMonth    => _buildThisMonth(),
          _SalaryMode.otherPayment => _buildOtherPayment(),
        },
      ),
    );
  }

  Widget _buildPicker() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _sheetHeader('Salary Management', _name),
        const SizedBox(height: 20),
        _modeOption(
          icon:  Icons.calendar_month_rounded,
          color: _kGreen,
          title: 'This Month Salary',
          sub:   'Record $_month salary payment',
          onTap: () async {
            await _loadBaseSalary();
            if (mounted) setState(() => _mode = _SalaryMode.thisMonth);
          },
        ),
        const SizedBox(height: 10),
        _modeOption(
          icon:  Icons.add_card_rounded,
          color: _kAmber,
          title: 'Other Payment',
          sub:   'Bonus, advance, or miscellaneous',
          onTap: () => setState(() => _mode = _SalaryMode.otherPayment),
        ),
      ],
    );
  }

  Widget _buildUpdateBase() {
    if (_loadingBase) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _sheetHeader('Update Base Salary', _name),
          const SizedBox(height: 24),
          const Center(child: CircularProgressIndicator(
              color: _kGreen, strokeWidth: 2)),
          const SizedBox(height: 24),
        ],
      );
    }
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sheetHeader('Update Base Salary', _name),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Salary Components',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _kNavy)),
              TextButton.icon(
                onPressed: () =>
                    setState(() => _salaryComponents.add(_SalaryComponentRow())),
                icon: const Icon(Icons.add_rounded,
                    size: 15, color: _kGreen),
                label: const Text('Add',
                    style: TextStyle(
                        color: _kGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
                style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...List.generate(_salaryComponents.length, (i) {
            final row = _salaryComponents[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: _SalaryComponentField(
                      controller: row.nameCtrl,
                      hint: 'Component (e.g. Basic)',
                      onSuggest: () => _showSalarySuggestions(i),
                      onChanged: () => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: row.amountCtrl,
                      onChanged: (_) => setState(() {}),
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Amount',
                        hintStyle: TextStyle(
                            color: Colors.grey[400], fontSize: 12),
                        prefixText: '₹ ',
                        prefixStyle: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                BorderSide(color: Colors.grey[300]!)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                BorderSide(color: Colors.grey[300]!)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                                color: _kGreen, width: 1.5)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  if (_salaryComponents.length > 1)
                    IconButton(
                      icon: Icon(Icons.remove_circle_outline_rounded,
                          color: Colors.grey[400], size: 20),
                      onPressed: () {
                        _salaryComponents[i].dispose();
                        setState(() => _salaryComponents.removeAt(i));
                      },
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                    )
                  else
                    const SizedBox(width: 28),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          // Total banner
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _kNavy,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Monthly Salary',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                Text(
                  '₹${_componentTotal.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _saveButton('Save Base Salary', _saveBaseSalary),
        ],
      ),
    );
  }

  void _showSalarySuggestions(int index) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Quick add',
                style: TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _kSalaryComponentSuggestions.map((s) =>
                GestureDetector(
                  onTap: () {
                    setState(() =>
                        _salaryComponents[index].nameCtrl.text = s);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _kGreen.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: _kGreen.withValues(alpha: 0.25)),
                    ),
                    child: Text(s,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _kGreen)),
                  ),
                ),
              ).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThisMonth() {
    final remaining = _baseSalary > 0
        ? (_baseSalary - _totalPaidThisMonth).clamp(0.0, double.infinity)
        : 0.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sheetHeader('This Month Salary', '$_name · $_month'),
        if (_loadingBase)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: CircularProgressIndicator(color: _kGreen, strokeWidth: 2)),
          )
        else ...[
          const SizedBox(height: 14),
          // Summary: total paid + remaining
          if (_totalPaidThisMonth > 0 || _baseSalary > 0)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Total Paid', style: TextStyle(fontSize: 11, color: Color(0xFF065F46))),
                    Text('₹${_totalPaidThisMonth.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF065F46))),
                  ]),
                  if (_baseSalary > 0)
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      const Text('Remaining', style: TextStyle(fontSize: 11, color: Color(0xFFF59E0B))),
                      Text('₹${remaining.toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFFF59E0B))),
                    ]),
                ],
              ),
            ),
          // Payment history
          if (_existingPayments.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Payment History',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                    color: Colors.grey[500], letterSpacing: 0.4)),
            const SizedBox(height: 6),
            ..._existingPayments.reversed.map((p) {
              final amt = ((p['amount'] as num?) ?? 0).toDouble();
              final by  = (p['paidByName'] as String?) ?? '';
              final ts  = p['paidAt'] as Timestamp?;
              final date = ts != null ? DateFormat('dd/MM/yy').format(ts.toDate()) : '';
              return Container(
                margin: const EdgeInsets.only(bottom: 5),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10)),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('₹${amt.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  Text('${by.isNotEmpty ? "by $by" : ""}${date.isNotEmpty ? " · $date" : ""}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                ]),
              );
            }),
          ],
          const SizedBox(height: 14),
          // Base salary breakdown (reference only)
          if (_salaryComponentsMap.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _kGreen.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _kGreen.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Base Salary Breakdown',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _kGreen)),
                  const SizedBox(height: 8),
                  ..._salaryComponentsMap.entries.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(e.key, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                      Text('₹${e.value.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _kNavy)),
                    ]),
                  )),
                  const Divider(height: 12),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Total', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    Text('₹${_salaryComponentsMap.values.fold(0.0, (a, b) => a + b).toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _kGreen)),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          TextField(
            controller: _amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: _inputDeco(
              remaining > 0 ? 'New Payment (₹) — ₹${remaining.toStringAsFixed(0)} remaining' : 'New Payment Amount (₹)',
              Icons.currency_rupee_rounded,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesCtrl,
            decoration: _inputDeco('Notes (optional)', Icons.notes_rounded),
          ),
          const SizedBox(height: 20),
          _saveButton('Record Payment', _saveMonthSalary),
        ],
      ],
    );
  }

  Widget _buildOtherPayment() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sheetHeader('Other Payment', _name),
        const SizedBox(height: 16),
        TextField(
          controller: _amountCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: _inputDeco('Amount (₹)', Icons.currency_rupee_rounded),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: _statusOption('PAID', _kGreen,
                    Icons.check_circle_rounded)),
            const SizedBox(width: 10),
            Expanded(
                child: _statusOption('PENDING', _kAmber,
                    Icons.pending_rounded)),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notesCtrl,
          decoration: _inputDeco('Description / Notes', Icons.notes_rounded),
        ),
        const SizedBox(height: 20),
        _saveButton('Save Payment', _saveOtherPayment),
      ],
    );
  }

  Widget _sheetHeader(String title, String sub) {
    return Row(
      children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: _kGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.receipt_long_rounded,
              color: _kGreen, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 16)),
            Text(sub,
                style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          ],
        ),
      ],
    );
  }

  Widget _modeOption({
    required IconData icon,
    required Color color,
    required String title,
    required String sub,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.03), blurRadius: 6)
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: _kNavy)),
                  Text(sub,
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey[500])),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: Colors.grey[300], size: 20),
          ],
        ),
      ),
    );
  }

  Widget _statusOption(String status, Color color, IconData icon) {
    final selected = _status == status;
    return GestureDetector(
      onTap: () => setState(() => _status = status),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: selected ? color : Colors.grey[200]!,
              width: selected ? 1.5 : 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: selected ? color : Colors.grey[400], size: 16),
            const SizedBox(width: 6),
            Text(status,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: selected ? color : Colors.grey[400])),
          ],
        ),
      ),
    );
  }

  Widget _saveButton(String label, Future<void> Function() onTap) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isSaving ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: _kGreen,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
        child: _isSaving
            ? const SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15)),
      ),
    );
  }

  InputDecoration _inputDeco(String hint, IconData icon) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        prefixIcon: Icon(icon, size: 18, color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.grey[50],
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      );
}

// ── Helper widget for salary component name field with suggestions ───────────
class _SalaryComponentField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final VoidCallback onSuggest;
  final VoidCallback onChanged;
  const _SalaryComponentField({
    required this.controller,
    required this.hint,
    required this.onSuggest,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: (_) => onChanged(),
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _kGreen, width: 1.5)),
        suffixIcon: IconButton(
          icon: Icon(Icons.lightbulb_outline_rounded,
              size: 14, color: Colors.grey[400]),
          onPressed: onSuggest,
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  FINANCE TAB
// ═══════════════════════════════════════════════════════════════════════════
class _FinanceTab extends ConsumerStatefulWidget {
  final UserModel? user;
  const _FinanceTab({required this.user});

  @override
  ConsumerState<_FinanceTab> createState() => _FinanceTabState();
}

class _FinanceTabState extends ConsumerState<_FinanceTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.user == null) return const SizedBox.shrink();
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kDark,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Text('Finance',
            style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          // Add expense button
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add Expense',
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20))),
              builder: (_) => _AddExpenseSheet(user: widget.user!),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: _kAmber,
          labelColor: _kAmber,
          unselectedLabelColor: Colors.white60,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          tabs: const [
            Tab(text: 'Expenses'),
            Tab(text: 'Salary Sheet'),
            Tab(text: 'Fee'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _ExpensesTab(schoolId: widget.user!.schoolId),
          _SalarySheetTab(schoolId: widget.user!.schoolId),
          _FeeCollectionTab(schoolId: widget.user!.schoolId),
        ],
      ),
    );
  }
}

// ── Expenses List Tab ───────────────────────────────────────────────────────
class _ExpensesTab extends StatelessWidget {
  final String schoolId;
  const _ExpensesTab({required this.schoolId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('expenses')
          .where('schoolId', isEqualTo: schoolId)
          // No orderBy / limit — sort in Dart to avoid composite-index error,
          // and no limit so salary expenses (deterministic IDs) are never cut off.
          .snapshots(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: _kPrimary));
        }
        if (snap.hasError) {
          return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Error: ${snap.error}',
                    style: const TextStyle(color: Colors.red)),
              ));
        }
        // Sort descending by date in Dart
        final docs = (snap.data?.docs ?? [])
            .toList()
          ..sort((a, b) {
            final aTs = (a.data() as Map)['date'] as Timestamp?;
            final bTs = (b.data() as Map)['date'] as Timestamp?;
            if (aTs == null && bTs == null) return 0;
            if (aTs == null) return 1;
            if (bTs == null) return -1;
            return bTs.compareTo(aTs);
          });

        // Summary by category
        final Map<String, double> byCategory = {};
        for (final d in docs) {
          final data = d.data() as Map<String, dynamic>;
          final cat  = (data['category'] as String?) ?? 'Other';
          final amt  = ((data['amount'] as num?) ?? 0).toDouble();
          byCategory[cat] = (byCategory[cat] ?? 0) + amt;
        }
        final total = byCategory.values.fold(0.0, (s, v) => s + v);
        final fmt   = NumberFormat('##,##,##0', 'en_IN');

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Total summary card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [_kDark, _kPrimary]),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.account_balance_wallet_rounded,
                              color: Colors.white, size: 28),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('₹ ${fmt.format(total)}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800)),
                              Text('Total (all time)',
                                  style: TextStyle(
                                      color: Colors.white
                                          .withValues(alpha: 0.65),
                                      fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Category breakdown
                    if (byCategory.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      ...(byCategory.entries.toList()
                            ..sort((a, b) => b.value.compareTo(a.value)))
                          .map((e) => _CategoryBar(
                                category: e.key,
                                amount:   e.value,
                                total:    total,
                              )),
                    ],
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) {
                    final data = docs[i].data() as Map<String, dynamic>;
                    return _ExpenseTile(
                        data: data, docId: docs[i].id);
                  },
                  childCount: docs.length,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Salary Sheet Tab (shows ALL staff with PENDING default) ─────────────────
class _SalarySheetTab extends StatefulWidget {
  final String schoolId;
  const _SalarySheetTab({required this.schoolId});

  @override
  State<_SalarySheetTab> createState() => _SalarySheetTabState();
}

class _SalarySheetTabState extends State<_SalarySheetTab> {
  List<QueryDocumentSnapshot> _staffDocs       = [];
  Map<String, Map<String, dynamic>> _salaryMap = {}; // uid → this-month salary doc
  Map<String, double> _baseSalaryMap           = {}; // uid → base monthly salary
  StreamSubscription? _staffSub;
  StreamSubscription? _salarySub;
  StreamSubscription? _baseSalarySub;

  @override
  void initState() {
    super.initState();
    _setupStreams();
  }

  void _setupStreams() {
    final monthKey = DateFormat('yyyy-MM').format(DateTime.now());
    final db       = FirebaseFirestore.instance;

    _staffSub = db
        .collection(FSC.users)
        .where('schoolId', isEqualTo: widget.schoolId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .listen((snap) {
          setState(() {
            _staffDocs = snap.docs
                .where((d) {
                  final role = (d.data() as Map)['role'] as String?;
                  return !_kNonStaffRoles.contains(role);
                })
                .toList();
          });
        });

    _salarySub = db
        .collection(FSC.staffSalaries)
        .where('schoolId', isEqualTo: widget.schoolId)
        .where('month', isEqualTo: monthKey)
        .snapshots()
        .listen((snap) {
          final map = <String, Map<String, dynamic>>{};
          for (final d in snap.docs) {
            final type = (d.data()['type'] as String?) ?? 'salary';
            if (type != 'salary') continue; // skip 'other' payments
            final uid = (d.data()['uid'] as String?) ?? d.id;
            map[uid] = d.data();
          }
          setState(() => _salaryMap = map);
        });

    // Stream base salaries so we can show the correct pending amount for staff
    // who haven't had a salary record entered for this month yet.
    _baseSalarySub = db
        .collection(FSC.staffSalarySettings)
        .where('schoolId', isEqualTo: widget.schoolId)
        .snapshots()
        .listen((snap) {
          final map = <String, double>{};
          for (final d in snap.docs) {
            final uid  = (d.data()['uid'] as String?) ?? '';
            final base = ((d.data()['monthlySalary'] as num?) ?? 0).toDouble();
            if (uid.isNotEmpty) map[uid] = base;
          }
          setState(() => _baseSalaryMap = map);
        });
  }

  @override
  void dispose() {
    _staffSub?.cancel();
    _salarySub?.cancel();
    _baseSalarySub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fmt          = NumberFormat('##,##,##0', 'en_IN');
    double totalPaid   = 0;
    double totalPending = 0;

    for (final doc in _staffDocs) {
      final uid        = doc.id;
      final salData    = _salaryMap[uid];
      final baseAmount = _baseSalaryMap[uid] ?? 0;
      if (salData != null && salData['status'] == 'PAID') {
        final paid = ((salData['amount'] as num?) ?? 0).toDouble();
        totalPaid    += paid;
        totalPending += (baseAmount - paid).clamp(0, double.infinity);
      } else {
        final recordedAmount = ((salData?['amount'] as num?) ?? 0).toDouble();
        totalPending += recordedAmount > 0 ? recordedAmount : baseAmount;
      }
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _SalarySummaryCard(
                        label: 'Paid',
                        amount: totalPaid,
                        color: _kGreen,
                        icon: Icons.check_circle_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SalarySummaryCard(
                        label: 'Pending',
                        amount: totalPending,
                        color: _kAmber,
                        icon: Icons.pending_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  DateFormat('MMMM yyyy').format(DateTime.now()),
                  style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                ),
              ],
            ),
          ),
        ),
        if (_staffDocs.isEmpty)
          SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(Icons.people_outline_rounded,
                        size: 48, color: Colors.grey[300]),
                    const SizedBox(height: 12),
                    Text('No staff found',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.grey[400], fontSize: 13)),
                  ],
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) {
                  final doc     = _staffDocs[i];
                  final uid     = doc.id;
                  final data    = doc.data() as Map<String, dynamic>;
                  final salData   = _salaryMap[uid];
                  final name      = (data['name'] as String?) ?? 'Staff';
                  final paidAmt   = ((salData?['amount'] as num?) ?? 0).toDouble();
                  final baseAmt   = _baseSalaryMap[uid] ?? 0;
                  final rawStatus = salData != null
                      ? ((salData['status'] as String?) ?? 'PENDING')
                      : 'PENDING';
                  final notes     = (salData?['notes'] as String?) ?? '';
                  final remaining = rawStatus == 'PAID'
                      ? (baseAmt - paidAmt).clamp(0, double.infinity)
                      : 0.0;
                  final isPartial = rawStatus == 'PAID' && remaining > 0;
                  final isPaid    = rawStatus == 'PAID' && remaining == 0;
                  final color      = isPaid ? _kGreen : isPartial ? _kBlue : _kAmber;
                  final displayAmt = paidAmt > 0 ? paidAmt : baseAmt;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 6)
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isPaid
                                ? Icons.check_circle_rounded
                                : Icons.pending_rounded,
                            color: color, size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: _kNavy)),
                              if (isPartial)
                                Text(
                                  'Paid ₹${fmt.format(paidAmt)} · ₹${fmt.format(remaining)} remaining',
                                  style: TextStyle(fontSize: 10, color: _kBlue),
                                ),
                              if (notes.isNotEmpty)
                                Text(notes,
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[500])),
                              if (salData == null)
                                Text('No record — showing as Pending',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey[400])),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              displayAmt > 0
                                  ? '₹${fmt.format(displayAmt)}'
                                  : '—',
                              style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: displayAmt > 0 ? color : Colors.grey),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                isPaid ? 'PAID' : isPartial ? 'PARTIAL' : 'PENDING',
                                style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: color)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
                childCount: _staffDocs.length,
              ),
            ),
          ),
      ],
    );
  }
}

// ── Add Expense Sheet ───────────────────────────────────────────────────────
class _AddExpenseSheet extends StatefulWidget {
  final UserModel user;
  const _AddExpenseSheet({required this.user});

  @override
  State<_AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<_AddExpenseSheet> {
  final _titleCtrl  = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _notesCtrl  = TextEditingController();
  String   _category = 'Other';
  DateTime _date      = DateTime.now();
  bool     _isSaving  = false;
  String?  _error;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title  = _titleCtrl.text.trim();
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (title.isEmpty) {
      setState(() => _error = 'Enter a title for this expense');
      return;
    }
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Enter a valid amount');
      return;
    }
    setState(() { _isSaving = true; _error = null; });
    try {
      await FirebaseFirestore.instance.collection('expenses').add({
        'schoolId':    widget.user.schoolId,
        'title':       title,
        'description': title,   // also store as 'description' for website compatibility
        'amount':      amount,
        'category':    _category,
        'notes':       _notesCtrl.text.trim(),
        'addedBy':     widget.user.uid,
        'addedByUid':  widget.user.uid,   // also store as 'addedByUid' for cross-platform consistency
        'addedByName': widget.user.name,
        'date':        Timestamp.fromDate(_date),
        'createdAt':   Timestamp.now(),
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() { _isSaving = false; _error = 'Failed to save. Try again.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: _kPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.add_circle_outline_rounded,
                      color: _kPrimary, size: 20),
                ),
                const SizedBox(width: 12),
                const Text('Add Expense',
                    style:
                        TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleCtrl,
              textCapitalization: TextCapitalization.words,
              decoration:
                  _deco('Expense Title', Icons.label_outline_rounded),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: _deco('Amount (₹)', Icons.currency_rupee_rounded),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: _deco('Category', Icons.category_outlined),
              items: _kExpenseCategories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v ?? 'Other'),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2024),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _date = picked);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 18, color: Colors.grey[400]),
                    const SizedBox(width: 10),
                    Text(
                      DateFormat('d MMM yyyy').format(_date),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesCtrl,
              decoration: _deco('Notes (optional)', Icons.notes_rounded),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!,
                  style: const TextStyle(color: _kPrimary, fontSize: 12)),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPrimary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Add Expense',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _deco(String hint, IconData icon) => InputDecoration(
        hintText:  hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        prefixIcon: Icon(icon, size: 18, color: Colors.grey[400]),
        filled:    true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kPrimary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      );
}

// ═══════════════════════════════════════════════════════════════════════════
//  PROFILE TAB
// ═══════════════════════════════════════════════════════════════════════════
class _ProfileTab extends ConsumerWidget {
  final UserModel? user;
  const _ProfileTab({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (user == null) return const SizedBox.shrink();
    final hasChildren = ref.watch(hasLinkedStudentsProvider).value ?? false;
    final initials = user!.name.trim().split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kDark,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Text('Profile',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80, height: 80,
                    decoration: const BoxDecoration(
                      gradient:
                          LinearGradient(colors: [_kDark, _kPrimary]),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(initials,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 28)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(user!.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: _kNavy)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _kPrimary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Management',
                        style: TextStyle(
                            color: _kPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 12)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            _infoCard('Phone', user!.phone, Icons.phone_rounded),
            const SizedBox(height: 10),
            if (user!.email.isNotEmpty)
              _infoCard('Email', user!.email, Icons.email_rounded),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProfileScreen(user: user!),
                ),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: _kPrimary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _kPrimary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit_rounded, color: _kPrimary, size: 18),
                    const SizedBox(width: 8),
                    Text('Edit Profile',
                        style: TextStyle(
                            color: _kPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 15)),
                  ],
                ),
              ),
            ),
            if (hasChildren) ...[
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  ref.read(parentModeProvider.notifier).state = true;
                  context.go('/parent');
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: const Color(0xFFD97706)
                            .withValues(alpha: 0.4)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.swap_horiz_rounded,
                          color: Color(0xFFD97706), size: 18),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text('Switch to Parent View',
                            style: TextStyle(
                                color: Color(0xFFC2410C),
                                fontWeight: FontWeight.w700,
                                fontSize: 14)),
                      ),
                      Icon(Icons.chevron_right_rounded,
                          color: Color(0xFFD97706), size: 18),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () async {
                final router = GoRouter.of(context);
                ref.read(parentModeProvider.notifier).state = false;
                await NotificationService.signOut();
                router.go('/login');
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout_rounded,
                        color: Color(0xFFEF4444), size: 18),
                    SizedBox(width: 8),
                    Text('Sign Out',
                        style: TextStyle(
                            color: Color(0xFFEF4444),
                            fontWeight: FontWeight.w700,
                            fontSize: 15)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: _kPrimary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _kPrimary, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[400],
                      fontWeight: FontWeight.w600)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _kNavy)),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  SHARED WIDGETS
// ═══════════════════════════════════════════════════════════════════════════
class _ExpenseTile extends StatelessWidget {
  final Map<String, dynamic> data;
  final String? docId;
  const _ExpenseTile(
      {required this.data, this.docId});

  static const _catColors = {
    'Salaries':       Color(0xFFD97706),
    'Utilities':      Color(0xFF3B82F6),
    'Maintenance':    Color(0xFFF59E0B),
    'Supplies':       Color(0xFF059669),
    'Events':         Color(0xFFD97706),
    'Infrastructure': Color(0xFF065F46),
    'Transport':      Color(0xFFEC4899),
    'Other':          Color(0xFF6B7280),
  };

  @override
  Widget build(BuildContext context) {
    final title       = (data['title']       as String?) ?? 'Expense';
    final amount      = ((data['amount']     as num?)    ?? 0).toDouble();
    final category    = (data['category']    as String?) ?? 'Other';
    final date        = (data['date']        as Timestamp?)?.toDate();
    final addedByName = (data['addedByName'] as String?) ?? '';
    final color       = _catColors[category] ?? const Color(0xFF6B7280);
    final fmt         = NumberFormat('##,##,##0', 'en_IN');

    // For salary expenses, derive a human-readable label from the title
    // e.g. "Salary: Kruthika (Apr-2025)" → "Salary to Kruthika"
    String displayTitle = title;
    if (category == 'Salaries' && title.startsWith('Salary:')) {
      final inner = title.replaceFirst('Salary:', '').trim();
      final namePart = inner.contains('(') ? inner.substring(0, inner.indexOf('(')).trim() : inner;
      displayTitle = 'Salary to $namePart';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.receipt_outlined, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(displayTitle,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: _kNavy)),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(category,
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: color)),
                    ),
                    if (date != null) ...[
                      const SizedBox(width: 6),
                      Text(DateFormat('d MMM').format(date),
                          style: TextStyle(
                              fontSize: 10, color: Colors.grey[400])),
                    ],
                    if (addedByName.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Text('· $addedByName',
                          style: TextStyle(
                              fontSize: 10, color: Colors.grey[400])),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Text('₹${fmt.format(amount)}',
              style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: _kPrimary)),
        ],
      ),
    );
  }
}

class _CategoryBar extends StatelessWidget {
  final String category;
  final double amount;
  final double total;
  const _CategoryBar(
      {required this.category, required this.amount, required this.total});

  static const _catColors = {
    'Salaries':       Color(0xFFD97706),
    'Utilities':      Color(0xFF3B82F6),
    'Maintenance':    Color(0xFFF59E0B),
    'Supplies':       Color(0xFF059669),
    'Events':         Color(0xFFD97706),
    'Infrastructure': Color(0xFF065F46),
    'Transport':      Color(0xFFEC4899),
    'Other':          Color(0xFF6B7280),
  };

  @override
  Widget build(BuildContext context) {
    final pct   = total > 0 ? (amount / total) : 0.0;
    final color = _catColors[category] ?? const Color(0xFF6B7280);
    final fmt   = NumberFormat('##,##,##0', 'en_IN');
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 88,
            child: Text(category,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600])),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct,
                backgroundColor: color.withValues(alpha: 0.1),
                color: color,
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('₹${fmt.format(amount)}',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color)),
        ],
      ),
    );
  }
}

class _SalarySummaryCard extends StatelessWidget {
  final String  label;
  final double  amount;
  final Color   color;
  final IconData icon;
  const _SalarySummaryCard(
      {required this.label,
      required this.amount,
      required this.color,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('##,##,##0', 'en_IN');
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('₹${fmt.format(amount)}',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: color)),
                Text(label,
                    style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Fee Collection Tab (read-only fee overview for management) ────────────────
class _FeeCollectionTab extends ConsumerStatefulWidget {
  final String schoolId;
  const _FeeCollectionTab({required this.schoolId});

  @override
  ConsumerState<_FeeCollectionTab> createState() => _FeeCollectionTabState();
}

class _FeeCollectionTabState extends ConsumerState<_FeeCollectionTab>
    with SingleTickerProviderStateMixin {
  TabController? _tabCtrl;
  List<QueryDocumentSnapshot> _classDocs = [];
  bool _classesLoaded = false;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String? _statusFilter; // null=all, 'paid', 'pending'

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 1, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadClasses());
  }

  @override
  void dispose() {
    _tabCtrl?.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadClasses() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection(FSC.classes)
          .where('schoolId', isEqualTo: widget.schoolId)
          .get();
      if (!mounted) return;
      final docs = snap.docs.where((d) => (d.data() as Map)['isActive'] != false).toList();
      docs.sort((a, b) {
        final aName = ((a.data() as Map)['name'] as String?) ?? '';
        final bName = ((b.data() as Map)['name'] as String?) ?? '';
        return aName.compareTo(bName);
      });
      final oldCtrl = _tabCtrl;
      final newCtrl = TabController(length: docs.length + 1, vsync: this);
      setState(() {
        _classDocs = docs;
        _classesLoaded = true;
        _tabCtrl = newCtrl;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => oldCtrl?.dispose());
    } catch (e) {
      if (mounted) setState(() => _classesLoaded = true);
    }
  }

  String get _academicYear {
    final now = DateTime.now();
    final startYear = now.month >= 4 ? now.year : now.year - 1;
    return '$startYear-${(startYear + 1).toString().substring(2)}';
  }

  String _fmtAmt(double v) {
    if (v >= 100000) return '₹${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '₹${(v / 1000).toStringAsFixed(1)}K';
    return '₹${v.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    if (!_classesLoaded) {
      return const Center(child: CircularProgressIndicator(color: _kPrimary));
    }
    return Column(
      children: [
        // Search + filter bar
        Container(
          color: _kDark,
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search student...',
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
                    prefixIcon: const Icon(Icons.search, color: Colors.white70, size: 18),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close, color: Colors.white70, size: 16),
                            onPressed: () { _searchCtrl.clear(); setState(() => _searchQuery = ''); })
                        : null,
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.15),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    isDense: true,
                  ),
                ),
              ),
              TabBar(
                controller: _tabCtrl!,
                isScrollable: true,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white54,
                labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                tabs: [
                  const Tab(text: 'All'),
                  ..._classDocs.map((d) {
                    final data = d.data() as Map<String, dynamic>;
                    final name = (data['name'] as String?) ?? d.id;
                    final section = (data['section'] as String?) ?? '';
                    return Tab(text: section.isNotEmpty ? '$name-$section' : name);
                  }),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabCtrl!,
            children: [
              _FeeCollectionClassView(
                schoolId: widget.schoolId,
                classId: null,
                classDocs: _classDocs,
                academicYear: _academicYear,
                searchQuery: _searchQuery,
                statusFilter: _statusFilter,
                fmtAmt: _fmtAmt,
                onFilterTap: (f) => setState(() => _statusFilter = _statusFilter == f ? null : f),
              ),
              ..._classDocs.map((d) => _FeeCollectionClassView(
                schoolId: widget.schoolId,
                classId: d.id,
                classDocs: _classDocs,
                academicYear: _academicYear,
                searchQuery: _searchQuery,
                statusFilter: _statusFilter,
                fmtAmt: _fmtAmt,
                onFilterTap: (f) => setState(() => _statusFilter = _statusFilter == f ? null : f),
              )),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Fee Collection Class View ─────────────────────────────────────────────────
class _FeeCollectionClassView extends ConsumerWidget {
  final String schoolId;
  final String? classId;
  final List<QueryDocumentSnapshot> classDocs;
  final String academicYear;
  final String searchQuery;
  final String? statusFilter;
  final String Function(double) fmtAmt;
  final void Function(String) onFilterTap;

  const _FeeCollectionClassView({
    required this.schoolId,
    required this.classId,
    required this.classDocs,
    required this.academicYear,
    required this.searchQuery,
    required this.statusFilter,
    required this.fmtAmt,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = FirebaseFirestore.instance;
    return StreamBuilder<QuerySnapshot>(
      stream: classId != null
          ? db.collection(FSC.students).where('classId', isEqualTo: classId).where('isActive', isEqualTo: true).snapshots()
          : db.collection(FSC.students).where('schoolId', isEqualTo: schoolId).where('isActive', isEqualTo: true).snapshots(),
      builder: (ctx, studentSnap) {
        if (studentSnap.connectionState == ConnectionState.waiting && studentSnap.data == null) {
          return const Center(child: CircularProgressIndicator(color: _kPrimary));
        }
        return StreamBuilder<QuerySnapshot>(
          stream: db.collection(FSC.fees).where('schoolId', isEqualTo: schoolId).where('academicYear', isEqualTo: academicYear).snapshots(),
          builder: (ctx2, feeSnap) {
            final studentDocs = studentSnap.data?.docs ?? [];
            final feeDocs = feeSnap.data?.docs ?? [];
            final feeByStudent = <String, Map<String, dynamic>>{};
            for (final d in feeDocs) {
              final data = d.data() as Map<String, dynamic>;
              final sId = (data['studentId'] as String?) ?? '';
              if (sId.isNotEmpty) feeByStudent[sId] = data;
            }

            // Filter students
            var filtered = studentDocs.where((d) {
              if (searchQuery.isEmpty) return true;
              final data = d.data() as Map<String, dynamic>;
              final name = ((data['name'] as String?) ?? '').toLowerCase();
              final roll = ((data['rollNo'] as String?) ?? '').toLowerCase();
              final adm = ((data['admissionNo'] as String?) ?? '').toLowerCase();
              final q = searchQuery.toLowerCase();
              return name.contains(q) || roll.contains(q) || adm.contains(q);
            }).toList();

            if (statusFilter == 'paid') {
              filtered = filtered.where((d) {
                final f = feeByStudent[d.id];
                if (f == null) return false;
                final total = ((f['totalAmount'] as num?) ?? 0).toDouble();
                final paid = ((f['totalPaid'] as num?) ?? 0).toDouble();
                return total > 0 && paid >= total;
              }).toList();
            } else if (statusFilter == 'pending') {
              filtered = filtered.where((d) {
                final f = feeByStudent[d.id];
                if (f == null) return true;
                final pending = ((f['totalPending'] as num?) ?? 0).toDouble();
                return pending > 0;
              }).toList();
            }

            // Sort by pending desc
            filtered.sort((a, b) {
              final fa = feeByStudent[a.id];
              final fb = feeByStudent[b.id];
              final pendA = fa != null ? ((fa['totalPending'] as num?) ?? 0).toDouble() : double.infinity;
              final pendB = fb != null ? ((fb['totalPending'] as num?) ?? 0).toDouble() : double.infinity;
              return pendB.compareTo(pendA);
            });

            // Aggregate stats
            final studentIdSet = studentDocs.map((d) => d.id).toSet();
            double totalCollected = 0, totalPending = 0;
            for (final data in feeByStudent.values) {
              final sId = (data['studentId'] as String?) ?? '';
              if (classId == null || studentIdSet.contains(sId)) {
                totalCollected += ((data['totalPaid'] as num?) ?? 0).toDouble();
                totalPending += ((data['totalPending'] as num?) ?? 0).toDouble();
              }
            }

            return Column(
              children: [
                // Stats banner
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [_kDark, _kPrimary]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: GestureDetector(
                        onTap: () => onFilterTap('paid'),
                        child: _FeeStatItem(value: fmtAmt(totalCollected), label: 'Collected', valueColor: _kGreen, isActive: statusFilter == 'paid'),
                      )),
                      Container(width: 1, height: 44, color: Colors.white.withValues(alpha: 0.2)),
                      Expanded(child: GestureDetector(
                        onTap: () => onFilterTap('pending'),
                        child: _FeeStatItem(value: fmtAmt(totalPending), label: 'Pending', valueColor: _kAmber, isActive: statusFilter == 'pending'),
                      )),
                      Container(width: 1, height: 44, color: Colors.white.withValues(alpha: 0.2)),
                      Expanded(child: _FeeStatItem(value: '${studentDocs.length}', label: 'Students', valueColor: Colors.white70)),
                    ],
                  ),
                ),
                if (statusFilter != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(
                      children: [
                        Icon(Icons.filter_alt_rounded, size: 14,
                            color: statusFilter == 'paid' ? _kGreen : _kAmber),
                        const SizedBox(width: 4),
                        Text(
                          'Showing ${statusFilter == 'paid' ? 'fully paid' : 'pending'} only',
                          style: TextStyle(fontSize: 11, color: statusFilter == 'paid' ? _kGreen : _kAmber, fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => onFilterTap(statusFilter!),
                          style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0)),
                          child: const Text('Clear', style: TextStyle(fontSize: 11)),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.people_outline, size: 48, color: Colors.grey[300]),
                              const SizedBox(height: 8),
                              Text(
                                searchQuery.isNotEmpty ? 'No students match' : 'No students found',
                                style: TextStyle(color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          itemCount: filtered.length,
                          itemBuilder: (_, i) {
                            final doc = filtered[i];
                            final data = doc.data() as Map<String, dynamic>;
                            final name = (data['name'] as String?) ?? 'Student';
                            final roll = (data['rollNo'] as String?) ?? '';
                            final clsId = (data['classId'] as String?) ?? '';
                            final clsName = classDocs
                                .where((c) => c.id == clsId)
                                .map((c) {
                                  final cd = c.data() as Map<String, dynamic>;
                                  final n = (cd['name'] as String?) ?? '';
                                  final s = (cd['section'] as String?) ?? '';
                                  return s.isNotEmpty ? '$n-$s' : n;
                                })
                                .firstOrNull ?? '';
                            final fee = feeByStudent[doc.id];
                            final totalAmt = fee != null ? ((fee['totalAmount'] as num?) ?? 0).toDouble() : 0.0;
                            final totalPaid = fee != null ? ((fee['totalPaid'] as num?) ?? 0).toDouble() : 0.0;
                            final totalPend = fee != null ? ((fee['totalPending'] as num?) ?? 0).toDouble() : 0.0;
                            final isFullyPaid = totalAmt > 0 && totalPaid >= totalAmt;
                            final hasPartial = totalPaid > 0 && !isFullyPaid;
                            final statusColor = fee == null ? _kAmber : isFullyPaid ? _kGreen : hasPartial ? _kBlue : _kPrimary;
                            final statusLabel = fee == null ? 'Not Set' : isFullyPaid ? 'Fully Paid' : hasPartial ? 'Partial' : 'Pending';
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: statusColor.withValues(alpha: 0.2)),
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor: statusColor.withValues(alpha: 0.12),
                                    child: Text(
                                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                                      style: TextStyle(color: statusColor, fontWeight: FontWeight.w700, fontSize: 16),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF0A0F1E))),
                                        Text(
                                          '$clsName${roll.isNotEmpty ? " • Roll: $roll" : ""}',
                                          style: TextStyle(color: Colors.grey[500], fontSize: 11),
                                        ),
                                        if (fee != null) ...[
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Text('₹${totalPaid.toStringAsFixed(0)}', style: const TextStyle(color: _kGreen, fontWeight: FontWeight.w700, fontSize: 12)),
                                              Text(' / ₹${totalAmt.toStringAsFixed(0)}', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(3),
                                            child: LinearProgressIndicator(
                                              value: totalAmt > 0 ? (totalPaid / totalAmt).clamp(0.0, 1.0) : 0,
                                              backgroundColor: Colors.grey[200],
                                              color: statusColor,
                                              minHeight: 3,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: statusColor.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(statusLabel, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w700)),
                                      ),
                                      if (fee != null && totalPend > 0) ...[
                                        const SizedBox(height: 4),
                                        Text('₹${totalPend.toStringAsFixed(0)} due',
                                            style: const TextStyle(color: _kPrimary, fontSize: 11, fontWeight: FontWeight.w600)),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _FeeStatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;
  final bool isActive;
  const _FeeStatItem({required this.value, required this.label, required this.valueColor, this.isActive = false});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(value, style: TextStyle(color: valueColor, fontSize: 16, fontWeight: FontWeight.w800)),
      const SizedBox(height: 2),
      Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11)),
      if (isActive)
        Container(
          margin: const EdgeInsets.only(top: 4),
          width: 24, height: 2,
          decoration: BoxDecoration(color: valueColor, borderRadius: BorderRadius.circular(1)),
        ),
    ],
  );
}
