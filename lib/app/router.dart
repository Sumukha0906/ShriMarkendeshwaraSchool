import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/splash_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/otp_screen.dart';
import '../features/auth/complete_profile_screen.dart';
import '../features/auth/role_router.dart';
import '../features/admin/admin_dashboard.dart';
import '../features/super_admin/super_admin_dashboard.dart';
import '../features/super_admin/screens/create_school_screen.dart';
import '../features/super_admin/screens/school_detail_screen.dart';
import '../features/principal/principal_dashboard.dart';
import '../features/principal/screens/create_announcement_screen.dart';
import '../features/admin/screens/fee_management_screen.dart';
import '../features/management/screens/set_fee_screen.dart';
import '../features/principal/screens/school_students_screen.dart';
import '../features/principal/screens/achievements_screen.dart';
import '../features/principal/screens/lesson_plans_screen.dart';
import '../features/teacher/teacher_dashboard.dart';
import '../features/parent/parent_dashboard.dart';
import '../features/management/management_dashboard.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/providers/core_providers.dart';

String _currentAcademicYearStr() => '2026-27';

class PlaceholderDashboard extends ConsumerWidget {
  final String role;
  const PlaceholderDashboard({super.key, required this.role});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF080D1A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$role Dashboard',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coming soon!',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 48),
            GestureDetector(
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) context.go('/login');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF97316).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFF97316).withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.logout_rounded,
                      color: Color(0xFFF97316),
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Logout',
                      style: TextStyle(
                        color: Color(0xFFF97316),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
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

class _FeeManagementWrapper extends ConsumerWidget {
  final bool showSetFeeOption;
  final bool canApplyFee;
  final bool canEditComponents;
  final bool readOnly;
  const _FeeManagementWrapper({
    this.showSetFeeOption = true,
    this.canApplyFee = true,
    this.canEditComponents = true,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    return userAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Text('Failed to load user: $e',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
      data: (user) {
        if (user == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('User profile not found.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }
        return FeeManagementScreen(
          schoolId:          user.schoolId,
          adminUid:          user.uid,
          adminName:         user.name,
          showSetFeeOption:  showSetFeeOption,
          canApplyFee:       canApplyFee,
          canEditComponents: canEditComponents,
          readOnly:          readOnly,
        );
      },
    );
  }
}

class _SetFeeWrapper extends ConsumerWidget {
  const _SetFeeWrapper();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    return userAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (user) {
        if (user == null) return const Scaffold(body: Center(child: Text('User not found')));
        return SetFeeScreen(
          schoolId:     user.schoolId,
          adminUid:     user.uid,
          academicYear: _currentAcademicYearStr(),
        );
      },
    );
  }
}

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/otp',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return OtpScreen(
          verificationId: extra['verificationId'] as String,
          phone: extra['phone'] as String,
          resendToken: extra['resendToken'] as int?,
        );
      },
    ),
    GoRoute(
      path: '/complete-profile',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return CompleteProfileScreen(
          phone: extra['phone'] as String,
          uid: extra['uid'] as String,
        );
      },
    ),
    GoRoute(path: '/home', builder: (context, state) => const RoleRouter()),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminDashboard(),
    ),
    GoRoute(
      path: '/administrator',
      builder: (context, state) => const AdminDashboard(readOnlyFees: true),
    ),
    GoRoute(
      path: '/administrator/fees',
      builder: (context, state) => const _FeeManagementWrapper(
        showSetFeeOption:  false,
        canApplyFee:       false,
        canEditComponents: true,
        readOnly:          false,
      ),
    ),
    GoRoute(
      path: '/admin/fees',
      builder: (context, state) => const _FeeManagementWrapper(
        showSetFeeOption:  false,
        canApplyFee:       false,
        canEditComponents: true,
      ),
    ),
    GoRoute(
      path: '/admin/set-fee',
      builder: (context, state) => const _SetFeeWrapper(),
    ),
    GoRoute(
      path: '/super-admin',
      builder: (context, state) => const SuperAdminDashboard(),
    ),
    GoRoute(
      path: '/super-admin/create-school',
      builder: (context, state) => const CreateSchoolScreen(),
    ),
    GoRoute(
      path: '/super-admin/school/:schoolId',
      builder: (context, state) => SchoolDetailScreen(
        schoolId: state.pathParameters['schoolId']!,
      ),
    ),
    GoRoute(
      path: '/principal',
      builder: (context, state) => const PrincipalDashboard(),
    ),
    GoRoute(
      path: '/principal/create-announcement',
      builder: (context, state) => const CreateAnnouncementScreen(),
    ),
    GoRoute(
      path: '/principal/students',
      builder: (context, state) => const SchoolStudentsScreen(),
    ),
    GoRoute(
      path: '/principal/fees',
      builder: (context, state) => const _FeeManagementWrapper(),
    ),
    GoRoute(
      path: '/principal/achievements',
      builder: (context, state) => const AchievementsScreen(),
    ),
    GoRoute(
      path: '/principal/lesson-plans',
      builder: (context, state) => const LessonPlansScreen(),
    ),
    GoRoute(
      path: '/teacher',
      builder: (context, state) => const TeacherDashboard(),
    ),
    GoRoute(
      path: '/parent',
      builder: (context, state) => const ParentDashboard(),
    ),
    GoRoute(
      path: '/management',
      builder: (context, state) => const ManagementDashboard(),
    ),
  ],
);
