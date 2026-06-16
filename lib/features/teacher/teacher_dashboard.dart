import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_constants.dart';
import '../../core/providers/core_providers.dart';
import '../../core/services/notification_service.dart';
import '../../core/models/class_model.dart';
import '../../core/models/leave_request.dart';
// import '../../core/models/special_request.dart';
import '../../core/models/announcement.dart';
import '../../core/models/attendance.dart';
import 'screens/mark_attendance_screen.dart';
import 'screens/leave_requests_screen.dart';
import 'screens/early_pickup_screen.dart';
import 'screens/post_lesson_plan_screen.dart';
import 'screens/my_lesson_plans_screen.dart';
import 'screens/study_materials_screen.dart';
import 'screens/marks_hub_screen.dart';
import 'screens/marks_results_screen.dart';
import 'screens/class_timetable_screen.dart';
import 'screens/class_announcement_screen.dart';
import 'screens/student_detail_screen.dart';
import 'screens/all_announcements_screen.dart';
import 'screens/edit_profile_screen.dart';

// ── Theme constants — Forest Green + Saffron ──────────────────
const _kPrimary    = Color(0xFF065F46);
const _kDark       = Color(0xFF022C22);
const _kHeaderBg   = Color(0xFF065F46);
const _kBg         = Color(0xFFF0FDF4);
const _kCard       = Colors.white;
const _kOrange     = Color(0xFFD97706);
const _kAmber      = Color(0xFFF59E0B);
const _kRed        = Color(0xFFEF4444);
const _kBlue       = Color(0xFF0284C7);

class TeacherDashboard extends ConsumerStatefulWidget {
  const TeacherDashboard({super.key});

  @override
  ConsumerState<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends ConsumerState<TeacherDashboard>
    with TickerProviderStateMixin {
  int _tab = 0;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  // Search state
  final _searchCtrl = TextEditingController();
  bool _searchActive = false;
  List<Map<String, dynamic>> _searchResults = [];
  bool _searchLoading = false;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    setState(() {
      _tab = index;
      _searchActive = false;
    });
    _fadeCtrl
      ..reset()
      ..forward();
  }

  Future<void> _performSearch(String query, String schoolId) async {
    if (query.trim().length < 2) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _searchLoading = true);
    try {
      final fs = ref.read(firestoreServiceProvider);
      final students = await fs.streamSchoolStudents(schoolId).first;
      final q = query.toLowerCase();
      setState(() {
        _searchResults = students
            .where((s) =>
                s.name.toLowerCase().contains(q) ||
                s.rollNo.toLowerCase().contains(q) ||
                s.admissionNo.toLowerCase().contains(q))
            .map((s) => {
                  'studentId': s.studentId,
                  'name': s.name,
                  'classId': s.classId,
                  'rollNo': s.rollNo,
                  'photoUrl': s.photoUrl,
                })
            .toList();
        _searchLoading = false;
      });
    } catch (_) {
      setState(() => _searchLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      loading: () => const Scaffold(
        backgroundColor: _kHeaderBg,
        body: Center(child: CircularProgressIndicator(color: _kPrimary)),
      ),
      error: (_, __) => const Scaffold(body: Center(child: Text('Error'))),
      data: (user) {
        if (user == null) {
          return const Scaffold(body: Center(child: Text('Not logged in')));
        }
        return Scaffold(
          backgroundColor: _kBg,
          body: FadeTransition(
            opacity: _fadeAnim,
            child: _buildBody(user),
          ),
          bottomNavigationBar: _buildBottomNav(),
        );
      },
    );
  }

  Widget _buildBody(dynamic user) {
    switch (_tab) {
      case 0:
        return _HomeTab(
          user: user,
          searchCtrl: _searchCtrl,
          searchActive: _searchActive,
          searchResults: _searchResults,
          searchLoading: _searchLoading,
          onSearchChanged: (q) {
            setState(() => _searchActive = q.isNotEmpty);
            _performSearch(q, user.schoolId);
          },
          onSearchClear: () {
            setState(() {
              _searchActive = false;
              _searchResults = [];
              _searchCtrl.clear();
            });
          },
          onNavToAttendance: () => _onNavTap(1),
          onNavToRequests: () => _onNavTap(3),
        );
      case 1:
        return _AttendanceTab(user: user);
      case 2:
        return _ClassesTab(user: user);
      case 3:
        return _RequestsTab(user: user);
      case 4:
        return _ProfileTab(user: user);
      default:
        return const SizedBox();
    }
  }

  Widget _buildBottomNav() {
    // Pattern D — top border accent on selected tab
    final tabs = [
      {'icon': Icons.home_outlined, 'selectedIcon': Icons.home, 'label': 'Home'},
      {'icon': Icons.how_to_reg_outlined, 'selectedIcon': Icons.how_to_reg, 'label': 'Attendance'},
      {'icon': Icons.class_outlined, 'selectedIcon': Icons.class_, 'label': 'Classes'},
      {'icon': Icons.pending_actions_outlined, 'selectedIcon': Icons.pending_actions, 'label': 'Requests'},
      {'icon': Icons.person_outline, 'selectedIcon': Icons.person, 'label': 'Profile'},
    ];
    return Container(
      decoration: BoxDecoration(
        color: _kCard,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            children: tabs.asMap().entries.map((e) {
              final i = e.key;
              final t = e.value;
              final sel = _tab == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => _onNavTap(i),
                  child: Container(
                    decoration: BoxDecoration(
                      border: sel
                          ? const Border(top: BorderSide(color: _kPrimary, width: 3))
                          : const Border(top: BorderSide(color: Colors.transparent, width: 3)),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          sel ? t['selectedIcon'] as IconData : t['icon'] as IconData,
                          color: sel ? _kPrimary : Colors.grey.shade400,
                          size: 22,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          t['label'] as String,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                            color: sel ? _kPrimary : Colors.grey.shade400,
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

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  HOME TAB
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _HomeTab extends ConsumerStatefulWidget {
  final dynamic user;
  final TextEditingController searchCtrl;
  final bool searchActive;
  final List<Map<String, dynamic>> searchResults;
  final bool searchLoading;
  final void Function(String) onSearchChanged;
  final VoidCallback onSearchClear;
  final VoidCallback onNavToAttendance;
  final VoidCallback onNavToRequests;

  const _HomeTab({
    required this.user,
    required this.searchCtrl,
    required this.searchActive,
    required this.searchResults,
    required this.searchLoading,
    required this.onSearchChanged,
    required this.onSearchClear,
    required this.onNavToAttendance,
    required this.onNavToRequests,
  });

  @override
  ConsumerState<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<_HomeTab> {
  int _classCount = 0;
  int _studentCount = 0;
  int _pendingLeaves = 0;
  int _pendingPickups = 0;

  // Attendance stats for selected date
  DateTime _selectedDate = DateTime.now();
  DateTime? _lastLoadDate;
  int _presentCount = 0;
  int _absentCount = 0;
  List<Map<String, dynamic>> _absentList = [];
  bool _attendanceLoading = false;

  // Live class + student subscriptions (keeps counts reactive to server changes)
  StreamSubscription<List<ClassModel>>? _classesSub;
  final Map<String, StreamSubscription<List<dynamic>>> _studentSubs = {};
  final Map<String, int> _classStudentCounts = {};
  List<ClassModel> _teacherClasses = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupClassStudentStreams();
      _loadStats();
    });
  }

  /// Subscribes to the teacher's classes and, for each class, to its student
  /// list.  Both subscriptions stay alive so the Home tab counts update the
  /// moment a student is added or removed from any of the teacher's classes
  /// on the website or by another admin — no pull-to-refresh needed.
  void _setupClassStudentStreams() {
    final fs = ref.read(firestoreServiceProvider);
    final uid = widget.user.uid as String;
    final schoolId = widget.user.schoolId as String;

    _classesSub?.cancel();
    _classesSub = fs.streamAllClassesForTeacher(schoolId, uid).listen((classes) {
      if (!mounted) return;
      _teacherClasses = classes;
      final newIds = classes.map((c) => c.classId).toSet();

      // Cancel subs for classes the teacher is no longer assigned to
      final removed = _studentSubs.keys.where((k) => !newIds.contains(k)).toList();
      for (final k in removed) {
        _studentSubs[k]?.cancel();
        _studentSubs.remove(k);
        _classStudentCounts.remove(k);
      }

      // Open subs for newly assigned classes
      for (final cls in classes) {
        if (!_studentSubs.containsKey(cls.classId)) {
          _studentSubs[cls.classId] =
              fs.streamStudentsByClass(cls.classId).listen((students) {
            if (!mounted) return;
            _classStudentCounts[cls.classId] = students.length;
            setState(() {
              _studentCount =
                  _classStudentCounts.values.fold(0, (a, n) => a + n);
            });
          });
        }
      }

      setState(() => _classCount = classes.length);
    });
  }

  @override
  void dispose() {
    _classesSub?.cancel();
    for (final sub in _studentSubs.values) {
      sub.cancel();
    }
    super.dispose();
  }

  Future<void> _loadStats() async {
    final fs = ref.read(firestoreServiceProvider);
    final schoolId = widget.user.schoolId as String;
    _lastLoadDate = DateTime.now();

    // Class count and student count are driven by live streams in
    // _setupClassStudentStreams — no one-time fetch needed here.

    try {
      final leaves = await fs.streamPendingLeavesForSchool(schoolId).first;
      if (mounted) setState(() => _pendingLeaves = leaves.length);
    } catch (e) {
      debugPrint('Stats: leaves error: $e');
    }

    try {
      final pickups =
          await fs.streamSchoolPickups(schoolId, status: 'PENDING').first;
      if (mounted) setState(() => _pendingPickups = pickups.length);
    } catch (e) {
      debugPrint('Stats: pickups error: $e');
    }

    await _loadAttendanceStats();
  }

  Future<void> _loadAttendanceStats() async {
    if (!mounted) return;
    setState(() => _attendanceLoading = true);
    final fs = ref.read(firestoreServiceProvider);
    final uid = widget.user.uid as String;
    final schoolId = widget.user.schoolId as String;

    try {
      // Use classes already loaded by the live stream; fall back to a one-time
      // fetch only if the stream hasn't emitted yet (first open).
      final classes = _teacherClasses.isNotEmpty
          ? _teacherClasses
          : await fs.streamAllClassesForTeacher(schoolId, uid).first;
      int presentCount = 0;
      final absentList = <Map<String, dynamic>>[];

      for (final cls in classes) {
        final session = await fs.getAttendanceSession(cls.classId, _selectedDate);
        if (session == null) continue; // attendance not yet taken for this class

        // Count present directly from session records
        presentCount += session.records
            .where((r) => r.status == AttendanceStatus.PRESENT)
            .length;

        // Collect absent/leave students
        final absentRecords = session.records
            .where((r) =>
                r.status == AttendanceStatus.ABSENT ||
                r.status == AttendanceStatus.LEAVE)
            .toList();
        if (absentRecords.isNotEmpty) {
          // Force server read so newly added students have their names resolved.
          final students = await fs.fetchStudentsByClass(cls.classId);
          final nameMap = {for (final s in students) s.studentId: s.name};
          for (final rec in absentRecords) {
            absentList.add({
              'studentId': rec.studentId,
              'name': nameMap[rec.studentId] ?? rec.studentId,
              'classId': cls.classId,
              'className': cls.name,
              'status': rec.status.name,
            });
          }
        }
      }

      if (mounted) {
        setState(() {
          _absentList = absentList;
          _absentCount = absentList.length;
          _presentCount = presentCount;
          _attendanceLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Stats: attendance error: $e');
      if (mounted) setState(() => _attendanceLoading = false);
    }
  }

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
      _presentCount = 0;
      _absentCount = 0;
      _absentList = [];
    });
    _loadAttendanceStats();
  }

  void _showAbsentSheet() {
    if (_absentList.isEmpty && !_attendanceLoading) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AbsentStudentsSheet(
        date: _selectedDate,
        absentList: _absentList,
        loading: _attendanceLoading,
      ),
    );
  }

  void _showPresentSheet() {
    if (_presentCount == 0 && !_attendanceLoading) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PresentStudentsSheet(
        date: _selectedDate,
        schoolId: widget.user.schoolId as String,
        teacherUid: widget.user.uid as String,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final schoolId = user.schoolId as String;
    final teacherUid = user.uid as String;
    final greeting = _greeting();

    // Auto-refresh if date changed (daily refresh)
    final today = DateTime.now();
    if (_lastLoadDate != null &&
        (today.day != _lastLoadDate!.day ||
            today.month != _lastLoadDate!.month)) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadStats());
    }

    return RefreshIndicator(
      color: _kPrimary,
      onRefresh: _loadStats,
      child: CustomScrollView(
        slivers: [
          // ── Header ──
          SliverToBoxAdapter(child: _buildHeader(user, greeting)),

          // ── Search Bar ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _buildSearchBar(),
            ),
          ),

          // ── Search Results (overlay-style) ──
          if (widget.searchActive)
            SliverToBoxAdapter(child: _buildSearchResults()),

          if (!widget.searchActive) ...[
            // ── Pending Requests Banner ──
            if (_pendingLeaves > 0 || _pendingPickups > 0)
              SliverToBoxAdapter(
                child: _buildRequestsBanner(),
              ),

            // ── Stats Grid ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pattern G — section header with accent bar
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 18,
                          decoration: BoxDecoration(
                            color: _kPrimary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Overview',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildStatsGrid(),
                  ],
                ),
              ),
            ),

            // ── Quick Actions ──
            SliverToBoxAdapter(
              child: _buildQuickActions(context, teacherUid, schoolId),
            ),

            // ── Announcements ──
            SliverToBoxAdapter(
              child: _buildAnnouncementsSection(schoolId, teacherUid),
            ),

            // ── Recent Leaves ──
            SliverToBoxAdapter(
              child: _buildRecentLeavesSection(schoolId),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(dynamic user, String greeting) {
    final initials = (user.name as String)
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0] : '')
        .join()
        .toUpperCase();

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_kHeaderBg, _kDark],
        ),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: _kDark.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative translucent circles
          Positioned(
            top: -30,
            right: -20,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: 60,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 20,
              right: 20,
              bottom: 24,
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
                          // Pattern J — decorative elements added to header
                          Text(
                            greeting,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.65),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                width: 4,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF59E0B),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  user.name as String,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _kPrimary.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              '🏫 Teacher',
                              style: TextStyle(
                                color: Color(0xFF5EEAD4),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _kPrimary.withValues(alpha: 0.5),
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 26,
                        backgroundColor: _kPrimary.withValues(alpha: 0.2),
                        child: Text(
                          initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Date navigation row
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        color: Colors.white.withValues(alpha: 0.7),
                        size: 14,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _isToday(_selectedDate)
                              ? 'Today, ${DateFormat('EEEE • MMM d').format(_selectedDate)}'
                              : DateFormat('EEE, MMM d').format(_selectedDate),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _changeDate(-1),
                        child: Icon(Icons.chevron_left,
                            color: Colors.white.withValues(alpha: 0.8), size: 22),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: _isToday(_selectedDate) ? null : () => _changeDate(1),
                        child: Icon(
                          Icons.chevron_right,
                          color: _isToday(_selectedDate)
                              ? Colors.white.withValues(alpha: 0.25)
                              : Colors.white.withValues(alpha: 0.8),
                          size: 22,
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
    );
  }

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.day == now.day && d.month == now.month && d.year == now.year;
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: widget.searchCtrl,
        onChanged: widget.onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search students by name, roll no...',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: _kPrimary, size: 20),
          suffixIcon: widget.searchActive
              ? IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: widget.onSearchClear,
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (widget.searchLoading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator(color: _kPrimary)),
      );
    }
    if (widget.searchResults.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            'No students found',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ),
      );
    }
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: widget.searchResults.map((s) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: _kPrimary.withValues(alpha: 0.1),
              child: Text(
                (s['name'] as String)[0].toUpperCase(),
                style: const TextStyle(color: _kPrimary, fontWeight: FontWeight.w700),
              ),
            ),
            title: Text(
              s['name'] as String,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            subtitle: Text(
              'Roll: ${s['rollNo'] ?? '—'}',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
            trailing: const Icon(Icons.chevron_right, color: _kPrimary),
            onTap: () {
              widget.onSearchClear();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StudentDetailScreen(
                    studentId: s['studentId'] as String,
                    classId: s['classId'] as String,
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRequestsBanner() {
    final total = _pendingLeaves + _pendingPickups;
    return GestureDetector(
      onTap: widget.onNavToRequests,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_kOrange, _kOrange.withValues(alpha: 0.8)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.notifications_active, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '$total pending request${total > 1 ? 's' : ''} need your attention!'
                '${_pendingLeaves > 0 ? '  •  $_pendingLeaves leave${_pendingLeaves > 1 ? 's' : ''}' : ''}'
                '${_pendingPickups > 0 ? '  •  $_pendingPickups pickup${_pendingPickups > 1 ? 's' : ''}' : ''}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    final rows = [
      [
        _StatData('My Classes',  '$_classCount',   Icons.class_rounded,          _kPrimary),
        _StatData('Students',    '$_studentCount', Icons.people_alt_rounded,     _kBlue),
      ],
      [
        _StatData('Leave Req.',  '$_pendingLeaves',  Icons.event_busy_rounded,     _kOrange),
        _StatData('Pickups',     '$_pendingPickups', Icons.directions_car_rounded, _kAmber),
      ],
      [
        _StatData('Present',
          _attendanceLoading ? '–' : '$_presentCount',
          Icons.check_circle_rounded, const Color(0xFF059669)),
        _StatData('Absent',
          _attendanceLoading ? '–' : '$_absentCount',
          Icons.cancel_rounded, _kRed),
      ],
    ];

    return LayoutBuilder(
      builder: (ctx, constraints) {
        final cardWidth = (constraints.maxWidth - 10) / 2; // 10 = gap between cards
        return Column(
          children: rows.map((pair) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: pair.map((s) {
                  final isAbsent  = s.label == 'Absent';
                  final isPresent = s.label == 'Present';
                  final isLeaveReq = s.label == 'Leave Req.';
                  final isPickups  = s.label == 'Pickups';
                  return GestureDetector(
                    onTap: isAbsent   ? _showAbsentSheet
                         : isPresent  ? _showPresentSheet
                         : isLeaveReq || isPickups ? widget.onNavToRequests
                         : null,
                    child: Container(
                      width: cardWidth,
                      margin: EdgeInsets.only(
                        left:  s == pair.first ? 0 : 5,
                        right: s == pair.last  ? 0 : 5,
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: s.color.withValues(alpha: 0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                        border: Border.all(
                            color: s.color.withValues(alpha: 0.12)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 36, height: 36,
                                decoration: BoxDecoration(
                                  color: s.color.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(s.icon, color: s.color, size: 18),
                              ),
                              if ((isAbsent && _absentCount > 0) ||
                                  (isPresent && _presentCount > 0) ||
                                  isLeaveReq ||
                                  isPickups)
                                Icon(Icons.chevron_right_rounded,
                                    color: s.color.withValues(alpha: 0.5),
                                    size: 14),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            s.value,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: s.color,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            s.label,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildQuickActions(
      BuildContext ctx, String teacherUid, String schoolId) {
    final actions = [
      _QuickAction('Mark\nAttendance', Icons.how_to_reg_rounded, _kPrimary, () {
        Navigator.push(
          ctx,
          MaterialPageRoute(
            builder: (_) => MarkAttendanceScreen(
              schoolId: schoolId,
              teacherUid: teacherUid,
            ),
          ),
        );
      }),
      _QuickAction('Lesson\nPlan', Icons.book_rounded, _kBlue, () {
        Navigator.push(
          ctx,
          MaterialPageRoute(
            builder: (_) => PostLessonPlanScreen(
              schoolId: schoolId,
              teacherUid: teacherUid,
            ),
          ),
        );
      }),
      _QuickAction('Upload\nNotes', Icons.upload_file_rounded, _kAmber, () {
        Navigator.push(
          ctx,
          MaterialPageRoute(
            builder: (_) => StudyMaterialsScreen(
              schoolId: schoolId,
              teacherUid: teacherUid,
            ),
          ),
        );
      }),
      _QuickAction('Announce', Icons.campaign_rounded, _kOrange, () {
        Navigator.push(
          ctx,
          MaterialPageRoute(
            builder: (_) => ClassAnnouncementScreen(
              schoolId: schoolId,
              teacherUid: teacherUid,
            ),
          ),
        );
      }),
      _QuickAction('Marks\nEntry', Icons.grade_rounded, _kRed, () {
        Navigator.push(
          ctx,
          MaterialPageRoute(
            builder: (_) => MarksHubScreen(
              schoolId: schoolId,
              teacherUid: teacherUid,
            ),
          ),
        );
      }),
      _QuickAction('Results', Icons.bar_chart_rounded, const Color(0xFFD97706), () {
        Navigator.push(
          ctx,
          MaterialPageRoute(
            builder: (_) => MarksResultsScreen(
              schoolId: schoolId,
              teacherUid: teacherUid,
            ),
          ),
        );
      }),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: _kPrimary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 96,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: actions.length,
            itemBuilder: (_, i) {
              final a = actions[i];
              return GestureDetector(
                onTap: a.onTap,
                child: Container(
                  width: 76,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: a.color.withValues(alpha: 0.12),
                          border: Border.all(
                              color: a.color.withValues(alpha: 0.25), width: 1.5),
                        ),
                        child: Icon(a.icon, color: a.color, size: 22),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        a.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAnnouncementsSection(String schoolId, String teacherUid) {
    final fs = ref.watch(firestoreServiceProvider);
    return StreamBuilder<List<Announcement>>(
      stream: fs.streamAnnouncementsForTeacher(schoolId),
      builder: (ctx, snap) {
        final items = snap.data ?? [];
        if (items.isEmpty) return const SizedBox();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                      color: _kOrange,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Announcements',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[800],
                    ),
                  ),
                  const Spacer(),
                  if (items.any((a) => !a.hasUserAcked(teacherUid)))
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _kOrange,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${items.where((a) => !a.hasUserAcked(teacherUid)).length} new',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => Navigator.push(
                      ctx,
                      MaterialPageRoute(
                        builder: (_) => AllAnnouncementsScreen(
                          schoolId:   schoolId,
                          teacherUid: teacherUid,
                        ),
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'See All',
                      style: TextStyle(
                        fontSize: 12,
                        color: _kPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ...items.take(3).map((a) {
              final isNew = !a.hasUserAcked(teacherUid);
              return _buildAnnouncementCard(a, isNew, teacherUid, fs);
            }),
          ],
        );
      },
    );
  }

  Widget _buildAnnouncementCard(
      Announcement a, bool isNew, String teacherUid, dynamic fs) {
    return GestureDetector(
      onTap: () {
        if (isNew) fs.acknowledgeAnnouncement(a.announcementId, teacherUid);
        _showAnnouncementDetail(a);
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isNew
              ? _kOrange.withValues(alpha: 0.06)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isNew
                ? _kOrange.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.15),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _kOrange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.campaign_rounded,
                  color: _kOrange, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          a.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: Colors.grey[900],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isNew)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: _kOrange,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  if (a.publishedAt != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('MMM d, h:mm a').format(a.publishedAt!),
                      style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                    ),
                  ],
                  const SizedBox(height: 3),
                  Text(
                    a.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAnnouncementDetail(Announcement a) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (_, ctrl) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                a.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              if (a.publishedAt != null)
                Text(
                  DateFormat('dd MMM yyyy, hh:mm a').format(a.publishedAt!),
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              const SizedBox(height: 16),
              Text(a.body, style: const TextStyle(fontSize: 14, height: 1.5)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentLeavesSection(String schoolId) {
    final fs = ref.watch(firestoreServiceProvider);
    return StreamBuilder<List<LeaveRequest>>(
      stream: fs.streamPendingLeavesForSchool(schoolId),
      builder: (ctx, snap) {
        final items = snap.data ?? [];
        if (items.isEmpty) return const SizedBox();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                      color: _kPrimary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Pending Leave Requests',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[800],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _kRed,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${items.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ...items.take(2).map((req) => _buildLeaveCard(req)),
          ],
        );
      },
    );
  }

  Widget _buildLeaveCard(LeaveRequest req) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kRed.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _kRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.event_busy_rounded,
                color: _kRed, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Leave Request',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: Colors.grey[900],
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${DateFormat('dd MMM').format(req.fromDate)} → ${DateFormat('dd MMM').format(req.toDate)}  •  ${req.durationDays}d',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                Text(
                  req.reason,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _kAmber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'PENDING',
              style: TextStyle(
                color: _kAmber,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  ATTENDANCE TAB
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _AttendanceTab extends ConsumerWidget {
  final dynamic user;
  const _AttendanceTab({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fs = ref.watch(firestoreServiceProvider);
    final schoolId = user.schoolId as String;
    final teacherUid = user.uid as String;

    return StreamBuilder<List<ClassModel>>(
      stream: fs.streamAllClassesForTeacher(schoolId, teacherUid),
      builder: (ctx, snap) {
        final classes = snap.data ?? [];

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _buildSectionHeader('Attendance', Icons.how_to_reg_rounded),
            ),

            // ── Morning Attendance ──
            SliverToBoxAdapter(
              child: _buildGroupTitle('Morning Attendance'),
            ),
            SliverToBoxAdapter(
              child: GestureDetector(
                onTap: () => Navigator.push(
                  ctx,
                  MaterialPageRoute(
                    builder: (_) => MarkAttendanceScreen(
                      schoolId: schoolId,
                      teacherUid: teacherUid,
                    ),
                  ),
                ),
                child: _buildAttendanceActionCard(
                  'Mark / Edit Morning Attendance',
                  'Mark present, absent, late, leave for any class',
                  Icons.how_to_reg_rounded,
                  _kPrimary,
                ),
              ),
            ),

            // ── Today's Attendance Summary by Class ──
            SliverToBoxAdapter(
              child: _buildGroupTitle("Today's Summary"),
            ),

            if (classes.isEmpty)
              const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('No classes assigned'),
                  ),
                ),
              ),

            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) {
                  final cls = classes[i];
                  return _TodayAttendanceTile(
                    cls: cls,
                    teacherUid: teacherUid,
                    schoolId: schoolId,
                  );
                },
                childCount: classes.length,
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 52, 20, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_kHeaderBg, _kDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.grey[600],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildAttendanceActionCard(
      String title, String subtitle, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: color, size: 16),
        ],
      ),
    );
  }
}

class _TodayAttendanceTile extends ConsumerWidget {
  final ClassModel cls;
  final String teacherUid;
  final String schoolId;

  const _TodayAttendanceTile({
    required this.cls,
    required this.teacherUid,
    required this.schoolId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fs = ref.watch(firestoreServiceProvider);
    return StreamBuilder(
      stream: fs.streamAttendanceSession(cls.classId, DateTime.now()),
      builder: (ctx, snap) {
        final session = snap.data;
        final present = session?.presentCount ?? 0;
        final absent  = session?.absentCount ?? 0;
        final total   = session?.records.length ?? 0;
        final marked  = session != null;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: (marked ? _kPrimary : Colors.grey[200])!,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  marked ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: marked ? Colors.white : Colors.grey[400],
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cls.displayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 3),
                    if (marked)
                      Text(
                        '$present present  •  $absent absent  •  $total total',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      )
                    else
                      Text(
                        'Not marked yet',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  ctx,
                  MaterialPageRoute(
                    builder: (_) => MarkAttendanceScreen(
                      schoolId: schoolId,
                      teacherUid: teacherUid,
                      preselectedClassId: cls.classId,
                    ),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _kPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    marked ? 'Edit' : 'Mark',
                    style: const TextStyle(
                      color: _kPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
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
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  CLASSES TAB
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _ClassesTab extends ConsumerWidget {
  final dynamic user;
  const _ClassesTab({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fs = ref.watch(firestoreServiceProvider);
    final schoolId  = user.schoolId as String;
    final teacherUid = user.uid as String;

    return StreamBuilder<List<ClassModel>>(
      stream: fs.streamAllClassesForTeacher(schoolId, teacherUid),
      builder: (ctx, snap) {
        final classes = snap.data ?? [];

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 52, 20, 16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_kHeaderBg, _kDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.class_, color: Colors.white, size: 22),
                    SizedBox(width: 10),
                    Text(
                      'My Classes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (classes.isEmpty)
              const SliverFillRemaining(
                child: Center(child: Text('No classes assigned to you')),
              ),

            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => _ClassCard(
                  cls: classes[i],
                  teacherUid: teacherUid,
                  schoolId: schoolId,
                ),
                childCount: classes.length,
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        );
      },
    );
  }
}

class _ClassCard extends ConsumerWidget {
  final ClassModel cls;
  final String teacherUid;
  final String schoolId;

  const _ClassCard({
    required this.cls,
    required this.teacherUid,
    required this.schoolId,
  });

  String _teacherRole() {
    if (cls.classTeacherUid == teacherUid) return 'Class Teacher';
    if (cls.proctorTeacherUid == teacherUid) return 'Proctor Teacher';
    final subj = cls.subjectTeachers
        .where((st) => st.teacherUid == teacherUid)
        .map((st) => st.subject)
        .join(', ');
    return subj.isNotEmpty ? 'Subject Teacher ($subj)' : 'Teacher';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role  = _teacherRole();
    final color = cls.classTeacherUid == teacherUid ? _kPrimary : _kBlue;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.8)],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.class_, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cls.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        role,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Container(
                //   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                //   decoration: BoxDecoration(
                //     color: Colors.white.withValues(alpha: 0.2),
                //     borderRadius: BorderRadius.circular(8),
                //   ),
                //   child: Text(
                //     '${cls.studentCount} students',
                //     style: const TextStyle(
                //       color: Colors.white,
                //       fontSize: 12,
                //       fontWeight: FontWeight.w600,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),

          // Actions
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ClassAction('Lesson Plan', Icons.book_rounded, _kBlue, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PostLessonPlanScreen(
                        schoolId: schoolId,
                        teacherUid: teacherUid,
                        preselectedClassId: cls.classId,
                      ),
                    ),
                  );
                }),
                _ClassAction('Timetable', Icons.schedule_rounded, _kPrimary, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ClassTimetableScreen(
                        cls: cls,
                        teacherUid: teacherUid,
                      ),
                    ),
                  );
                }),
                _ClassAction('Marks', Icons.grade_rounded, _kRed, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MarksHubScreen(
                        schoolId: schoolId,
                        teacherUid: teacherUid,
                        preselectedClassId: cls.classId,
                      ),
                    ),
                  );
                }),
                _ClassAction('My Plans', Icons.list_alt_rounded, _kAmber, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MyLessonPlansScreen(
                        teacherUid: teacherUid,
                        classId: cls.classId,
                        className: cls.displayName,
                      ),
                    ),
                  );
                }),
                _ClassAction('Students', Icons.people_rounded, const Color(0xFFD97706), () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StudentDetailScreen(
                        classId: cls.classId,
                        showClassList: true,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ClassAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ClassAction(this.label, this.icon, this.color, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  REQUESTS TAB
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _RequestsTab extends ConsumerStatefulWidget {
  final dynamic user;
  const _RequestsTab({required this.user});

  @override
  ConsumerState<_RequestsTab> createState() => _RequestsTabState();
}

class _RequestsTabState extends ConsumerState<_RequestsTab> {
  List<String> _classTeacherClassIds = [];
  @override
  void initState() {
    super.initState();
    _loadClassTeacherClasses();
  }

  Future<void> _loadClassTeacherClasses() async {
    final fs = ref.read(firestoreServiceProvider);
    final schoolId = widget.user.schoolId as String;
    final teacherUid = widget.user.uid as String;
    try {
      final classes = await fs.streamAllClassesForTeacher(schoolId, teacherUid).first;
      final ids = classes
          .where((c) => c.classTeacherUid == teacherUid)
          .map((c) => c.classId)
          .toList();
      if (mounted) setState(() => _classTeacherClassIds = ids);
    } catch (_) {
      // ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    final schoolId   = widget.user.schoolId as String;
    final teacherUid = widget.user.uid as String;
    // final fs = ref.watch(firestoreServiceProvider);

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: _kHeaderBg,
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top + 8),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Parent Requests',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const TabBar(
                  indicatorColor: _kPrimary,
                  labelColor: _kPrimary,
                  unselectedLabelColor: Colors.white54,
                  tabs: [
                    Tab(text: 'Leave'),
                    Tab(text: 'Pickups'),
                    // Tab(text: 'Special'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                LeaveRequestsScreen(
                  schoolId: schoolId,
                  teacherUid: teacherUid,
                  embeddedMode: true,
                  classTeacherClassIds: _classTeacherClassIds,
                ),
                EarlyPickupScreen(
                  schoolId: schoolId,
                  teacherUid: teacherUid,
                  embeddedMode: true,
                  classTeacherClassIds: _classTeacherClassIds,
                ),
                // _SpecialRequestsPanel(
                //   teacherUid: teacherUid,
                //   fs: fs,
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* ── Special Requests Panel (teacher side) — disabled ────────
class _SpecialRequestsPanel extends ConsumerWidget {
  final String teacherUid;
  final dynamic fs;

  const _SpecialRequestsPanel({
    required this.teacherUid,
    required this.fs,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<List<SpecialRequest>>(
      stream: fs.streamTeacherSpecialRequests(teacherUid),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: _kPrimary));
        }
        final requests = snap.data ?? [];
        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.help_outline_rounded,
                    size: 64, color: _kPrimary.withValues(alpha: 0.3)),
                const SizedBox(height: 16),
                const Text(
                  'No special requests',
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
          itemCount: requests.length,
          itemBuilder: (_, i) => _SpecialRequestCard(
            request: requests[i],
            teacherUid: teacherUid,
            fs: fs,
          ),
        );
      },
    );
  }
}

class _SpecialRequestCard extends StatefulWidget {
  final SpecialRequest request;
  final String teacherUid;
  final dynamic fs;

  const _SpecialRequestCard({
    required this.request,
    required this.teacherUid,
    required this.fs,
  });

  @override
  State<_SpecialRequestCard> createState() => _SpecialRequestCardState();
}

class _SpecialRequestCardState extends State<_SpecialRequestCard> {
  final _responseCtrl = TextEditingController();
  bool _acting = false;

  @override
  void dispose() {
    _responseCtrl.dispose();
    super.dispose();
  }

  Color _statusColor(SpecialRequestStatus s) {
    switch (s) {
      case SpecialRequestStatus.APPROVED:      return const Color(0xFF059669);
      case SpecialRequestStatus.REJECTED:      return _kRed;
      case SpecialRequestStatus.ACKNOWLEDGED:  return _kBlue;
      default:                                 return _kAmber;
    }
  }

  @override
  Widget build(BuildContext context) {
    final req = widget.request;
    final statusColor = _statusColor(req.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    req.subject,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    req.status.name,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: statusColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'From: ${req.parentName} • ${req.studentName}',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _kBlue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                req.type.name,
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _kBlue),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              req.description,
              style: TextStyle(color: Colors.grey[700], fontSize: 13),
            ),
            if (req.responseNote.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Response: ${req.responseNote}',
                  style:
                      TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ),
            ],
            if (req.status == SpecialRequestStatus.PENDING) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _responseCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Response note (optional)',
                  hintStyle:
                      TextStyle(color: Colors.grey[400], fontSize: 13),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.all(10),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _acting
                          ? null
                          : () async {
                              setState(() => _acting = true);
                              await widget.fs.respondToSpecialRequest(
                                requestId: req.requestId,
                                status: SpecialRequestStatus.REJECTED,
                                respondedBy: widget.teacherUid,
                                responseNote: _responseCtrl.text.trim(),
                              );
                              if (mounted) setState(() => _acting = false);
                            },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _kRed,
                        side: const BorderSide(color: _kRed),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Decline',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _acting
                          ? null
                          : () async {
                              setState(() => _acting = true);
                              await widget.fs.respondToSpecialRequest(
                                requestId: req.requestId,
                                status: SpecialRequestStatus.ACKNOWLEDGED,
                                respondedBy: widget.teacherUid,
                                responseNote: _responseCtrl.text.trim(),
                              );
                              if (mounted) setState(() => _acting = false);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kPrimary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Acknowledge',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
*/

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  PROFILE TAB
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _ProfileTab extends ConsumerWidget {
  final dynamic user;
  const _ProfileTab({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasChildren = ref.watch(hasLinkedStudentsProvider).value ?? false;
    final initials = (user.name as String)
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0] : '')
        .join()
        .toUpperCase();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).padding.top + 20,
              20,
              32,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_kHeaderBg, _kDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: _kPrimary,
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user.name as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.phone as String,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _kPrimary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'TEACHER',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _ProfileTile(Icons.email_outlined, 'Email', user.email ?? '—'),
                _ProfileTile(Icons.school_outlined, 'School ID', user.schoolId),
                const SizedBox(height: 16),
                // Edit Profile
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditProfileScreen(user: user),
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: _kBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.edit_rounded,
                              color: _kBlue, size: 18),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Text('Edit Profile',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0A0F1E))),
                        ),
                        Icon(Icons.chevron_right_rounded,
                            color: Colors.grey[400], size: 20),
                      ],
                    ),
                  ),
                ),
                // Switch to Parent — only shown when the teacher also has linked children
                if (hasChildren) ...[
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      ref.read(parentModeProvider.notifier).state = true;
                      context.go('/parent');
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 0),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFFD97706).withValues(alpha: 0.4)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.swap_horiz_rounded,
                              color: Color(0xFFD97706), size: 20),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text('Switch to Parent View',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFC2410C))),
                          ),
                          Icon(Icons.chevron_right_rounded,
                              color: Color(0xFFD97706), size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final router = GoRouter.of(context);
                    ref.read(parentModeProvider.notifier).state = false;
                    await NotificationService.signOut();
                    router.go('/login');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: _kRed.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: _kRed.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout_rounded, color: _kRed, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Logout',
                          style: TextStyle(
                            color: _kRed,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
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
      ],
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _ProfileTile(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: _kPrimary, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  SHARED HELPERS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _StatData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatData(this.label, this.value, this.icon, this.color);
}

class _QuickAction {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction(this.label, this.icon, this.color, this.onTap);
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  PRESENT STUDENTS BOTTOM SHEET  (grouped by class)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _PresentStudentsSheet extends StatefulWidget {
  final DateTime date;
  final String schoolId;
  final String teacherUid;
  const _PresentStudentsSheet({
    required this.date,
    required this.schoolId,
    required this.teacherUid,
  });

  @override
  State<_PresentStudentsSheet> createState() => _PresentStudentsSheetState();
}

class _PresentStudentsSheetState extends State<_PresentStudentsSheet> {
  // classId → {name, students: [{name, studentId}]}
  final _byClass = <String, Map<String, dynamic>>{};
  bool _loading = true;
  final _searchCtrl = TextEditingController();
  String _query = '';

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
      final db         = FirebaseFirestore.instance;
      final todayStart = DateTime(
          widget.date.year, widget.date.month, widget.date.day);
      final todayEnd   = todayStart.add(const Duration(days: 1));

      // Fetch all school classes then filter client-side for this teacher
      final allSnap = await db
          .collection(FSC.classes)
          .where('schoolId', isEqualTo: widget.schoolId)
          .get();

      final allClassDocs = allSnap.docs.where((doc) {
        final data = doc.data();
        if ((data['classTeacherUid'] as String?) == widget.teacherUid) {
          return true;
        }
        final subs = (data['subjectTeachers'] as List<dynamic>?) ?? [];
        return subs.any((st) =>
            (st as Map<String, dynamic>)['teacherUid'] == widget.teacherUid);
      }).toList();

      final byClass = <String, Map<String, dynamic>>{};
      final allStudentIds = <String>[];

      for (final classDoc in allClassDocs) {
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

        final records = sessSnap.docs.first.data()['records'] as List<dynamic>? ?? [];
        final presentIds = records
            .where((r) => (r['status'] as String? ?? '') == 'PRESENT')
            .map((r) => r['studentId'] as String? ?? '')
            .where((id) => id.isNotEmpty)
            .toList();

        if (presentIds.isEmpty) continue;

        final className =
            classDoc.data()['name'] as String? ?? classDoc.id;
        byClass[classDoc.id] = {
          'className': className,
          'students': presentIds.map((id) => {'studentId': id, 'name': '—'}).toList(),
        };
        allStudentIds.addAll(presentIds);
      }

      // Batch-fetch names
      final uniqueIds = allStudentIds.toSet().toList();
      final nameMap   = <String, String>{};
      for (int i = 0; i < uniqueIds.length; i += 30) {
        final batch = uniqueIds.skip(i).take(30).toList();
        final snap  = await db
            .collection(FSC.students)
            .where(FieldPath.documentId, whereIn: batch)
            .get();
        for (final doc in snap.docs) {
          nameMap[doc.id] = doc.data()['name'] as String? ?? '—';
        }
      }

      // Fill in names
      for (final entry in byClass.values) {
        final students = entry['students'] as List<Map<String, dynamic>>;
        for (final s in students) {
          final sid = s['studentId'] as String;
          if (nameMap.containsKey(sid)) s['name'] = nameMap[sid];
        }
      }

      if (mounted) {
        setState(() {
          _byClass
            ..clear()
            ..addAll(byClass);
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  int get _totalPresent => _byClass.values
      .expand((c) => c['students'] as List)
      .length;

  @override
  Widget build(BuildContext context) {
    const green   = Color(0xFF059669);
    final dateStr = DateFormat('EEE, MMM d').format(widget.date);

    // Build filtered list of classes
    final filteredClasses = _byClass.entries.where((entry) {
      if (_query.isEmpty) return true;
      final className = (entry.value['className'] as String).toLowerCase();
      final students  = entry.value['students'] as List<Map<String, dynamic>>;
      return className.contains(_query) ||
          students.any((s) =>
              (s['name'] as String).toLowerCase().contains(_query));
    }).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      maxChildSize:     0.95,
      minChildSize:     0.3,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(Icons.how_to_reg_rounded,
                        color: green, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Present Students',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w800)),
                        Text(dateStr,
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 12)),
                      ],
                    ),
                  ),
                  if (!_loading)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$_totalPresent present',
                        style: const TextStyle(
                            color: green,
                            fontWeight: FontWeight.w700,
                            fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Search bar
            if (!_loading)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: SizedBox(
                  height: 38,
                  child: TextField(
                    controller: _searchCtrl,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Search student or class…',
                      hintStyle:
                          TextStyle(fontSize: 12, color: Colors.grey[400]),
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
            const Divider(height: 1),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: green))
                  : filteredClasses.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.how_to_reg_outlined,
                                  color: Colors.grey[300], size: 48),
                              const SizedBox(height: 12),
                              Text(
                                _byClass.isEmpty
                                    ? 'No attendance recorded'
                                    : 'No results',
                                style: TextStyle(
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: ctrl,
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                          itemCount: filteredClasses.length,
                          itemBuilder: (_, i) {
                            final entry    = filteredClasses[i];
                            final className = entry.value['className'] as String;
                            final students = (entry.value['students']
                                    as List<Map<String, dynamic>>)
                                .where((s) =>
                                    _query.isEmpty ||
                                    (s['name'] as String)
                                        .toLowerCase()
                                        .contains(_query))
                                .toList();

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Class header
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 12, bottom: 6),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color:
                                              green.withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(className,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: green,
                                                fontWeight:
                                                    FontWeight.w700)),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${students.length} present',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[500]),
                                      ),
                                    ],
                                  ),
                                ),
                                // Student tiles
                                ...students.map((s) {
                                  final name = s['name'] as String;
                                  return ListTile(
                                    dense: true,
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 4, vertical: 0),
                                    leading: CircleAvatar(
                                      radius: 16,
                                      backgroundColor:
                                          green.withValues(alpha: 0.12),
                                      child: Text(
                                        name.isNotEmpty
                                            ? name[0].toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                            color: green,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12),
                                      ),
                                    ),
                                    title: Text(name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14)),
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: green.withValues(alpha: 0.1),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: const Text('Present',
                                          style: TextStyle(
                                              color: green,
                                              fontSize: 11,
                                              fontWeight:
                                                  FontWeight.w600)),
                                    ),
                                  );
                                }),
                                const Divider(height: 1),
                              ],
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

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  ABSENT STUDENTS BOTTOM SHEET
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _AbsentStudentsSheet extends StatelessWidget {
  final DateTime date;
  final List<Map<String, dynamic>> absentList;
  final bool loading;

  const _AbsentStudentsSheet({
    required this.date,
    required this.absentList,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEE, MMM d').format(date);
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      maxChildSize: 0.9,
      minChildSize: 0.3,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _kRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(Icons.cancel_rounded,
                        color: _kRed, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Absent / On Leave',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w800)),
                        Text(dateStr,
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 12)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _kRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${absentList.length} student${absentList.length != 1 ? 's' : ''}',
                      style: const TextStyle(
                          color: _kRed,
                          fontWeight: FontWeight.w700,
                          fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 20),
            Expanded(
              child: loading
                  ? const Center(
                      child: CircularProgressIndicator(color: _kPrimary))
                  : absentList.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle_rounded,
                                  color: Colors.green[300], size: 48),
                              const SizedBox(height: 12),
                              const Text('All students present!',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15)),
                              const SizedBox(height: 4),
                              Text('No absences recorded for $dateStr',
                                  style: TextStyle(
                                      color: Colors.grey[500], fontSize: 13)),
                            ],
                          ),
                        )
                      : ListView.separated(
                          controller: ctrl,
                          itemCount: absentList.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1),
                          itemBuilder: (_, i) {
                            final s = absentList[i];
                            final isLeave = s['status'] == 'LEAVE';
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isLeave
                                    ? _kAmber.withValues(alpha: 0.15)
                                    : _kRed.withValues(alpha: 0.12),
                                child: Text(
                                  (s['name'] as String).isNotEmpty
                                      ? (s['name'] as String)[0].toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                    color: isLeave ? _kAmber : _kRed,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              title: Text(
                                s['name'] as String? ?? '—',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                              subtitle: Text(
                                s['className'] as String? ?? '',
                                style: TextStyle(
                                    color: Colors.grey[500], fontSize: 12),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isLeave
                                      ? _kAmber.withValues(alpha: 0.12)
                                      : _kRed.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  isLeave ? 'On Leave' : 'Absent',
                                  style: TextStyle(
                                    color: isLeave ? _kAmber : _kRed,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
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
