import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'firebase_options.dart';
import 'app/app.dart';
import 'app/school_config.dart';
import 'core/services/notification_service.dart';
import 'core/utils/app_logger.dart';

// ─── 1. ADD THIS FUNCTION HERE (Outside of main) ───────────
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase is already initialised by the system before this runs.
  // No-op needed — Android shows the notification automatically.
}
// ───────────────────────────────────────────────────────────

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await FirebaseAppCheck.instance.activate(
    androidProvider: kDebugMode
        ? AndroidProvider.debug
        : AndroidProvider.playIntegrity,
  );

  // Register background message handler before runApp
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Load persisted session ID so the session guard can detect takeovers
  await NotificationService.loadPersistedSession();

  // Initialise notifications (requests permission, sets up channels)
  await NotificationService().initialize();

  final config = await loadSchoolConfig();

  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://5793048d9338862bcd3aab9d1e188782@o4510690645442560.ingest.de.sentry.io/4511008767344720';
      options.tracesSampleRate = 1.0;
      options.profilesSampleRate = 1.0;
      options.environment = 'development';
      options.debug = false;
    },
    appRunner: () {
      AppLogger.i('App', 'Starting ShalaLink with Sentry');
      runApp(
        ProviderScope(
          overrides: [schoolConfigProvider.overrideWithValue(config)],
          child: const ShalaLinkApp(),
        ),
      );
    },
  );
}
