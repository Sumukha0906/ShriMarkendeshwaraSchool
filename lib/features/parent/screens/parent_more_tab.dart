import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/models/student.dart';
import '../parent_dashboard.dart';
import 'announcements_screen.dart';
import 'fee_payment_screen.dart';
import 'edit_parent_profile_screen.dart';

class ParentMoreTab extends ConsumerWidget {
  final Student student;
  const ParentMoreTab({super.key, required this.student});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    final isMultiRole = user != null &&
        user.role != UserRole.PARENT &&
        user.role != UserRole.SUPER_ADMIN;

    return Scaffold(
      backgroundColor: kParentBg,
      appBar: AppBar(
        backgroundColor: kParentDark,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Text('More',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info card
            if (user != null) _ProfileCard(user: user),
            const SizedBox(height: 16),

            // Child switcher — shown when the parent has more than one child
            const ChildSwitcherBar(),
            const SizedBox(height: 4),

            // Multi-role switch — shown for any non-parent privileged user
            if (isMultiRole) ...[
              _SwitchRoleCard(
                roleLabel: _roleLabelFor(user.role),
                onSwitch: () {
                  ref.read(parentModeProvider.notifier).state = false;
                  _switchToPrimaryDashboard(context, user.role);
                },
              ),
              const SizedBox(height: 20),
            ],

            // Menu sections
            _SectionHeader(title: 'School'),
            _MenuItem(
              icon: Icons.campaign_rounded,
              label: 'Announcements',
              color: kParentPrimary,
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          AnnouncementsScreen(student: student))),
            ),
            _MenuItem(
              icon: Icons.account_balance_wallet_rounded,
              label: 'Fee & Payments',
              color: kParentAmber,
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          FeePaymentScreen(student: student))),
            ),
            const SizedBox(height: 16),

            _SectionHeader(title: 'Account'),
            _MenuItem(
              icon: Icons.edit_outlined,
              label: 'Edit Profile',
              color: const Color(0xFF3B82F6),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          const EditParentProfileScreen())),
            ),
            _MenuItem(
              icon: Icons.logout_rounded,
              label: 'Sign Out',
              color: const Color(0xFFEF4444),
              onTap: () async {
                // Capture router before the async sign-out so navigation works
                // even if this widget is unmounted mid-way (parentChildrenProvider
                // returns [] when the auth state changes, which rebuilds
                // ParentDashboard and removes ParentMoreTab from the tree).
                final router = GoRouter.of(context);
                ref.read(parentModeProvider.notifier).state = false;
                await NotificationService.signOut();
                router.go('/login');
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final dynamic user;
  const _ProfileCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kParentDark, Color(0xFF7C2D12)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: kParentAmber.withValues(alpha: 0.2),
            backgroundImage: (user.profilePhotoUrl?.isNotEmpty ?? false)
                ? NetworkImage(user.profilePhotoUrl)
                : null,
            child: (user.profilePhotoUrl?.isEmpty ?? true)
                ? Text(
                    user.name?.isNotEmpty == true
                        ? user.name[0].toUpperCase()
                        : 'P',
                    style: const TextStyle(
                      color: kParentAmber,
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.phone ?? '',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 13,
                  ),
                ),
                if ((user.email ?? '').isNotEmpty)
                  Text(
                    user.email,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: kParentPrimary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'Parent',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Returns a human-readable label for the user's primary (non-parent) role.
String _roleLabelFor(UserRole role) {
  switch (role) {
    case UserRole.TEACHER:       return 'Teacher';
    case UserRole.ADMIN:         return 'Admin';
    case UserRole.ADMINISTRATOR: return 'Administrator';
    case UserRole.PRINCIPAL:     return 'Principal';
    case UserRole.MANAGEMENT:    return 'Management';
    default:                     return role.name;
  }
}

// Navigates to the correct primary-role dashboard.
void _switchToPrimaryDashboard(BuildContext context, UserRole role) {
  switch (role) {
    case UserRole.TEACHER:       context.go('/teacher');       break;
    case UserRole.ADMIN:         context.go('/admin');         break;
    case UserRole.ADMINISTRATOR: context.go('/administrator'); break;
    case UserRole.PRINCIPAL:     context.go('/principal');     break;
    case UserRole.MANAGEMENT:    context.go('/management');    break;
    default:                     context.go('/login');         break;
  }
}

class _SwitchRoleCard extends StatelessWidget {
  final String roleLabel;
  final VoidCallback onSwitch;
  const _SwitchRoleCard({required this.roleLabel, required this.onSwitch});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSwitch,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFEDE9FE),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: const Color(0xFFD97706).withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFD97706).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.swap_horiz_rounded,
                  color: Color(0xFFD97706), size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Switch to $roleLabel View',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: Color(0xFF4C1D95),
                    ),
                  ),
                  Text(
                    'You are also a $roleLabel at your school',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFFD97706)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: Color(0xFFD97706)),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.grey[500],
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _MenuItem(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: kParentDark,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: Colors.grey[400], size: 18),
          ],
        ),
      ),
    );
  }
}

