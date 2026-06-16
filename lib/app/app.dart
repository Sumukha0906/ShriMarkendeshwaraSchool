import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'router.dart';
import 'school_config.dart';
import '../core/providers/core_providers.dart';
import '../core/services/notification_service.dart';

class ShalaLinkApp extends ConsumerWidget {
  const ShalaLinkApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(schoolConfigProvider);

    return MaterialApp.router(
      title: config.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: config.primaryColorValue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: config.primaryColorValue,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: config.primaryColorValue,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
      routerConfig: appRouter,
      builder: (context, child) => _SessionGuard(child: child ?? const SizedBox()),
    );
  }
}

// ── Session Guard ──────────────────────────────────────────────────────────
// Watches the user's Firestore doc in real-time. If another device logs in
// and changes activeSessionId, this device is automatically signed out.
class _SessionGuard extends ConsumerStatefulWidget {
  final Widget child;
  const _SessionGuard({required this.child});

  @override
  ConsumerState<_SessionGuard> createState() => _SessionGuardState();
}

class _SessionGuardState extends ConsumerState<_SessionGuard> {
  bool _handlingSignOut = false;

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<Map<String, dynamic>?>>(
      userDocStreamProvider,
      (_, next) {
        next.whenData((data) async {
          if (data == null || _handlingSignOut) return;

          final firestoreSessionId = data['activeSessionId'] as String?;
          final localSessionId = NotificationService.currentSessionId;

          // Only check if both IDs are known; mismatches mean another device logged in
          if (localSessionId != null &&
              firestoreSessionId != null &&
              firestoreSessionId != localSessionId) {
            _handlingSignOut = true;
            await NotificationService.signOut();
            // Navigate to login after sign-out
            WidgetsBinding.instance.addPostFrameCallback((_) {
              appRouter.go('/login');
            });
          }
        });
      },
    );

    return widget.child;
  }
}