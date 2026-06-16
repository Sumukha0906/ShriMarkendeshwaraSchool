import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/firestore_constants.dart';

// ─── Plan tiers ───────────────────────────────────────────────────────────────
// BASIC    (₹49/mo)  — attendance, announcements, student management
// STANDARD (₹99/mo)  — BASIC + fees, leave mgmt, timetable, achievements
// PREMIUM  (₹199/mo) — STANDARD + chat, lesson plans, expenses, documents, visitors

// ─── Feature flag keys ────────────────────────────────────────────────────────
// Store these as keys in `schools/{id}.features` map in Firestore.
// Super admin sets `plan` and optionally overrides individual flags.
class FeatureFlags {
  static const String attendance    = 'attendance';
  static const String announcements = 'announcements';
  static const String students      = 'students';
  static const String feeView       = 'feeView';        // view fee data
  static const String feeCollection = 'feeCollection';  // record payments
  static const String feeStructure  = 'feeStructure';   // set fee components
  static const String leaveMgmt     = 'leaveMgmt';
  static const String timetable     = 'timetable';
  static const String achievements  = 'achievements';
  static const String chat          = 'chat';
  static const String lessonPlans   = 'lessonPlans';
  static const String expenses      = 'expenses';
  static const String documents     = 'documents';
  static const String visitors      = 'visitors';
  static const String earlyPickup   = 'earlyPickup';
}

// ─── Default flags per plan ───────────────────────────────────────────────────
const _planDefaults = {
  'BASIC': {
    FeatureFlags.attendance:    true,
    FeatureFlags.announcements: true,
    FeatureFlags.students:      true,
    FeatureFlags.feeView:       false,
    FeatureFlags.feeCollection: false,
    FeatureFlags.feeStructure:  false,
    FeatureFlags.leaveMgmt:     false,
    FeatureFlags.timetable:     false,
    FeatureFlags.achievements:  false,
    FeatureFlags.chat:          false,
    FeatureFlags.lessonPlans:   false,
    FeatureFlags.expenses:      false,
    FeatureFlags.documents:     false,
    FeatureFlags.visitors:      false,
    FeatureFlags.earlyPickup:   false,
  },
  'STANDARD': {
    FeatureFlags.attendance:    true,
    FeatureFlags.announcements: true,
    FeatureFlags.students:      true,
    FeatureFlags.feeView:       true,
    FeatureFlags.feeCollection: true,
    FeatureFlags.feeStructure:  true,
    FeatureFlags.leaveMgmt:     true,
    FeatureFlags.timetable:     true,
    FeatureFlags.achievements:  true,
    FeatureFlags.chat:          false,
    FeatureFlags.lessonPlans:   false,
    FeatureFlags.expenses:      false,
    FeatureFlags.documents:     false,
    FeatureFlags.visitors:      false,
    FeatureFlags.earlyPickup:   true,
  },
  'PREMIUM': {
    FeatureFlags.attendance:    true,
    FeatureFlags.announcements: true,
    FeatureFlags.students:      true,
    FeatureFlags.feeView:       true,
    FeatureFlags.feeCollection: true,
    FeatureFlags.feeStructure:  true,
    FeatureFlags.leaveMgmt:     true,
    FeatureFlags.timetable:     true,
    FeatureFlags.achievements:  true,
    FeatureFlags.chat:          true,
    FeatureFlags.lessonPlans:   true,
    FeatureFlags.expenses:      true,
    FeatureFlags.documents:     true,
    FeatureFlags.visitors:      true,
    FeatureFlags.earlyPickup:   true,
  },
};

// ─── Service ──────────────────────────────────────────────────────────────────
class FeatureService {
  final FirebaseFirestore _db;
  FeatureService(this._db);

  static FeatureService get instance =>
      FeatureService(FirebaseFirestore.instance);

  /// Returns true if [feature] is enabled for [schoolId].
  /// Reads the school doc once; result is NOT cached — use a provider for caching.
  Future<bool> isEnabled(String schoolId, String feature) async {
    final snap = await _db.collection(FSC.schools).doc(schoolId).get();
    return _resolve(snap.data(), feature);
  }

  /// Check a feature from an already-loaded school data map (no extra Firestore read).
  static bool check(Map<String, dynamic>? schoolData, String feature) =>
      _resolve(schoolData, feature);

  static bool _resolve(Map<String, dynamic>? data, String feature) {
    if (data == null) return true; // fail-open during loading

    final plan     = (data['plan'] as String?)?.toUpperCase() ?? 'PREMIUM';
    final overrides = data['features'] as Map<String, dynamic>? ?? {};

    // Per-school override takes priority over plan default
    if (overrides.containsKey(feature)) {
      return overrides[feature] == true;
    }

    final defaults = _planDefaults[plan] ?? _planDefaults['PREMIUM']!;
    return defaults[feature] ?? true;
  }
}
