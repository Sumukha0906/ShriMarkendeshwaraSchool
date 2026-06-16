import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Centralised structured logger for ShalaLink.
///
/// Usage:
///   AppLogger.i('TAG', 'User logged in');
///   AppLogger.e('TAG', 'Firestore write failed', error: e, stack: st);
///
/// In Android Studio / Logcat filter by "ShalaLink" to see all app logs.
/// In VS Code terminal they print to the debug console.
class AppLogger {
  AppLogger._();

  static const _appTag = 'ShalaLink';

  // ── Public API ───────────────────────────────────────────────────────────

  /// Verbose — low-level tracing (stream events, widget builds)
  static void v(String tag, String msg) =>
      _log('V', tag, msg);

  /// Debug — general flow (method calls, param values)
  static void d(String tag, String msg) =>
      _log('D', tag, msg);

  /// Info — important state changes (login, save, navigation)
  static void i(String tag, String msg) =>
      _log('I', tag, msg);

  /// Warning — unexpected but recoverable situations
  static void w(String tag, String msg, {Object? error}) =>
      _log('W', tag, msg, error: error);

  /// Error — failures that need attention; automatically sent to Sentry in release
  static void e(String tag, String msg,
      {Object? error, StackTrace? stack}) {
    _log('E', tag, msg, error: error);
    if (stack != null && kDebugMode) debugPrintStack(stackTrace: stack, label: '[$_appTag/E/$tag]');
    // In release mode, send to Sentry
    if (!kDebugMode && error != null) {
      Sentry.captureException(error, stackTrace: stack,
          hint: Hint.withMap({'tag': tag, 'msg': msg}));
    }
  }

  // ── Internal ─────────────────────────────────────────────────────────────

  static void _log(String level, String tag, String msg, {Object? error}) {
    if (!kDebugMode) return; // silent in release; hook Crashlytics here
    final ts = DateTime.now().toLocal();
    final hms = '${_pad(ts.hour)}:${_pad(ts.minute)}:${_pad(ts.second)}';
    final line = '[$_appTag/$level] $hms | $tag | $msg'
        '${error != null ? '\n  ERROR: $error' : ''}';
    debugPrint(line);
  }

  static String _pad(int n) => n.toString().padLeft(2, '0');
}
