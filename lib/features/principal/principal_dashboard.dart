import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_constants.dart';
import '../../core/providers/core_providers.dart';
import '../../core/services/notification_service.dart';
import '../../core/models/user_model.dart';
import '../../core/models/announcement.dart';
import '../admin/screens/manage_classes_screen.dart';
import 'screens/create_announcement_screen.dart';
import 'screens/invite_staff_screen.dart';
import '../../core/models/lesson_plan.dart';
import 'screens/lesson_plans_screen.dart';
import 'screens/syllabus_covered_screen.dart';
import '../teacher/screens/edit_profile_screen.dart';
import '../teacher/screens/marks_results_screen.dart';
import 'package:intl/intl.dart';

class PrincipalDashboard extends ConsumerStatefulWidget {
  const PrincipalDashboard({super.key});

  @override
  ConsumerState<PrincipalDashboard> createState() =>
      _PrincipalDashboardState();
}

class _PrincipalDashboardState extends ConsumerState<PrincipalDashboard>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _fadeController;
  late Animation<double>    _fadeAnimation;

  // Stats
  int  _totalStudents  = 0;
  int  _totalClasses   = 0;
  int  _absentToday    = 0;
  int  _presentToday   = 0;
  int  _pendingStaffLeaves = 0;
  bool _statsLoading   = true;

  static const _blue = Color(0xFF3B82F6);
  static const _dark = Color(0xFF1D4ED8);

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
    _loadStats();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd   = todayStart.add(const Duration(days: 1));

    try {
      final aggregates = await Future.wait([
        FirebaseFirestore.instance
            .collection(FSC.students)
            .where('schoolId', isEqualTo: user.schoolId)
            .where('isActive', isEqualTo: true)
            .count()
            .get(),
        FirebaseFirestore.instance
            .collection(FSC.classes)
            .where('schoolId', isEqualTo: user.schoolId)
            .count()
            .get(),
        FirebaseFirestore.instance
            .collection(FSC.staffLeaves)
            .where('schoolId', isEqualTo: user.schoolId)
            .where('status', isEqualTo: 'PENDING')
            .count()
            .get(),
      ]);

      // Count absent/present students today across all attendance sessions
      int absentCount  = 0;
      int presentCount = 0;
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
          if (sessSnap.docs.isNotEmpty) {
            final data    = sessSnap.docs.first.data();
            final records = data['records'] as List<dynamic>? ?? [];
            absentCount  += records
                .where((r) =>
                    r['status'] == 'ABSENT' || r['status'] == 'LEAVE')
                .length;
            presentCount += records
                .where((r) => r['status'] == 'PRESENT')
                .length;
          }
        }
      } catch (_) {}

      if (mounted) {
        setState(() {
          _totalStudents      = aggregates[0].count ?? 0;
          _totalClasses       = aggregates[1].count ?? 0;
          _pendingStaffLeaves = aggregates[2].count ?? 0;
          _absentToday        = absentCount;
          _presentToday       = presentCount;
          _statsLoading       = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _statsLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).value;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: _buildBody(user),
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildBody(UserModel? user) {
    switch (_selectedIndex) {
      case 0:  return _buildHomeTab(user);
      case 1:  return const ManageClassesScreen();
      case 2:
        if (user == null) return const SizedBox.shrink();
        return const CreateAnnouncementScreen();
      case 3:  return _buildStaffTab(user);
      case 4:  return _buildProfileTab(user);
      default: return _buildHomeTab(user);
    }
  }

  BottomNavigationBar _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex:        _selectedIndex,
      onTap: (i) {
        setState(() => _selectedIndex = i);
        if (i == 0) _loadStats();
      },
      selectedItemColor:   _blue,
      unselectedItemColor: Colors.grey[400],
      backgroundColor:     Colors.white,
      elevation:           8,
      type:                BottomNavigationBarType.fixed,
      selectedLabelStyle:   const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(fontSize: 10),
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded), label: 'Home'),
        BottomNavigationBarItem(
            icon: Icon(Icons.class_rounded), label: 'Classes'),
        BottomNavigationBarItem(
            icon: Icon(Icons.campaign_rounded), label: 'Announce'),
        BottomNavigationBarItem(
            icon: Icon(Icons.people_rounded), label: 'Staff'),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded), label: 'Profile'),
      ],
    );
  }

  // ─── HOME TAB ───────────────────────────────────────────────────────────────

  Widget _buildHomeTab(UserModel? user) {
    return RefreshIndicator(
      onRefresh: _loadStats,
      color: _blue,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(user)),
          if (_pendingStaffLeaves > 0)
            SliverToBoxAdapter(child: _buildStaffLeavesBanner(user)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _sectionLabel('School Overview'),
                const SizedBox(height: 14),
                _buildStatsGrid(),
                const SizedBox(height: 24),
                _sectionLabel('Quick Actions'),
                const SizedBox(height: 12),
                _buildQuickActions(user),
                const SizedBox(height: 24),
                _buildRecentLessonPlans(user),
                const SizedBox(height: 24),
                _sectionLabel('Recent Announcements'),
                const SizedBox(height: 12),
                _buildRecentAnnouncements(user),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(UserModel? user) {
    final hour     = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good morning' : hour < 17 ? 'Good afternoon' : 'Good evening';
    final initials = user?.name.isNotEmpty == true
        ? user!.name.trim().split(' ').take(2).map((w) => w[0].toUpperCase()).join()
        : 'P';
    final now = DateTime.now();
    final dateStr = '${_weekday(now.weekday)}, ${_month(now.month)} ${now.day}';

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20, right: 20, bottom: 24,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F1F3D), Color(0xFF1D4ED8), Color(0xFF1E3A8A)],
          stops: [0.0, 0.6, 1.0],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D4ED8).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar with ring
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                  ),
                ),
                child: Center(
                  child: Text(initials,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(greeting,
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.6))),
                    Text(user?.name ?? 'Principal',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            color: Colors.white)),
                  ],
                ),
              ),
              // PRINCIPAL badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.stars_rounded,
                        color: Color(0xFFFBBF24), size: 13),
                    SizedBox(width: 4),
                    Text('PRINCIPAL',
                        style: TextStyle(
                            color: Color(0xFFFBBF24),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Date + quick stats strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded,
                    color: Colors.white70, size: 13),
                const SizedBox(width: 6),
                Text(dateStr,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
                const Spacer(),
                _miniStat(Icons.people_alt_rounded,
                    _statsLoading ? '—' : '$_totalStudents', 'Students'),
                const SizedBox(width: 16),
                _miniStat(Icons.class_rounded,
                    _statsLoading ? '—' : '$_totalClasses', 'Classes'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(IconData icon, String value, String label,
      {bool highlight = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value,
            style: TextStyle(
                color: highlight ? const Color(0xFFFBBF24) : Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                height: 1.0)),
        Text(label,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 8,
                fontWeight: FontWeight.w500)),
      ],
    );
  }

  String _weekday(int wd) {
    const days = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[wd.clamp(1, 7)];
  }

  String _month(int m) {
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                     'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[m.clamp(1, 12)];
  }

  Widget _sectionLabel(String title) => Text(title,
      style: const TextStyle(
          fontSize:   16,
          fontWeight: FontWeight.w700,
          color:      Color(0xFF0A0F1E)));

  Widget _buildStatsGrid() {
    final items = [
      _Stat('Students',      _statsLoading ? '—' : '$_totalStudents',  Icons.people_alt_rounded,    const Color(0xFF059669), const Color(0xFFECFDF5)),
      _Stat('Classes',       _statsLoading ? '—' : '$_totalClasses',   Icons.class_rounded,         _blue,                   const Color(0xFFEFF6FF)),
      _Stat('Present Today', _statsLoading ? '—' : '$_presentToday',   Icons.how_to_reg_rounded,    const Color(0xFF059669), const Color(0xFFECFDF5)),
      _Stat('Absent Today',  _statsLoading ? '—' : '$_absentToday',    Icons.person_off_rounded,    const Color(0xFFEF4444), const Color(0xFFFEF2F2)),
    ];

    final user = ref.read(currentUserProvider).value;

    return LayoutBuilder(
      builder: (ctx, constraints) {
        final cardW = (constraints.maxWidth - 12) / 2;
        return Column(
          children: [
            Row(children: [
              _statCard2(items[0], cardW,
                  onTap: () => _showStudentsSheet(user)),
              const SizedBox(width: 12),
              _statCard2(items[1], cardW,
                  onTap: () => setState(() => _selectedIndex = 1)),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              _statCard2(items[2], cardW,
                  onTap: () => _showPresentSheet(user)),
              const SizedBox(width: 12),
              _statCard2(items[3], cardW,
                  onTap: () => _showAbsentSheet(user)),
            ]),
          ],
        );
      },
    );
  }

  // ─── Staff Leaves Banner + tile in home ────────────────────────────────────
  Widget _buildStaffLeavesBanner(UserModel? user) {
    if (user == null || _pendingStaffLeaves == 0) return const SizedBox.shrink();
    return GestureDetector(
      onTap: () => _showStaffLeavesSheet(user),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _blue.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.badge_rounded, color: _blue, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '$_pendingStaffLeaves staff leave request${_pendingStaffLeaves > 1 ? 's' : ''} pending',
                style: const TextStyle(
                    fontSize:   13,
                    color:      Color(0xFF1E40AF),
                    fontWeight: FontWeight.w600),
              ),
            ),
            const Text('Review →',
                style: TextStyle(
                    fontSize:   12,
                    color:      _blue,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  void _showAbsentSheet(UserModel? user) {
    if (user == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AbsentStudentsSheet(schoolId: user.schoolId),
    );
  }

  void _showPresentSheet(UserModel? user) {
    if (user == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PresentStudentsSheet(schoolId: user.schoolId),
    );
  }

  void _showStudentsSheet(UserModel? user) {
    if (user == null) return;
    context.push('/principal/students');
  }

  void _showStaffLeavesSheet(UserModel? user) {
    if (user == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _StaffLeavesSheet(
        schoolId:    user.schoolId,
        principalUid: user.uid,
        onReviewed:  _loadStats,
      ),
    );
  }

  Widget _statCard2(_Stat s, double width, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: s.color.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: s.color.withValues(alpha: onTap != null ? 0.25 : 0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: s.bg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(s.icon, color: s.color, size: 19),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: s.color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  s.label,
                  style: TextStyle(
                    fontSize: 9,
                    color: s.color,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _statsLoading
              ? Container(
                  width: 50,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(6),
                  ),
                )
              : Text(
                  s.value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: s.color,
                    height: 1.0,
                  ),
                ),
          const SizedBox(height: 2),
          Text(
            'Total ${s.label.toLowerCase()}',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[400],
              fontWeight: FontWeight.w500,
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(height: 4),
            Icon(Icons.touch_app_outlined,
                size: 12, color: s.color.withValues(alpha: 0.5)),
          ],
        ],
      ),
    )); // closes GestureDetector
  }


  Widget _buildQuickActions(UserModel? user) {
    final actions = [
      _Action('Invite Staff',  Icons.group_add_rounded,     _blue,
          () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const InviteStaffScreen()))),
      _Action('Announce',      Icons.campaign_rounded,      const Color(0xFFD97706),
          () => context.push('/principal/create-announcement')),
      _Action('All Students',  Icons.people_outline_rounded, const Color(0xFFD97706),
          () => context.push('/principal/students')),
      _Action('Lesson Plans',  Icons.book_outlined,         _blue,
          () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LessonPlansScreen()))),
      _Action('Classes',       Icons.class_rounded,         _blue,
          () => setState(() => _selectedIndex = 1)),
      _Action('Syllabus',      Icons.library_books_rounded, const Color(0xFF059669),
          () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SyllabusCoveredScreen()))),
      _Action('Results',       Icons.bar_chart_rounded,     const Color(0xFFD97706),
          () {
            final u = ref.read(currentUserProvider).value;
            if (u == null) return;
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => MarksResultsScreen(schoolId: u.schoolId)));
          }),
    ];

    return LayoutBuilder(
      builder: (ctx, constraints) {
        final itemW = (constraints.maxWidth - 3 * 10) / 4; // 4 per row
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: actions.map((a) {
            return GestureDetector(
              onTap: a.onTap,
              child: Container(
                width: itemW,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: a.color.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: a.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(a.icon, color: a.color, size: 20),
                    ),
                    const SizedBox(height: 6),
                    Text(a.label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0A0F1E),
                            height: 1.2)),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildRecentLessonPlans(UserModel? user) {
    if (user == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)]),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.library_books_rounded, color: Colors.white, size: 14),
                  SizedBox(width: 5),
                  Text('Recent Lesson Plans',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                ],
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SyllabusCoveredScreen())),
              child: const Text('View all →',
                  style: TextStyle(fontSize: 12, color: _blue, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<LessonPlan>>(
          stream: ref.watch(firestoreServiceProvider).streamSchoolLessonPlans(user.schoolId),
          builder: (context, snap) {
            final plans = (snap.data ?? []).take(3).toList();
            if (plans.isEmpty) {
              return _emptyCard('No lesson plans yet', 'Teachers post lesson plans from their dashboard');
            }
            return Column(
              children: plans.map((p) => _lessonPlanTile(p)).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _lessonPlanTile(LessonPlan plan) {
    final dateStr = '${plan.date.day}/${plan.date.month}/${plan.date.year}';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6)],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: _blue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.menu_book_rounded, color: _blue, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                          color: _blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(5)),
                      child: Text(plan.subject,
                          style: const TextStyle(fontSize: 9, color: _blue, fontWeight: FontWeight.w700)),
                    ),
                    const Spacer(),
                    Text(dateStr, style: TextStyle(fontSize: 9, color: Colors.grey[400])),
                  ],
                ),
                const SizedBox(height: 4),
                Text(plan.topicsCovered,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0A0F1E)),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAnnouncements(UserModel? user) {
    if (user == null) {
      return _emptyCard(
          'No announcements yet', 'Tap Announce to post to staff or parents');
    }
    return StreamBuilder<List<Announcement>>(
      stream: ref
          .watch(firestoreServiceProvider)
          .streamSchoolAllAnnouncements(user.schoolId),
      builder: (context, snap) {
        if (snap.hasError || !snap.hasData) {
          return _emptyCard(
              'No announcements yet', 'Tap Announce to post to staff or parents');
        }
        final items = snap.data!.take(3).toList();
        if (items.isEmpty) {
          return _emptyCard(
              'No announcements yet', 'Tap Announce to post to staff or parents');
        }
        return Column(
          children: items.map(_announcementTile).toList(),
        );
      },
    );
  }

  Widget _announcementTile(Announcement a) {
    const audienceColors = {
      AnnouncementAudience.ALL:      Color(0xFF3B82F6),
      AnnouncementAudience.PARENTS:  Color(0xFFD97706),
      AnnouncementAudience.TEACHERS: Color(0xFF059669),
      AnnouncementAudience.CLASS:    Color(0xFFF59E0B),
    };
    const audienceLabels = {
      AnnouncementAudience.ALL:      'All',
      AnnouncementAudience.PARENTS:  'Parents',
      AnnouncementAudience.TEACHERS: 'Teachers',
      AnnouncementAudience.CLASS:    'Class',
    };
    final color = audienceColors[a.audience] ?? _blue;
    final label = audienceLabels[a.audience] ?? 'All';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color:      Colors.black.withValues(alpha: 0.04),
              blurRadius: 8)
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color:        color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.campaign_rounded, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(a.title,
                          style: const TextStyle(
                              fontSize:   13,
                              fontWeight: FontWeight.w700,
                              color:      Color(0xFF0A0F1E))),
                    ),
                    if (a.publishedAt != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        _timeAgo(a.publishedAt),
                        style: TextStyle(fontSize: 9, color: Colors.grey[400]),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(a.body,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(5)),
                      child: Text(label,
                          style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w700)),
                    ),
                    if (a.audience == AnnouncementAudience.CLASS &&
                        a.targetClassName.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded, size: 9, color: Colors.grey[400]),
                      const SizedBox(width: 2),
                      Flexible(child: Text(a.targetClassName,
                          style: TextStyle(fontSize: 9, color: Colors.grey[600],
                              fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis)),
                    ],
                    if (a.createdByName.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Flexible(child: Text('· ${a.createdByName}',
                          style: TextStyle(fontSize: 9, color: Colors.grey[400]),
                          overflow: TextOverflow.ellipsis)),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyCard(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Icon(Icons.inbox_rounded, size: 32, color: Colors.grey[300]),
          const SizedBox(height: 8),
          Text(title,
              style: TextStyle(
                  color:      Colors.grey[400],
                  fontSize:   13,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(subtitle,
              style: TextStyle(color: Colors.grey[300], fontSize: 11),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }



  String _timeAgo(DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 6)  return '${dt.day}/${dt.month}/${dt.year}';
    if (diff.inDays > 0)  return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  // ─── STAFF TAB ──────────────────────────────────────────────────────────────

  Widget _buildStaffTab(UserModel? user) {
    if (user == null) return const SizedBox.shrink();
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(
          children: [
            _tabHeader('Staff'),
            Expanded(
              child: StreamBuilder<List<UserModel>>(
                stream: ref
                    .watch(firestoreServiceProvider)
                    .streamSchoolStaff(user.schoolId),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child:
                            CircularProgressIndicator(color: _blue));
                  }
                  final staff = snap.data ?? [];
                  if (staff.isEmpty) return _emptyStaff();
                  return ListView.builder(
                    padding:
                        const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: staff.length,
                    itemBuilder: (_, i) => _staffCard(staff[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
                builder: (_) => const InviteStaffScreen())),
        backgroundColor: _blue,
        icon:  const Icon(Icons.group_add_rounded, color: Colors.white),
        label: const Text('Invite Staff',
            style: TextStyle(
                color:      Colors.white,
                fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _tabHeader(String title) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: const BoxDecoration(
        color:  Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize:   20,
                  fontWeight: FontWeight.w800,
                  color:      Color(0xFF0A0F1E))),
        ],
      ),
    );
  }

  Widget _emptyStaff() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
                color:  _blue.withValues(alpha: 0.1),
                shape:  BoxShape.circle),
            child: const Icon(Icons.people_outline_rounded,
                color: _blue, size: 32),
          ),
          const SizedBox(height: 16),
          const Text('No staff members yet',
              style: TextStyle(
                  fontSize:   18,
                  fontWeight: FontWeight.w700,
                  color:      Color(0xFF0A0F1E))),
          const SizedBox(height: 8),
          Text('Invite teachers and admins to get started',
              style: TextStyle(fontSize: 14, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _staffCard(UserModel staff) {
    final roleColors = {
      UserRole.ADMIN:         const Color(0xFF059669),
      UserRole.ADMINISTRATOR: const Color(0xFFD97706),
      UserRole.MANAGEMENT:    const Color(0xFF0EA5E9),
      UserRole.TEACHER:       const Color(0xFFF59E0B),
    };
    final roleBgs = {
      UserRole.ADMIN:         const Color(0xFFECFDF5),
      UserRole.ADMINISTRATOR: const Color(0xFFF3E8FF),
      UserRole.MANAGEMENT:    const Color(0xFFE0F2FE),
      UserRole.TEACHER:       const Color(0xFFFFFBEB),
    };
    final roleLabels = {
      UserRole.ADMIN:         'Admin',
      UserRole.ADMINISTRATOR: 'Administrator',
      UserRole.MANAGEMENT:    'Management',
      UserRole.TEACHER:       'Teacher',
    };
    final color     = roleColors[staff.role] ?? const Color(0xFFF59E0B);
    final bgColor   = roleBgs[staff.role]    ?? const Color(0xFFFFFBEB);
    final roleLabel = roleLabels[staff.role] ?? staff.role.name;
    final initials   = staff.name.isNotEmpty
        ? staff.name.trim().split(' ').take(2).map((w) => w[0].toUpperCase()).join()
        : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color:      Colors.black.withValues(alpha: 0.04),
              blurRadius: 8)
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color:        color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(initials,
                  style: TextStyle(
                      color:      color,
                      fontWeight: FontWeight.w800,
                      fontSize:   16)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(staff.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize:   14,
                        color:      Color(0xFF0A0F1E))),
                Text(staff.phone,
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey[500])),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: bgColor, borderRadius: BorderRadius.circular(8)),
            child: Text(roleLabel,
                style: TextStyle(
                    fontSize:   11,
                    color:      color,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ─── PROFILE TAB ────────────────────────────────────────────────────────────

  Widget _buildProfileTab(UserModel? user) {
    final hasChildren = ref.watch(hasLinkedStudentsProvider).value ?? false;
    final initials = user?.name.isNotEmpty == true
        ? user!.name.trim().split(' ').take(2).map((w) => w[0].toUpperCase()).join()
        : 'P';

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              width: 80, height: 80,
              decoration: const BoxDecoration(
                shape:    BoxShape.circle,
                gradient: LinearGradient(colors: [_dark, _blue]),
              ),
              child: Center(
                child: Text(initials,
                    style: const TextStyle(
                        color:      Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize:   28)),
              ),
            ),
            const SizedBox(height: 12),
            Text(user?.name ?? '—',
                style: const TextStyle(
                    fontSize:   20,
                    fontWeight: FontWeight.w800,
                    color:      Color(0xFF0A0F1E))),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color:        _blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('Principal',
                  style: TextStyle(
                      color:      _blue,
                      fontSize:   12,
                      fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 6),
            Text(user?.phone ?? '—',
                style: TextStyle(fontSize: 13, color: Colors.grey[500])),
            const SizedBox(height: 32),
            if (user != null)
              _profileOption(
                  Icons.edit_rounded, 'Edit Profile',
                  _blue, () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => EditProfileScreen(user: user)));
              }),
            const SizedBox(height: 10),
            _profileOption(
                Icons.group_add_rounded, 'Invite Staff',
                const Color(0xFF059669), () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const InviteStaffScreen()));
            }),
            const SizedBox(height: 10),
            _profileOption(
                Icons.campaign_rounded, 'Make Announcement',
                const Color(0xFFD97706),
                () => context.push('/principal/create-announcement')),
            const SizedBox(height: 10),
            _profileOption(
                Icons.people_outline_rounded, 'View All Students',
                const Color(0xFFD97706),
                () => context.push('/principal/students')),
            const SizedBox(height: 10),
            if (hasChildren) ...[
              _profileOption(
                  Icons.swap_horiz_rounded, 'Switch to Parent View',
                  const Color(0xFFD97706), () {
                ref.read(parentModeProvider.notifier).state = true;
                context.go('/parent');
              }),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () async {
                final router = GoRouter.of(context);
                ref.read(parentModeProvider.notifier).state = false;
                await NotificationService.signOut();
                router.go('/login');
              },
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color:        const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: const Color(0xFFEF4444)
                          .withValues(alpha: 0.3)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout_rounded,
                        color: Color(0xFFEF4444), size: 18),
                    SizedBox(width: 8),
                    Text('Sign Out',
                        style: TextStyle(
                            color:      Color(0xFFEF4444),
                            fontWeight: FontWeight.w600,
                            fontSize:   15)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileOption(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color:      Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset:     const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color:        color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize:   14,
                      fontWeight: FontWeight.w600,
                      color:      Color(0xFF0A0F1E))),
            ),
            Icon(Icons.chevron_right_rounded,
                color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }
}

// ─── Private data classes ────────────────────────────────────────────────────

class _Stat {
  final String label, value;
  final IconData icon;
  final Color color, bg;
  const _Stat(this.label, this.value, this.icon, this.color, this.bg);
}

class _Action {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _Action(this.label, this.icon, this.color, this.onTap);
}

class _StaffApplyLeaveScreen extends ConsumerStatefulWidget {
  const _StaffApplyLeaveScreen();

  @override
  ConsumerState<_StaffApplyLeaveScreen> createState() =>
      _StaffApplyLeaveScreenState();
}

class _StaffApplyLeaveScreenState
    extends ConsumerState<_StaffApplyLeaveScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _reasonCtrl = TextEditingController();

  DateTime _fromDate  = DateTime.now();
  DateTime _toDate    = DateTime.now();
  String   _leaveType = 'casual';
  bool     _submitting = false;

  static const _kP = Color(0xFF1D4ED8);
  static const _kD = Color(0xFF0F1F3D);

  static const _leaveTypes = [
    ('sick',     'Sick Leave',     Icons.local_hospital_outlined),
    ('casual',   'Casual Leave',   Icons.beach_access_outlined),
    ('personal', 'Personal Leave', Icons.person_outline),
    ('other',    'Other',          Icons.more_horiz_rounded),
  ];

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final initial = isFrom ? _fromDate : _toDate;
    final first   = isFrom ? DateTime.now() : _fromDate;
    final picked  = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate:   first,
      lastDate:    DateTime.now().add(const Duration(days: 90)),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: _kP),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isFrom) {
        _fromDate = picked;
        if (_toDate.isBefore(_fromDate)) _toDate = _fromDate;
      } else {
        _toDate = picked;
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final user = ref.read(currentUserProvider).value;
      if (user == null) throw Exception('Not logged in');
      final fs = ref.read(firestoreServiceProvider);

      await fs.createStaffLeave({
        'schoolId':  user.schoolId,
        'staffUid':  user.uid,
        'staffName': user.name,
        'staffRole': user.role.name,
        'fromDate':  Timestamp.fromDate(
            DateTime(_fromDate.year, _fromDate.month, _fromDate.day)),
        'toDate':    Timestamp.fromDate(
            DateTime(_toDate.year, _toDate.month, _toDate.day)),
        'reason':    _reasonCtrl.text.trim(),
        'leaveType': _leaveType,
        'status':    'PENDING',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Leave application submitted'),
            backgroundColor: _kP,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'),
              backgroundColor: const Color(0xFFEF4444)));
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dayDiff = _toDate.difference(_fromDate).inDays + 1;
    final fmt     = DateFormat('d MMM yyyy');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: _kD,
        foregroundColor: Colors.white,
        title: const Text('Apply for Leave',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient:
                      const LinearGradient(colors: [_kD, _kP]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month_rounded,
                        color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$dayDiff day${dayDiff > 1 ? 's' : ''} leave',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800),
                        ),
                        Text(
                          '${fmt.format(_fromDate)} → ${fmt.format(_toDate)}',
                          style: TextStyle(
                              color:
                                  Colors.white.withValues(alpha: 0.8),
                              fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text('Leave Type',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _leaveTypes.map((t) {
                  final selected = _leaveType == t.$1;
                  return GestureDetector(
                    onTap: () => setState(() => _leaveType = t.$1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? _kP : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: selected
                                ? _kP
                                : Colors.grey[300]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(t.$3,
                              size: 16,
                              color: selected
                                  ? Colors.white
                                  : Colors.grey[600]),
                          const SizedBox(width: 6),
                          Text(t.$2,
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: selected
                                      ? Colors.white
                                      : Colors.grey[700])),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              const Text('Date Range',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _pickDate(isFrom: true),
                      child: _dateTile('From', _fromDate, _kP),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _pickDate(isFrom: false),
                      child: _dateTile('To', _toDate, _kP),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Reason',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              TextFormField(
                controller: _reasonCtrl,
                maxLines: 4,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Please enter a reason'
                    : null,
                decoration: InputDecoration(
                  hintText: 'Describe the reason for leave...',
                  hintStyle:
                      TextStyle(color: Colors.grey[400], fontSize: 13),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: _kP, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kP,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _submitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white))
                      : const Text('Submit Leave Application',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dateTile(String label, DateTime date, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today_outlined, size: 16, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w600)),
              Text(DateFormat('d MMM yyyy').format(date),
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Staff Leaves Bottom Sheet ────────────────────────────────────────────────

class _StaffLeavesSheet extends ConsumerWidget {
  final String schoolId;
  final String principalUid;
  final VoidCallback onReviewed;

  const _StaffLeavesSheet({
    required this.schoolId,
    required this.principalUid,
    required this.onReviewed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fs = ref.watch(firestoreServiceProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize:     0.95,
      minChildSize:     0.4,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Text('Staff Leave Requests',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: fs.streamStaffLeavesForSchool(schoolId),
                builder: (ctx, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFF3B82F6)));
                  }
                  final leaves = snap.data ?? [];
                  if (leaves.isEmpty) {
                    return const Center(
                      child: Text('No staff leave requests',
                          style: TextStyle(color: Colors.grey)),
                    );
                  }
                  return ListView.builder(
                    controller: ctrl,
                    padding: const EdgeInsets.all(16),
                    itemCount: leaves.length,
                    itemBuilder: (_, i) => _StaffLeaveCard(
                      data:         leaves[i],
                      principalUid: principalUid,
                      onAction: () {
                        onReviewed();
                        Navigator.of(context).pop();
                      },
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
}

class _StaffLeaveCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> data;
  final String principalUid;
  final VoidCallback onAction;

  const _StaffLeaveCard({
    required this.data,
    required this.principalUid,
    required this.onAction,
  });

  @override
  ConsumerState<_StaffLeaveCard> createState() => _StaffLeaveCardState();
}

class _StaffLeaveCardState extends ConsumerState<_StaffLeaveCard> {
  bool _acting = false;

  static const _blue = Color(0xFF3B82F6);
  static const _red  = Color(0xFFEF4444);

  Future<void> _review(String status) async {
    setState(() => _acting = true);
    try {
      final fs = ref.read(firestoreServiceProvider);
      await fs.reviewStaffLeave(
        widget.data['leaveId'] as String,
        status,
        widget.principalUid,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(status == 'APPROVED'
              ? 'Leave approved'
              : 'Leave rejected'),
          backgroundColor: status == 'APPROVED' ? _blue : _red,
        ));
        widget.onAction();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'),
                backgroundColor: _red));
        setState(() => _acting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final d          = widget.data;
    final staffName  = d['staffName'] as String? ?? 'Staff';
    final staffRole  = d['staffRole'] as String? ?? '';
    final leaveType  = d['leaveType'] as String? ?? '';
    final reason     = d['reason'] as String? ?? '';
    final status     = d['status'] as String? ?? 'PENDING';
    final fromTs     = d['fromDate'] as Timestamp?;
    final toTs       = d['toDate']   as Timestamp?;
    final fmt        = DateFormat('d MMM');

    final fromStr = fromTs != null ? fmt.format(fromTs.toDate()) : '—';
    final toStr   = toTs   != null ? fmt.format(toTs.toDate())   : '—';

    final statusColor = status == 'APPROVED'
        ? const Color(0xFF059669)
        : status == 'REJECTED'
            ? _red
            : const Color(0xFFF59E0B);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: _blue.withValues(alpha: 0.1),
                child: Text(
                  staffName.isNotEmpty ? staffName[0].toUpperCase() : 'S',
                  style: const TextStyle(
                      color: _blue, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(staffName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14)),
                    Text(staffRole,
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey[500])),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(status,
                    style: TextStyle(
                        fontSize: 10,
                        color: statusColor,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.date_range_outlined,
                  size: 14, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text('$fromStr → $toStr',
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey[600])),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(leaveType,
                    style: TextStyle(
                        fontSize: 10, color: Colors.grey[700])),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(reason,
              style: const TextStyle(fontSize: 12, height: 1.4),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          if (status == 'PENDING') ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _acting
                        ? null
                        : () => _review('REJECTED'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _red,
                      side: const BorderSide(color: _red),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Reject',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _acting
                        ? null
                        : () => _review('APPROVED'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: const Text('Approve',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Absent Students Bottom Sheet ────────────────────────────────────────────

// ─── Present students sheet ──────────────────────────────────────────────────
class _PresentStudentsSheet extends StatefulWidget {
  final String schoolId;
  const _PresentStudentsSheet({required this.schoolId});

  @override
  State<_PresentStudentsSheet> createState() => _PresentStudentsSheetState();
}

class _PresentStudentsSheetState extends State<_PresentStudentsSheet> {
  List<Map<String, dynamic>> _allRows = [];
  bool _loading = true;
  final _searchCtrl = TextEditingController();
  String _query = '';
  String? _classFilter;
  final _classNames = <String, String>{};

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(
        () => setState(() => _query = _searchCtrl.text.toLowerCase()));
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
      final today      = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      final todayEnd   = todayStart.add(const Duration(days: 1));
      final db         = FirebaseFirestore.instance;

      final classSnap = await db
          .collection(FSC.classes)
          .where('schoolId', isEqualTo: widget.schoolId)
          .get();

      final classNames = <String, String>{};
      for (final doc in classSnap.docs) {
        classNames[doc.id] = doc.data()['name'] as String? ?? doc.id;
      }

      final rows = <Map<String, dynamic>>[];

      for (final classDoc in classSnap.docs) {
        final sessSnap = await db
            .collection(FSC.attendance)
            .doc(classDoc.id)
            .collection(FSC.sessions)
            .where('date',
                isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart),
                isLessThan: Timestamp.fromDate(todayEnd))
            .limit(1)
            .get();
        if (sessSnap.docs.isEmpty) continue;

        final data      = sessSnap.docs.first.data();
        final records   = data['records'] as List<dynamic>? ?? [];
        final className = classNames[classDoc.id] ?? classDoc.id;

        for (final r in records) {
          if ((r['status'] as String? ?? '') == 'PRESENT') {
            rows.add({
              'studentId': r['studentId'] as String? ?? '',
              'name':      '—',
              'className': className,
              'classId':   classDoc.id,
            });
          }
        }
      }

      // Batch-fetch student names
      final uniqueIds = rows
          .map((r) => r['studentId'] as String)
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();
      final nameMap = <String, String>{};
      for (int i = 0; i < uniqueIds.length; i += 30) {
        final batch = uniqueIds.skip(i).take(30).toList();
        final snap = await db
            .collection(FSC.students)
            .where(FieldPath.documentId, whereIn: batch)
            .get();
        for (final doc in snap.docs) {
          nameMap[doc.id] = doc.data()['name'] as String? ?? '—';
        }
      }
      for (final row in rows) {
        final sid = row['studentId'] as String;
        if (nameMap.containsKey(sid)) row['name'] = nameMap[sid];
      }

      if (mounted) {
        setState(() {
          _allRows = rows;
          _classNames
            ..clear()
            ..addAll(classNames);
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> get _filtered {
    return _allRows.where((s) {
      final matchClass =
          _classFilter == null || s['classId'] == _classFilter;
      final name = (s['name'] as String).toLowerCase();
      final cls  = (s['className'] as String).toLowerCase();
      final matchSearch =
          _query.isEmpty || name.contains(_query) || cls.contains(_query);
      return matchClass && matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    const green    = Color(0xFF059669);
    final filtered = _filtered;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize:     0.95,
      minChildSize:     0.4,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  const Text('Present Students Today',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  if (!_loading)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: green.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${filtered.length} present',
                        style: const TextStyle(
                            fontSize: 12,
                            color: green,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            if (!_loading) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 38,
                        child: TextField(
                          controller: _searchCtrl,
                          style: const TextStyle(fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Search student or class…',
                            hintStyle: TextStyle(
                                fontSize: 12, color: Colors.grey[400]),
                            prefixIcon:
                                const Icon(Icons.search, size: 18),
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 0),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    color: Colors.grey[300]!)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    color: Colors.grey[300]!)),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                        ),
                      ),
                    ),
                    if (_classNames.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 38,
                        child: DropdownButtonHideUnderline(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: Colors.grey[300]!),
                            ),
                            child: DropdownButton<String?>(
                              value: _classFilter,
                              hint: const Text('All classes',
                                  style: TextStyle(fontSize: 12)),
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF0A0F1E)),
                              items: [
                                const DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text('All classes',
                                      style:
                                          TextStyle(fontSize: 12)),
                                ),
                                ..._classNames.entries.map((e) =>
                                    DropdownMenuItem<String?>(
                                      value: e.key,
                                      child: Text(e.value,
                                          style: const TextStyle(
                                              fontSize: 12)),
                                    )),
                              ],
                              onChanged: (v) =>
                                  setState(() => _classFilter = v),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            const Divider(height: 1),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: green))
                  : filtered.isEmpty
                      ? Center(
                          child: Text(
                            _allRows.isEmpty
                                ? 'No attendance recorded today'
                                : 'No results',
                            style:
                                const TextStyle(color: Colors.grey),
                          ))
                      : ListView.builder(
                          controller: ctrl,
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          itemBuilder: (_, i) {
                            final s   = filtered[i];
                            final name = s['name'] as String;
                            final cls  = s['className'] as String;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(10),
                                border: Border.all(
                                    color: Colors.grey[200]!),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36, height: 36,
                                    decoration: BoxDecoration(
                                      color: green
                                          .withValues(alpha: 0.1),
                                      borderRadius:
                                          BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                        Icons.how_to_reg_rounded,
                                        size: 16,
                                        color: green),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(name,
                                            style: const TextStyle(
                                                fontWeight:
                                                    FontWeight.w600,
                                                fontSize: 13)),
                                        Text(cls,
                                            style: TextStyle(
                                                fontSize: 11,
                                                color:
                                                    Colors.grey[500])),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: green
                                          .withValues(alpha: 0.1),
                                      borderRadius:
                                          BorderRadius.circular(4),
                                    ),
                                    child: const Text('PRESENT',
                                        style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            color: green)),
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
}

// ─── Absent students sheet ───────────────────────────────────────────────────
class _AbsentStudentsSheet extends ConsumerStatefulWidget {
  final String schoolId;
  const _AbsentStudentsSheet({required this.schoolId});

  @override
  ConsumerState<_AbsentStudentsSheet> createState() =>
      _AbsentStudentsSheetState();
}

class _AbsentStudentsSheetState
    extends ConsumerState<_AbsentStudentsSheet> {
  List<Map<String, dynamic>> _allRows = [];
  bool _loading = true;
  final _searchCtrl = TextEditingController();
  String _query = '';
  String? _classFilter;
  final _classNames = <String, String>{};

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(
        () => setState(() => _query = _searchCtrl.text.toLowerCase()));
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
      final today      = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      final todayEnd   = todayStart.add(const Duration(days: 1));
      final db         = FirebaseFirestore.instance;

      final classSnap = await db
          .collection(FSC.classes)
          .where('schoolId', isEqualTo: widget.schoolId)
          .get();

      final classNames = <String, String>{};
      for (final doc in classSnap.docs) {
        classNames[doc.id] = doc.data()['name'] as String? ?? doc.id;
      }

      final rows = <Map<String, dynamic>>[];

      for (final classDoc in classSnap.docs) {
        final sessSnap = await db
            .collection(FSC.attendance)
            .doc(classDoc.id)
            .collection(FSC.sessions)
            .where('date',
                isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart),
                isLessThan: Timestamp.fromDate(todayEnd))
            .limit(1)
            .get();
        if (sessSnap.docs.isEmpty) continue;

        final data      = sessSnap.docs.first.data();
        final records   = data['records'] as List<dynamic>? ?? [];
        final className = classNames[classDoc.id] ?? classDoc.id;

        for (final r in records) {
          final status = r['status'] as String? ?? '';
          if (status == 'ABSENT' || status == 'LEAVE') {
            rows.add({
              'studentId': r['studentId'] as String? ?? '',
              'name':      '—',
              'status':    status,
              'className': className,
              'classId':   classDoc.id,
            });
          }
        }
      }

      // Batch-fetch student names
      final uniqueIds = rows
          .map((r) => r['studentId'] as String)
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();
      final nameMap = <String, String>{};
      for (int i = 0; i < uniqueIds.length; i += 30) {
        final batch = uniqueIds.skip(i).take(30).toList();
        final snap = await db
            .collection(FSC.students)
            .where(FieldPath.documentId, whereIn: batch)
            .get();
        for (final doc in snap.docs) {
          nameMap[doc.id] = doc.data()['name'] as String? ?? '—';
        }
      }
      for (final row in rows) {
        final sid = row['studentId'] as String;
        if (nameMap.containsKey(sid)) row['name'] = nameMap[sid];
      }

      if (mounted) {
        setState(() {
          _allRows = rows;
          _classNames
            ..clear()
            ..addAll(classNames);
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> get _filtered {
    return _allRows.where((s) {
      final matchClass =
          _classFilter == null || s['classId'] == _classFilter;
      final name = (s['name'] as String).toLowerCase();
      final cls  = (s['className'] as String).toLowerCase();
      final matchSearch =
          _query.isEmpty || name.contains(_query) || cls.contains(_query);
      return matchClass && matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize:     0.95,
      minChildSize:     0.4,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  const Text('Absent Students Today',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  if (!_loading)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${filtered.length} absent',
                        style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFEF4444),
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // Search + class filter
            if (!_loading) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 38,
                        child: TextField(
                          controller: _searchCtrl,
                          style: const TextStyle(fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Search student or class…',
                            hintStyle: TextStyle(
                                fontSize: 12, color: Colors.grey[400]),
                            prefixIcon: const Icon(Icons.search, size: 18),
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 0),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!)),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                        ),
                      ),
                    ),
                    if (_classNames.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 38,
                        child: DropdownButtonHideUnderline(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: DropdownButton<String?>(
                              value: _classFilter,
                              hint: const Text('All classes',
                                  style: TextStyle(fontSize: 12)),
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF0A0F1E)),
                              items: [
                                const DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text('All classes',
                                      style: TextStyle(fontSize: 12)),
                                ),
                                ..._classNames.entries.map((e) =>
                                    DropdownMenuItem<String?>(
                                      value: e.key,
                                      child: Text(e.value,
                                          style: const TextStyle(
                                              fontSize: 12)),
                                    )),
                              ],
                              onChanged: (v) =>
                                  setState(() => _classFilter = v),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            const Divider(height: 1),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFFEF4444)))
                  : filtered.isEmpty
                      ? Center(
                          child: Text(
                            _allRows.isEmpty
                                ? 'No absent students today'
                                : 'No results',
                            style: const TextStyle(color: Colors.grey),
                          ))
                      : ListView.builder(
                          controller: ctrl,
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          itemBuilder: (_, i) {
                            final s       = filtered[i];
                            final name    = s['name'] as String;
                            final status  = s['status'] as String;
                            final cls     = s['className'] as String;
                            final isLeave = status == 'LEAVE';
                            final color   = isLeave
                                ? const Color(0xFF3B82F6)
                                : const Color(0xFFEF4444);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey[200]!),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36, height: 36,
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.1),
                                      borderRadius:
                                          BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      isLeave
                                          ? Icons.event_busy_rounded
                                          : Icons.person_off_rounded,
                                      size: 16,
                                      color: color,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(name,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13)),
                                        Text(cls,
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey[500])),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(status,
                                        style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            color: color)),
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
}
