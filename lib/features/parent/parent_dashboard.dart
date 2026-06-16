import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/core_providers.dart';
import '../../core/services/notification_service.dart';
import '../../core/models/student.dart';
import 'screens/parent_home_tab.dart';
import 'screens/parent_attendance_tab.dart';
import 'screens/parent_academics_tab.dart';
import 'screens/parent_more_tab.dart';

// ── Parent theme colours — Forest Green + Saffron ────────────
const kParentPrimary   = Color(0xFF065F46); // Forest Green
const kParentAmber     = Color(0xFFD97706); // Saffron
const kParentDark      = Color(0xFF022C22); // Deep green-black
const kParentBg        = Color(0xFFF0FDF4); // Pale green-white
const kParentCard      = Color(0xFFFFFFFF);
const kParentSurface   = Color(0xFFD1FAE5); // Pale green

// ── Parent children provider ──────────────────────────────────
// StreamProvider so classId/isActive changes in Firestore are reflected
// immediately — prevents stale student data causing wrong classId in leave
// requests and other parent-submitted data.
final parentChildrenProvider = StreamProvider.autoDispose<List<Student>>((ref) async* {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) { yield []; return; }
  final fs = ref.read(firestoreServiceProvider);

  // Prefer the phone stored in the Firestore user doc.
  // If it is empty (can happen when the doc was created before phone was
  // written), fall back to the Firebase Auth phone number (always E.164).
  // streamStudentsForParentFull normalises both forms internally.
  final phone = user.phone.isNotEmpty
      ? user.phone
      : (FirebaseAuth.instance.currentUser?.phoneNumber ?? '');

  yield* fs.streamStudentsForParentFull(user.uid, phone);
});

/// Horizontal chip row for switching between children.
/// Self-contained: reads the providers directly, so it works in any tab.
/// Returns empty space when the parent has only one child.
class ChildSwitcherBar extends ConsumerWidget {
  const ChildSwitcherBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childrenAsync = ref.watch(parentChildrenProvider);
    final selectedIndex = ref.watch(selectedChildIndexProvider);

    final children = childrenAsync.value ?? [];
    if (children.length <= 1) return const SizedBox.shrink();

    return Container(
      color: kParentDark,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: children.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (ctx, i) {
            final c = children[i];
            final isSelected = i == selectedIndex;
            return GestureDetector(
              onTap: () =>
                  ref.read(selectedChildIndexProvider.notifier).state = i,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF065F46) : Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF065F46) : Colors.white.withValues(alpha: 0.3),
                  ),
                  boxShadow: isSelected
                      ? [BoxShadow(color: const Color(0xFF065F46).withValues(alpha: 0.4), blurRadius: 6)]
                      : [],
                ),
                child: Text(
                  c.name.split(' ').first,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class ParentDashboard extends ConsumerStatefulWidget {
  const ParentDashboard({super.key});

  @override
  ConsumerState<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends ConsumerState<ParentDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final childrenAsync = ref.watch(parentChildrenProvider);
    final selectedIndex = ref.watch(selectedChildIndexProvider);

    return childrenAsync.when(
      loading: () => const Scaffold(
        backgroundColor: kParentBg,
        body: Center(child: CircularProgressIndicator(color: kParentPrimary)),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: kParentBg,
        body: Center(child: Text('Error: $e')),
      ),
      data: (children) {
        if (children.isEmpty) {
          return _buildNoChildScreen();
        }

        // Guard selected index
        final safeIndex = selectedIndex < children.length ? selectedIndex : 0;
        final child = children[safeIndex];

        return Scaffold(
          backgroundColor: kParentBg,
          body: IndexedStack(
            index: _currentIndex,
            children: [
              ParentHomeTab(
                student: child,
                allChildren: children,
                selectedIndex: safeIndex,
              ),
              ParentAttendanceTab(student: child),
              ParentAcademicsTab(student: child),
              ParentMoreTab(student: child),
            ],
          ),
          bottomNavigationBar: _buildBottomNav(),
        );
      },
    );
  }

  Widget _buildBottomNav() {
    // Pattern D — top border accent on selected tab
    final tabs = [
      {'icon': Icons.home_outlined, 'selectedIcon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.calendar_today_outlined, 'selectedIcon': Icons.calendar_today_rounded, 'label': 'Attendance'},
      {'icon': Icons.menu_book_outlined, 'selectedIcon': Icons.menu_book_rounded, 'label': 'Academics'},
      {'icon': Icons.more_horiz_rounded, 'selectedIcon': Icons.more_horiz_rounded, 'label': 'More'},
    ];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
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
              final sel = _currentIndex == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _currentIndex = i),
                  child: Container(
                    decoration: BoxDecoration(
                      border: sel
                          ? const Border(top: BorderSide(color: kParentPrimary, width: 3))
                          : const Border(top: BorderSide(color: Colors.transparent, width: 3)),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          sel ? t['selectedIcon'] as IconData : t['icon'] as IconData,
                          color: sel ? kParentPrimary : Colors.grey.shade400,
                          size: 22,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          t['label'] as String,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                            color: sel ? kParentPrimary : Colors.grey.shade400,
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

  Widget _buildNoChildScreen() {
    return Scaffold(
      backgroundColor: kParentBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: kParentPrimary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.child_care_rounded,
                  color: kParentPrimary,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'No Children Linked',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: kParentDark,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your account is not yet linked to any student.\n'
                'Please contact your school admin for an invitation.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 40),
              TextButton.icon(
                onPressed: () async {
                  await NotificationService.signOut();
                  if (mounted) context.go('/login');
                },
                icon: const Icon(Icons.logout_rounded, color: kParentPrimary),
                label: const Text(
                  'Sign out',
                  style: TextStyle(color: kParentPrimary, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

/// Shared placeholder shown inside any parent tab when the student has
/// not yet been assigned to a class.
class NoClassPlaceholder extends StatelessWidget {
  const NoClassPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: kParentAmber.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.class_outlined,
                  color: kParentAmber, size: 32),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Class Assigned',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: kParentDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This student has not been assigned to a class yet.\nPlease contact your school admin.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
