import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/user_model.dart';
import '../../core/providers/core_providers.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/logger_service.dart';

class RoleRouter extends ConsumerWidget {
  const RoleRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      loading: () => const Scaffold(
        backgroundColor: Color(0xFF080D1A),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF059669)),
        ),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: const Color(0xFF080D1A),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline,
                  color: Colors.white.withValues(alpha: 0.4), size: 48),
              const SizedBox(height: 16),
              Text(
                'Could not load your profile.\nPlease restart the app.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => context.go('/login'),
                child: const Text(
                  'Back to Login',
                  style: TextStyle(color: Color(0xFF059669)),
                ),
              ),
            ],
          ),
        ),
      ),
      data: (user) {
        if (user == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/login');
          });
          return const Scaffold(
            backgroundColor: Color(0xFF080D1A),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF059669)),
            ),
          );
        }

        // Block deactivated accounts immediately
        if (!user.isActive) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await NotificationService.signOut();
            if (context.mounted) context.go('/login');
          });
          return Scaffold(
            backgroundColor: const Color(0xFF080D1A),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.block_rounded,
                          color: Color(0xFFEF4444), size: 40),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Account Deactivated',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your account has been deactivated by your school administrator.\n\nPlease contact your school for assistance.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 13,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Save FCM token + log successful login
        WidgetsBinding.instance.addPostFrameCallback((_) {
          NotificationService().saveTokenForUser(user.uid);
          AuditLogger.logLogin(
            uid:      user.uid,
            role:     user.role.name,
            schoolId: user.schoolId,
          );
        });

        // SUPER_ADMIN goes directly — no parent mode possible.
        if (user.role == UserRole.SUPER_ADMIN) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/super-admin');
          });
          return const Scaffold(
            backgroundColor: Color(0xFF080D1A),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF059669)),
            ),
          );
        }

        // PARENT goes directly — no dual-role possible from the parent side.
        if (user.role == UserRole.PARENT) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/parent');
          });
          return const Scaffold(
            backgroundColor: Color(0xFF080D1A),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF059669)),
            ),
          );
        }

        // For all other privileged roles (Teacher, Admin, Administrator,
        // Principal, Management): check whether the user also has linked
        // children. If yes, show a profile-picker so they can choose which
        // mode to enter.
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          try {
            final fs = ref.read(firestoreServiceProvider);
            final hasChildren = await fs.hasLinkedStudents(user.uid, phone: user.phone);
            if (!context.mounted) return;
            if (hasChildren) {
              final chosen = await showDialog<String>(
                context: context,
                barrierDismissible: false,
                builder: (_) => _ProfilePickerDialog(primaryRole: user.role),
              );
              if (!context.mounted) return;
              if (chosen == 'parent') {
                ref.read(parentModeProvider.notifier).state = true;
                context.go('/parent');
              } else {
                ref.read(parentModeProvider.notifier).state = false;
                _gotoRoleDashboard(context, user.role);
              }
            } else {
              _gotoRoleDashboard(context, user.role);
            }
          } catch (_) {
            // Network or Firestore error — skip the parent check and
            // navigate directly to the primary role dashboard.
            if (context.mounted) _gotoRoleDashboard(context, user.role);
          }
        });

        return const Scaffold(
          backgroundColor: Color(0xFF080D1A),
          body: Center(
            child: CircularProgressIndicator(color: Color(0xFF059669)),
          ),
        );
      },
    );
  }
}

// ── Navigate to the correct dashboard for a privileged role ─────────────────
void _gotoRoleDashboard(BuildContext context, UserRole role) {
  switch (role) {
    case UserRole.PRINCIPAL:     context.go('/principal');     break;
    case UserRole.ADMIN:         context.go('/admin');         break;
    case UserRole.ADMINISTRATOR: context.go('/administrator'); break;
    case UserRole.TEACHER:       context.go('/teacher');       break;
    case UserRole.MANAGEMENT:    context.go('/management');    break;
    // SUPER_ADMIN and PARENT are handled before this is called.
    default:                     context.go('/login');         break;
  }
}

// ── Role display info used by the profile picker ─────────────────────────────
({String label, IconData icon, Color color}) _roleDisplay(UserRole role) {
  switch (role) {
    case UserRole.TEACHER:
      return (label: 'Teacher', icon: Icons.school_rounded,
          color: const Color(0xFF065F46));
    case UserRole.ADMIN:
      return (label: 'Admin', icon: Icons.admin_panel_settings_rounded,
          color: const Color(0xFF065F46));
    case UserRole.ADMINISTRATOR:
      return (label: 'Administrator', icon: Icons.admin_panel_settings_outlined,
          color: const Color(0xFF065F46));
    case UserRole.PRINCIPAL:
      return (label: 'Principal', icon: Icons.account_balance_rounded,
          color: const Color(0xFF3B82F6));
    case UserRole.MANAGEMENT:
      return (label: 'Management', icon: Icons.business_center_rounded,
          color: const Color(0xFFDC2626));
    default:
      return (label: role.name, icon: Icons.person_rounded,
          color: const Color(0xFF059669));
  }
}

// ── Profile picker dialog for dual-role users ────────────────────────────────
class _ProfilePickerDialog extends StatelessWidget {
  final UserRole primaryRole;
  const _ProfilePickerDialog({required this.primaryRole});

  @override
  Widget build(BuildContext context) {
    final rd = _roleDisplay(primaryRole);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.swap_horiz_rounded,
                color: Color(0xFFD97706), size: 40),
            const SizedBox(height: 12),
            const Text(
              'Choose Your Profile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF431407),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You have both ${rd.label} and Parent access.\nWhich profile would you like to use?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _ProfileOption(
                    icon: rd.icon,
                    label: rd.label,
                    color: rd.color,
                    onTap: () => Navigator.pop(context, 'primary'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ProfileOption(
                    icon: Icons.child_care_rounded,
                    label: 'Parent',
                    color: const Color(0xFFD97706),
                    onTap: () => Navigator.pop(context, 'parent'),
                  ),
                ),
              ],
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
  const _ProfileOption(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
