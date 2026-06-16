import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_constants.dart';
import '../../core/providers/core_providers.dart';
import '../../core/services/notification_service.dart';
import '../../core/models/school.dart';
import '../../core/models/user_model.dart';

class SuperAdminDashboard extends ConsumerStatefulWidget {
  const SuperAdminDashboard({super.key});

  @override
  ConsumerState<SuperAdminDashboard> createState() =>
      _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends ConsumerState<SuperAdminDashboard>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  int _totalSchools      = 0;
  int _totalUsers        = 0;
  int _totalStudents     = 0;
  int _totalInvitations  = 0;
  bool _statsLoading     = true;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
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
    try {
      // Schools: fetch + parse with same try-catch as streamAllSchools so the
      // stat always matches the visible list (skips malformed documents).
      final schoolSnap = await FirebaseFirestore.instance
          .collection(FSC.schools)
          .where('isActive', isEqualTo: true)
          .get();
      int validSchools = 0;
      for (final doc in schoolSnap.docs) {
        try {
          School.fromFirestore(doc);
          validSchools++;
        } catch (_) {}
      }

      final results = await Future.wait([
        FirebaseFirestore.instance
            .collection(FSC.users)
            .where('isActive', isEqualTo: true)
            .count()
            .get(),
        FirebaseFirestore.instance
            .collection(FSC.students)
            .where('isActive', isEqualTo: true)
            .count()
            .get(),
        FirebaseFirestore.instance
            .collection(FSC.invitations)
            .where('status', isEqualTo: 'PENDING')
            .count()
            .get(),
      ]);
      if (mounted) {
        setState(() {
          _totalSchools     = validSchools;
          _totalUsers       = results[0].count ?? 0;
          _totalStudents    = results[1].count ?? 0;
          _totalInvitations = results[2].count ?? 0;
          _statsLoading     = false;
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
      value: SystemUiOverlayStyle.dark,
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
      case 0:  return _buildOverviewTab(user);
      case 1:  return _buildSchoolsTab();
      case 2:  return _buildProfileTab(user);
      default: return _buildOverviewTab(user);
    }
  }

  BottomNavigationBar _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (i) => setState(() => _selectedIndex = i),
      selectedItemColor:   const Color(0xFFD97706),
      unselectedItemColor: Colors.grey[400],
      backgroundColor: Colors.white,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded), label: 'Overview'),
        BottomNavigationBarItem(
            icon: Icon(Icons.school_rounded), label: 'Schools'),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded), label: 'Profile'),
      ],
    );
  }

  // ─── OVERVIEW TAB ───────────────────────────────────────────────────────────

  Widget _buildOverviewTab(UserModel? user) {
    final firstName = user?.name.split(' ').first ?? 'Admin';
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader(firstName, user)),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 20),
              _sectionTitle('Platform Overview'),
              const SizedBox(height: 12),
              _buildStatsGrid(),
              const SizedBox(height: 24),
              _sectionTitle('Quick Actions'),
              const SizedBox(height: 12),
              _buildQuickActions(),
              const SizedBox(height: 24),
              _sectionTitle('Recent Schools'),
              const SizedBox(height: 12),
              _buildRecentSchools(),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(String firstName, UserModel? user) {
    final initials = user?.name.isNotEmpty == true
        ? user!.name
            .trim()
            .split(' ')
            .take(2)
            .map((w) => w[0].toUpperCase())
            .join()
        : 'SA';

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF022C22), Color(0xFF4C1D95)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft:  Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Role badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color:  const Color(0xFFD97706).withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: const Color(0xFFA78BFA).withValues(alpha: 0.4)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shield_rounded,
                            color: Color(0xFFA78BFA), size: 12),
                        SizedBox(width: 4),
                        Text(
                          'SUPER ADMIN',
                          style: TextStyle(
                            color: Color(0xFFA78BFA),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() => _selectedIndex = 2),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFD97706).withValues(alpha: 0.3),
                      ),
                      child: Center(
                        child: Text(
                          initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Welcome, $firstName',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Platform Administration',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55), fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0A0F1E)),
    );
  }

  Widget _buildStatsGrid() {
    final items = [
      ('Schools',       _totalSchools.toString(),  Icons.school_rounded,          const Color(0xFFD97706), const Color(0xFFF3E8FF)),
      ('Total Users',   _totalUsers.toString(),    Icons.people_rounded,          const Color(0xFF3B82F6), const Color(0xFFEFF6FF)),
      ('Students',      _totalStudents.toString(), Icons.menu_book_rounded,       const Color(0xFF059669), const Color(0xFFECFDF5)),
      ('Invitations',   _totalInvitations.toString(), Icons.mail_outline_rounded,    const Color(0xFFF59E0B), const Color(0xFFFFFBEB)),
    ];
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.45,
      children: items
          .map((item) => _statCard(
                item.$1, item.$2, item.$3, item.$4, item.$5))
          .toList(),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color,
      Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: bgColor, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 18),
          ),
          const Spacer(),
          _statsLoading
              ? Container(
                  width: 40,
                  height: 22,
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4)))
              : Text(value,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _quickAction('Create School', Icons.add_business_rounded,
              const Color(0xFFD97706),
              () => context.push('/super-admin/create-school')),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _quickAction('All Schools', Icons.list_alt_rounded,
              const Color(0xFF3B82F6),
              () => setState(() => _selectedIndex = 1)),
        ),
      ],
    );
  }

  Widget _quickAction(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0A0F1E))),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSchools() {
    return StreamBuilder<List<School>>(
      stream: ref.watch(firestoreServiceProvider).streamAllSchools(),
      builder: (context, snap) {
        if (snap.hasError) {
          return const SizedBox.shrink();
        }
        if (!snap.hasData) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFFD97706)));
        }
        final schools = snap.data!.take(5).toList();
        if (schools.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                Icon(Icons.school_outlined, size: 40, color: Colors.grey[300]),
                const SizedBox(height: 8),
                Text('No schools yet',
                    style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => context.push('/super-admin/create-school'),
                  child: const Text(
                    'Create your first school →',
                    style: TextStyle(
                        color: Color(0xFFD97706),
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          );
        }
        return Column(
          children: schools.map(_buildSchoolTile).toList(),
        );
      },
    );
  }

  Widget _buildSchoolTile(School school) {
    return GestureDetector(
      onTap: () =>
          context.push('/super-admin/school/${school.schoolId}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFD97706).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  school.name.isNotEmpty
                      ? school.name[0].toUpperCase()
                      : 'S',
                  style: const TextStyle(
                      color: Color(0xFFD97706),
                      fontWeight: FontWeight.w800,
                      fontSize: 18),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(school.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Color(0xFF0A0F1E))),
                  if (school.address.isNotEmpty)
                    Text(school.address,
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey[500]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  // ─── SCHOOLS TAB ────────────────────────────────────────────────────────────

  Widget _buildSchoolsTab() {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(
          children: [
            _tabHeader('Schools'),
            Expanded(
              child: StreamBuilder<List<School>>(
                stream: ref.watch(firestoreServiceProvider).streamAllSchools(),
                builder: (context, snap) {
                  if (snap.hasError) {
                    return Center(
                        child: Text('Error: ${snap.error}',
                            style: const TextStyle(color: Colors.red)));
                  }
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFFD97706)));
                  }
                  final schools = snap.data ?? [];
                  if (schools.isEmpty) return _emptySchools();
                  return ListView.builder(
                    padding:
                        const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: schools.length,
                    itemBuilder: (context, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildSchoolCard(schools[i]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/super-admin/create-school'),
        backgroundColor: const Color(0xFFD97706),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('New School',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _tabHeader(String title) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0A0F1E))),
        ],
      ),
    );
  }

  Widget _emptySchools() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFD97706).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.school_outlined,
                color: Color(0xFFD97706), size: 32),
          ),
          const SizedBox(height: 16),
          const Text('No schools yet',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0A0F1E))),
          const SizedBox(height: 8),
          Text('Create the first school to get started',
              style: TextStyle(fontSize: 14, color: Colors.grey[500])),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => context.push('/super-admin/create-school'),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFD97706),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('Create School',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSchoolCard(School school) {
    return GestureDetector(
      onTap: () => context.push('/super-admin/school/${school.schoolId}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFFD97706), Color(0xFF065F46)]),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  school.name.isNotEmpty
                      ? school.name[0].toUpperCase()
                      : 'S',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 22),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(school.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Color(0xFF0A0F1E))),
                  const SizedBox(height: 3),
                  if (school.address.isNotEmpty)
                    Text(school.address,
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey[500]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (school.phone.isNotEmpty) ...[
                        Icon(Icons.phone_outlined,
                            size: 11, color: Colors.grey[400]),
                        const SizedBox(width: 3),
                        Text(school.phone,
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[400])),
                        const SizedBox(width: 10),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF059669)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(school.academicYear,
                            style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF059669),
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: Colors.grey, size: 22),
          ],
        ),
      ),
    );
  }

  // ─── PROFILE TAB ────────────────────────────────────────────────────────────

  Widget _buildProfileTab(UserModel? user) {
    final initials = user?.name.isNotEmpty == true
        ? user!.name
            .trim()
            .split(' ')
            .take(2)
            .map((w) => w[0].toUpperCase())
            .join()
        : 'SA';

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                    colors: [Color(0xFFD97706), Color(0xFF065F46)]),
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
            Text(user?.name ?? '—',
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0A0F1E))),
            const SizedBox(height: 4),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFD97706).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('Super Admin',
                  style: TextStyle(
                      color: Color(0xFFD97706),
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 6),
            Text(user?.phone ?? '—',
                style: TextStyle(fontSize: 13, color: Colors.grey[500])),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () async {
                await NotificationService.signOut();
                if (mounted) context.go('/login');
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
                            fontWeight: FontWeight.w600,
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
}
