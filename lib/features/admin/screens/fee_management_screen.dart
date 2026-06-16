import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/firestore_constants.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/models/student.dart';
import '../../../core/models/fee.dart';
import '../../../core/models/class_model.dart';
import '../../../core/services/fee_receipt_service.dart';

// ─── Colours ────────────────────────────────────────────────────────────────
const _kPrimary = Color(0xFF059669);
const _kDark    = Color(0xFF065F46);
const _kBg      = Color(0xFFF5F6FA);
const _kAmber   = Color(0xFFF59E0B);
const _kRed     = Color(0xFFEF4444);
const _kBlue    = Color(0xFF3B82F6);

String _currentAcademicYear() => '2026-27';


// ─── Inline component row (for edit-fee-components editor) ──────────────────
class _CompRow {
  final TextEditingController nameCtrl;
  final TextEditingController amtCtrl;
  _CompRow({String name = '', String amount = ''})
      : nameCtrl = TextEditingController(text: name),
        amtCtrl  = TextEditingController(text: amount);
  void dispose() { nameCtrl.dispose(); amtCtrl.dispose(); }
}

// ─── Main Screen ────────────────────────────────────────────────────────────
class FeeManagementScreen extends ConsumerStatefulWidget {
  final String schoolId;
  final String adminUid;
  final String adminName;
  final bool showSetFeeOption;
  /// When true, shows the "Apply Fees to Students" button (website-only behaviour on mobile).
  final bool canApplyFee;
  /// When true, the breakdown component editor is available in the fee detail sheet.
  final bool canEditComponents;
  /// When true, hides payment recording — Administrator role uses this.
  final bool readOnly;
  /// When set, pre-fills the search bar and auto-opens the fee detail for this student.
  final String? initialStudentId;
  final String? initialStudentName;

  const FeeManagementScreen({
    super.key,
    required this.schoolId,
    required this.adminUid,
    required this.adminName,
    this.showSetFeeOption = true,
    this.canApplyFee = true,
    this.canEditComponents = true,
    this.readOnly = false,
    this.initialStudentId,
    this.initialStudentName,
  });

  @override
  ConsumerState<FeeManagementScreen> createState() => _FeeManagementScreenState();
}

class _FeeManagementScreenState extends ConsumerState<FeeManagementScreen> {
  List<ClassModel> _classes   = [];
  bool _classesLoaded         = false;
  final _searchCtrl           = TextEditingController();
  String _searchQuery         = '';
  // null = All, 'unassigned' = no class, or a classId string
  String? _classFilter;
  final _academicYear         = _currentAcademicYear();
  String? _fixedStudentId;

  @override
  void initState() {
    super.initState();
    if (widget.initialStudentName != null) {
      _searchCtrl.text = widget.initialStudentName!;
      _searchQuery = widget.initialStudentName!;
    }
    if (widget.initialStudentId != null) {
      _fixedStudentId = widget.initialStudentId;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadClasses());
  }

  Future<void> _loadClasses() async {
    try {
      final fs = ref.read(firestoreServiceProvider);
      final classes = await fs.streamSchoolClasses(widget.schoolId).first
          .timeout(const Duration(seconds: 10), onTimeout: () => []);
      if (!mounted) return;
      setState(() { _classes = classes; _classesLoaded = true; });
    } catch (_) {
      if (mounted) setState(() => _classesLoaded = true);
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Widget _classChip(String label, String? value) {
    final selected = _classFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: () => setState(() => _classFilter = value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? _kDark : Colors.white,
              fontSize: 12,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            backgroundColor: _kDark,
            foregroundColor: Colors.white,
            pinned: true,
            title: const Text('Fee Management',
                style: TextStyle(fontWeight: FontWeight.w700)),
            actions: [
              if (widget.canApplyFee)
                IconButton(
                  icon: const Icon(Icons.group_add_rounded, size: 20),
                  tooltip: 'Apply Fees to Students',
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20))),
                    builder: (_) => _ApplyFeesSheet(
                      schoolId:     widget.schoolId,
                      adminUid:     widget.adminUid,
                      adminName:    widget.adminName,
                      academicYear: _academicYear,
                    ),
                  ),
                ),
            ],
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(_classesLoaded ? 96 : 50),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() {
                        _searchQuery    = v;
                        _fixedStudentId = null;
                      }),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search student...',
                        hintStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 13),
                        prefixIcon: const Icon(Icons.search,
                            color: Colors.white70, size: 18),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close,
                                    color: Colors.white70, size: 16),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  setState(() {
                                    _searchQuery    = '';
                                    _fixedStudentId = null;
                                  });
                                })
                            : null,
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.15),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        isDense: true,
                      ),
                    ),
                  ),
                  if (_classesLoaded)
                    SizedBox(
                      height: 38,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
                        children: [
                          _classChip('All', null),
                          ..._classes.map((c) => _classChip(
                                c.section.isNotEmpty
                                    ? '${c.name}-${c.section}'
                                    : c.name,
                                c.classId,
                              )),
                          _classChip('Unassigned', 'unassigned'),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
        body: !_classesLoaded
            ? const Center(child: CircularProgressIndicator(color: _kPrimary))
            : _FeeClassTab(
                schoolId:          widget.schoolId,
                classFilter:       _classFilter,
                academicYear:      _academicYear,
                searchQuery:       _searchQuery,
                fixedStudentId:    _fixedStudentId,
                adminUid:          widget.adminUid,
                adminName:         widget.adminName,
                classes:           _classes,
                showSetFeeOption:  widget.showSetFeeOption,
                canEditComponents: widget.canEditComponents,
                readOnly:          widget.readOnly,
              ),
      ),
    );
  }
}

// ─── Helper for the collected-filter list ───────────────────────────────────
// ─── Student list tab ────────────────────────────────────────────────────────
class _FeeClassTab extends ConsumerWidget {
  final String  schoolId;
  /// null = All, 'unassigned' = no class assigned, or a specific classId.
  final String? classFilter;
  final String  academicYear;
  final String  searchQuery;
  final String? fixedStudentId;
  final String  adminUid;
  final String  adminName;
  final List<ClassModel> classes;
  final bool showSetFeeOption;
  final bool canEditComponents;
  final bool readOnly;

  const _FeeClassTab({
    required this.schoolId,
    this.classFilter,
    required this.academicYear,
    required this.searchQuery,
    this.fixedStudentId,
    required this.adminUid,
    required this.adminName,
    required this.classes,
    this.showSetFeeOption  = true,
    this.canEditComponents = true,
    this.readOnly          = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fs = ref.watch(firestoreServiceProvider);
    return StreamBuilder<List<Student>>(
      stream: fs.streamAllSchoolStudents(schoolId),
      builder: (ctx, studentSnap) {
        if (studentSnap.connectionState == ConnectionState.waiting &&
            studentSnap.data == null) {
          return const Center(child: CircularProgressIndicator(color: _kPrimary));
        }
        if (studentSnap.hasError && studentSnap.data == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: _kRed.withValues(alpha: 0.5)),
                const SizedBox(height: 12),
                const Text('Could not load students',
                    style: TextStyle(color: _kDark)),
                const SizedBox(height: 4),
                Text('${studentSnap.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          );
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection(FSC.fees)
              .where('schoolId', isEqualTo: schoolId)
              .snapshots(),
          builder: (ctx, feeSnap) {
            final students = studentSnap.data ?? [];
            final feeDocs  = feeSnap.data?.docs ?? [];

            // Parse fee docs, skipping any with missing required fields
            final fees = feeDocs
                .map((d) { try { return Fee.fromFirestore(d); } catch (_) { return null; } })
                .whereType<Fee>()
                .toList();

            // Per-student best fee for card display
            final feeByStudentYear = <String, Fee>{};
            for (final f in fees) {
              final key      = '${f.studentId}_${f.academicYear}';
              final existing = feeByStudentYear[key];
              if (existing == null || f.totalPaid > existing.totalPaid) {
                feeByStudentYear[key] = f;
              }
            }
            final feeByStudent = <String, Fee>{};
            for (final f in feeByStudentYear.values) {
              final existing = feeByStudent[f.studentId];
              if (existing == null) {
                feeByStudent[f.studentId] = f;
              } else if (f.totalPaid > existing.totalPaid) {
                feeByStudent[f.studentId] = f;
              } else if (f.totalPaid == existing.totalPaid &&
                         f.academicYear.compareTo(existing.academicYear) > 0) {
                feeByStudent[f.studentId] = f;
              }
            }

            // ── Filter students ───────────────────────────────────────────────
            final knownClassIds = classes.map((c) => c.classId).toSet();

            var filtered = students.where((s) {
              // ID lock (opened from dashboard)
              if (fixedStudentId != null) return s.studentId == fixedStudentId;
              // Search filter
              if (searchQuery.isNotEmpty) {
                final q = searchQuery.toLowerCase();
                if (!s.name.toLowerCase().contains(q) &&
                    !s.rollNo.toLowerCase().contains(q) &&
                    !s.admissionNo.toLowerCase().contains(q)) return false;
              }
              // Class filter
              if (classFilter == 'unassigned') {
                return s.classId.isEmpty || !knownClassIds.contains(s.classId);
              } else if (classFilter != null) {
                return s.classId == classFilter;
              }
              return true;
            }).toList();

            // Sort: highest pending first, fully-paid last
            filtered.sort((a, b) {
              final pendingA = feeByStudent[a.studentId]?.totalPending ?? double.infinity;
              final pendingB = feeByStudent[b.studentId]?.totalPending ?? double.infinity;
              return pendingB.compareTo(pendingA);
            });

            return Column(
              children: [
                const SizedBox(height: 8),
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.people_outline, size: 48, color: Colors.grey[300]),
                              const SizedBox(height: 8),
                              Text(
                                searchQuery.isNotEmpty
                                    ? 'No students match "$searchQuery"'
                                    : classFilter == 'unassigned'
                                        ? 'No unassigned students'
                                        : 'No students found',
                                style: TextStyle(color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          primary: false,
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          itemCount: filtered.length,
                          itemBuilder: (_, i) {
                            final student = filtered[i];
                            final fee     = feeByStudent[student.studentId];
                            final clsName = classes
                                    .where((c) => c.classId == student.classId)
                                    .firstOrNull
                                    ?.displayName ?? '';
                            return _StudentFeeCard(
                              student:             student,
                              studentNameFallback: student.name,
                              fee:                 fee,
                              className:           clsName,
                              academicYear:        academicYear,
                              schoolId:            schoolId,
                              adminUid:            adminUid,
                              adminName:           adminName,
                              showSetFeeOption:    showSetFeeOption,
                              canEditComponents:   canEditComponents,
                              readOnly:            readOnly,
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}


// ─── Student card ────────────────────────────────────────────────────────────
class _StudentFeeCard extends ConsumerWidget {
  final Student? student;
  final String   studentNameFallback;
  final Fee?     fee;
  final String   className;
  final String  academicYear;
  final String  schoolId;
  final String  adminUid;
  final String  adminName;
  final bool    showSetFeeOption;
  final bool    canEditComponents;
  final bool    readOnly;

  const _StudentFeeCard({
    required this.student,
    required this.studentNameFallback,
    required this.fee,
    required this.className,
    required this.academicYear,
    required this.schoolId,
    required this.adminUid,
    required this.adminName,
    this.showSetFeeOption = true,
    this.canEditComponents = true,
    this.readOnly = false,
  });

  Color get _statusColor {
    if (fee == null)        return _kAmber;
    if (fee!.isFullyPaid)   return _kPrimary;
    if (fee!.totalPaid > 0) return _kBlue;
    return _kRed;
  }

  String get _statusLabel {
    if (fee == null)        return 'Not Set';
    if (fee!.isFullyPaid)   return 'Fully Paid';
    if (fee!.totalPaid > 0) return 'Partial';
    return 'Pending';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _showFeeDetail(context, ref),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 4, color: _statusColor),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: _statusColor.withValues(alpha: 0.12),
                          child: Text(
                            studentNameFallback.isNotEmpty ? studentNameFallback[0].toUpperCase() : '?',
                            style: TextStyle(
                                color: _statusColor, fontWeight: FontWeight.w700, fontSize: 16),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(studentNameFallback,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF0A0F1E))),
                              Text(
                                '$className${(student?.rollNo.isNotEmpty == true) ? " • Roll: ${student!.rollNo}" : ""}',
                                style: TextStyle(color: Colors.grey[500], fontSize: 11),
                              ),
                              if (fee != null) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text('₹${fee!.totalPaid.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                            color: _kPrimary, fontWeight: FontWeight.w700, fontSize: 12)),
                                    Text(' / ₹${fee!.totalAmount.toStringAsFixed(0)}',
                                        style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(3),
                                  child: LinearProgressIndicator(
                                    value: fee!.totalAmount > 0
                                        ? (fee!.totalPaid / fee!.totalAmount).clamp(0.0, 1.0) : 0,
                                    backgroundColor: Colors.grey[200],
                                    color: _statusColor,
                                    minHeight: 3,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(_statusLabel,
                                  style: TextStyle(
                                      color: _statusColor, fontSize: 11, fontWeight: FontWeight.w700)),
                            ),
                            if (fee != null && !fee!.isFullyPaid) ...[
                              const SizedBox(height: 4),
                              Text('₹${fee!.totalPending.toStringAsFixed(0)} due',
                                  style: const TextStyle(
                                      color: _kRed, fontSize: 11, fontWeight: FontWeight.w600)),
                            ],
                            const SizedBox(height: 4),
                            const Icon(Icons.chevron_right, color: Colors.grey, size: 16),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFeeDetail(BuildContext context, WidgetRef ref) {
    if (student == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _FeeDetailSheet(
        student:     student!,
        initialFee:  fee,
        className:   className,
        academicYear: academicYear,
        schoolId:    schoolId,
        adminUid:    adminUid,
        adminName:   adminName,
        canSetFee:       showSetFeeOption,
        canEditComponents: canEditComponents,
        readOnly:        readOnly,
      ),
    );
  }
}

// ─── Fee detail bottom sheet ─────────────────────────────────────────────────
class _FeeDetailSheet extends ConsumerStatefulWidget {
  final Student student;
  final Fee?    initialFee;
  final String  className;
  final String  academicYear;
  final String  schoolId;
  final String  adminUid;
  final String  adminName;
  final bool    canSetFee;
  final bool    canEditComponents;
  final bool    readOnly;

  const _FeeDetailSheet({
    required this.student,
    required this.initialFee,
    required this.className,
    required this.academicYear,
    required this.schoolId,
    required this.adminUid,
    required this.adminName,
    this.canSetFee = true,
    this.canEditComponents = true,
    this.readOnly = false,
  });

  @override
  ConsumerState<_FeeDetailSheet> createState() => _FeeDetailSheetState();
}

class _FeeDetailSheetState extends ConsumerState<_FeeDetailSheet> {
  final _totalFeeCtrl = TextEditingController();
  final _payAmtCtrl   = TextEditingController();
  final _payNoteCtrl  = TextEditingController();
  PaymentMode _payMode      = PaymentMode.CASH;
  bool _savingFee           = false;
  bool _savingPay           = false;
  bool _showPayForm         = false;
  bool _feeLoaded           = false;
  bool _showCompEditor      = false;
  bool _savingComps         = false;
  List<_CompRow> _compRows  = [];
  Map<String, dynamic>? _lastReceipt; // {receiptNumber, downloadUrl, pdfBytes, fileName}
  String _fatherName        = '';

  @override
  void initState() {
    super.initState();
    if (widget.initialFee != null) {
      _totalFeeCtrl.text = widget.initialFee!.totalAmount.toStringAsFixed(0);
      _feeLoaded = true;
      _initCompRows(widget.initialFee!.feeComponents);
    }
    _loadFatherName();
  }

  Future<void> _loadFatherName() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('students')
          .doc(widget.student.studentId)
          .get();
      final name = (doc.data()?['fatherName'] as String?) ?? '';
      if (mounted && name.isNotEmpty) setState(() => _fatherName = name);
    } catch (_) {}
  }

  String get _classOnlyName => widget.className.split(' - ').first;

  void _initCompRows(Map<String, double> components) {
    for (final r in _compRows) r.dispose();
    _compRows = components.entries
        .map((e) => _CompRow(name: e.key, amount: e.value.toStringAsFixed(0)))
        .toList();
    if (_compRows.isEmpty) _compRows.add(_CompRow());
  }

  @override
  void dispose() {
    _totalFeeCtrl.dispose();
    _payAmtCtrl.dispose();
    _payNoteCtrl.dispose();
    for (final r in _compRows) r.dispose();
    super.dispose();
  }

  Future<void> _saveTotalFee(Fee? liveFee) async {
    final amt = double.tryParse(_totalFeeCtrl.text.trim());
    if (amt == null || amt <= 0) { _snack('Enter a valid amount'); return; }
    setState(() => _savingFee = true);
    try {
      final fs = ref.read(firestoreServiceProvider);
      await fs.upsertStudentFee(
        schoolId:      widget.schoolId,
        studentId:     widget.student.studentId,
        studentName:   widget.student.name,
        classId:       widget.student.classId,
        className:     widget.className,
        academicYear:  widget.academicYear,
        totalAmount:   amt,
        updatedByUid:  widget.adminUid,
        updatedByName: widget.adminName,
      );
      if (mounted) _snack('Fee updated', isGood: true);
    } catch (e) {
      if (mounted) _snack('Error: $e');
    }
    if (mounted) setState(() => _savingFee = false);
  }

  Future<void> _saveComponents(Fee? liveFee) async {
    final Map<String, double> components = {};
    for (final row in _compRows) {
      final name = row.nameCtrl.text.trim();
      final amt  = double.tryParse(row.amtCtrl.text.trim()) ?? 0.0;
      if (name.isNotEmpty && amt > 0) components[name] = amt;
    }
    if (components.isEmpty) { _snack('Add at least one component with amount > 0'); return; }
    final total = components.values.fold(0.0, (a, b) => a + b);
    setState(() => _savingComps = true);
    try {
      final fs = ref.read(firestoreServiceProvider);
      if (liveFee != null) {
        // Update existing fee record
        final newPending = (total - liveFee.totalPaid).clamp(0.0, double.infinity);
        await fs.updateFeeComponents(
          feeId:         liveFee.feeId,
          components:    components,
          totalAmount:   total,
          totalPending:  newPending,
          updatedByUid:  widget.adminUid,
          updatedByName: widget.adminName,
          schoolId:      widget.schoolId,
        );
      } else {
        // Create new fee record with components
        await fs.upsertStudentFeeWithComponents(
          schoolId:      widget.schoolId,
          studentId:     widget.student.studentId,
          studentName:   widget.student.name,
          classId:       widget.student.classId,
          className:     widget.className,
          academicYear:  widget.academicYear,
          components:    components,
          totalAmount:   total,
          updatedByUid:  widget.adminUid,
          updatedByName: widget.adminName,
        );
      }
      if (mounted) {
        setState(() { _savingComps = false; _showCompEditor = false; });
        _snack('Fee components saved', isGood: true);
      }
    } catch (e) {
      if (mounted) { setState(() => _savingComps = false); _snack('Error: $e'); }
    }
  }

  Future<void> _recordPayment(Fee? liveFee) async {
    final amt = double.tryParse(_payAmtCtrl.text.trim());
    if (amt == null || amt <= 0) { _snack('Enter a valid amount'); return; }
    if (liveFee == null) { _snack('Set total fee first'); return; }
    setState(() => _savingPay = true);
    try {
      final fs = ref.read(firestoreServiceProvider);
      final payment = Payment(
        paymentId:      const Uuid().v4(),
        amount:         amt,
        mode:           _payMode,
        paidAt:         DateTime.now(),
        recordedBy:     widget.adminUid,
        transactionRef: _payNoteCtrl.text.trim(),
      );
      await fs.recordFeePaymentWithNotification(
        feeId:          liveFee.feeId,
        studentId:      widget.student.studentId,
        payment:        payment,
        recordedByName: widget.adminName,
      );

      // Generate PDF receipt
      final school = await fs.getSchool(widget.schoolId);
      final receiptNumber = await FeeReceiptService.getNextReceiptNumber(widget.schoolId);
      final remainingBalance = (liveFee.totalPending - amt).clamp(0.0, double.infinity);
      final receiptData = ReceiptData(
        receiptNumber:    receiptNumber,
        schoolId:         widget.schoolId,
        schoolName:       school?.name ?? widget.schoolId,
        schoolAddress:    school?.address ?? '',
        schoolPhone:      school?.phone ?? '',
        schoolEmail:      school?.email ?? '',
        schoolLogoUrl:    school?.logoUrl ?? '',
        studentId:        widget.student.studentId,
        studentName:      widget.student.name,
        fatherName:       _fatherName,
        admissionNo:      widget.student.admissionNo,
        className:        _classOnlyName,
        academicYear:     widget.academicYear,
        feeComponents:    liveFee.feeComponents,
        totalAmount:      liveFee.totalAmount,
        remainingBalance: remainingBalance,
        payment:          payment,
      );
      final receiptResult = await FeeReceiptService.uploadAndSaveReceipt(
        data:      receiptData,
        adminUid:  widget.adminUid,
        adminName: widget.adminName,
      );

      _payAmtCtrl.clear();
      _payNoteCtrl.clear();
      if (mounted) {
        setState(() {
          _savingPay   = false;
          _showPayForm = false;
          _lastReceipt = receiptResult;
        });
        _snack('Payment recorded & receipt generated', isGood: true);
      }
    } catch (e) {
      if (mounted) { setState(() => _savingPay = false); _snack('Error: $e'); }
    }
  }

  void _downloadReceipt() async {
    if (_lastReceipt == null) return;
    try {
      await Printing.sharePdf(
        bytes: _lastReceipt!['pdfBytes'] as Uint8List,
        filename: _lastReceipt!['fileName'] as String,
      );
    } catch (e) {
      if (mounted) _snack('Download failed: $e');
    }
  }

  void _snack(String msg, {bool isGood = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isGood ? _kPrimary : null,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final fs = ref.watch(firestoreServiceProvider);
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize:     0.95,
      minChildSize:     0.4,
      expand: false,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: StreamBuilder<Fee?>(
          stream: fs.streamStudentFee(widget.student.studentId, widget.academicYear),
          builder: (ctx, snap) {
            final liveFee = snap.data ?? widget.initialFee;
            if (liveFee != null && !_feeLoaded) {
              _feeLoaded = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && _totalFeeCtrl.text.isEmpty) {
                  _totalFeeCtrl.text = liveFee.totalAmount.toStringAsFixed(0);
                  _initCompRows(liveFee.feeComponents);
                  setState(() {});
                }
              });
            }
            return ListView(
              controller: ctrl,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),

                // Student header
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: _kPrimary.withValues(alpha: 0.12),
                      child: Text(
                        widget.student.name.isNotEmpty
                            ? widget.student.name[0].toUpperCase() : '?',
                        style: const TextStyle(
                            color: _kPrimary, fontWeight: FontWeight.w700, fontSize: 18),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.student.name,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w800,
                                  color: Color(0xFF0A0F1E))),
                          Text(
                            '${widget.className}${widget.student.rollNo.isNotEmpty ? " • Roll: ${widget.student.rollNo}" : ""} • ${widget.academicYear}',
                            style: TextStyle(color: Colors.grey[500], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Fee summary card
                if (liveFee != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: _kDark, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _FeeItem('Total', '₹${liveFee.totalAmount.toStringAsFixed(0)}', Colors.white),
                            _FeeItem('Paid',  '₹${liveFee.totalPaid.toStringAsFixed(0)}',  const Color(0xFF6EE7B7)),
                            _FeeItem('Due',   '₹${liveFee.totalPending.toStringAsFixed(0)}', _kAmber),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: liveFee.totalAmount > 0
                                ? (liveFee.totalPaid / liveFee.totalAmount).clamp(0.0, 1.0) : 0,
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                            color: _kPrimary,
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Fee breakdown
                if (liveFee != null && liveFee.feeComponents.isNotEmpty) ...[
                  _sectionLabel('Fee Breakdown'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: liveFee.feeComponents.entries.map((e) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(e.key, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                            Text('₹${e.value.toStringAsFixed(0)}',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0A0F1E))),
                          ],
                        ),
                      )).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // ── Edit Fee Components ───────────────────────────────────────
                if (widget.canEditComponents) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _sectionLabel('Fee Components'),
                      TextButton.icon(
                        onPressed: () {
                          if (!_showCompEditor && liveFee != null && _compRows.length == 1 &&
                              _compRows.first.nameCtrl.text.isEmpty) {
                            _initCompRows(liveFee.feeComponents);
                          } else if (!_showCompEditor && liveFee == null) {
                            _initCompRows({});
                          }
                          setState(() => _showCompEditor = !_showCompEditor);
                        },
                        icon: Icon(_showCompEditor ? Icons.close : Icons.edit_rounded, size: 14),
                        label: Text(_showCompEditor ? 'Cancel' : 'Edit'),
                        style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
                      ),
                    ],
                  ),
                  if (_showCompEditor) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...List.generate(_compRows.length, (i) => _CompRowWidget(
                            row:      _compRows[i],
                            canDelete: _compRows.length > 1,
                            onDelete: () {
                              _compRows[i].dispose();
                              setState(() => _compRows.removeAt(i));
                            },
                            onChanged: () => setState(() {}),
                          )),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () => setState(() => _compRows.add(_CompRow())),
                                icon: const Icon(Icons.add_rounded, size: 14, color: _kDark),
                                label: const Text('Add Component',
                                    style: TextStyle(color: _kDark, fontSize: 12)),
                                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                              ),
                            ],
                          ),
                          // Total
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: _kDark.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _kDark)),
                                Text(
                                  '₹ ${_compRows.fold(0.0, (s, r) => s + (double.tryParse(r.amtCtrl.text) ?? 0)).toStringAsFixed(0)}',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _kDark),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _savingComps ? null : () => _saveComponents(liveFee),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _kDark,
                                foregroundColor: Colors.white,
                                shape: const StadiumBorder(),
                              ),
                              child: _savingComps
                                  ? const SizedBox(
                                      width: 16, height: 16,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2))
                                  : const Text('Save Components'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ] else
                    const SizedBox(height: 4),
                ],

                // Set total fee (simple override)
                if (widget.canSetFee && !_showCompEditor) ...[
                  _sectionLabel('Set / Update Total Fee'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _totalFeeCtrl,
                          keyboardType: TextInputType.number,
                          decoration: _inputDeco('Total annual fee (₹)'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _savingFee ? null : () => _saveTotalFee(liveFee),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _kDark, foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          shape: const StadiumBorder(),
                        ),
                        child: _savingFee
                            ? const SizedBox(width: 16, height: 16,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Save'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],

                // Record payment — hidden for read-only roles (ADMINISTRATOR)
                if (!widget.readOnly)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _sectionLabel('Record Payment'),
                      TextButton.icon(
                        onPressed: () => setState(() => _showPayForm = !_showPayForm),
                        icon: Icon(_showPayForm ? Icons.expand_less : Icons.add_rounded, size: 16),
                        label: Text(_showPayForm ? 'Cancel' : 'Add Payment'),
                      ),
                    ],
                  ),

                if (_showPayForm) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _payAmtCtrl,
                          keyboardType: TextInputType.number,
                          decoration: _inputDeco('Amount (₹)'),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          children: PaymentMode.values.map((m) {
                            final selected = _payMode == m;
                            return FilterChip(
                              label: Text(m.name,
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: selected ? Colors.white : _kDark)),
                              selected: selected,
                              onSelected: (_) => setState(() => _payMode = m),
                              selectedColor: _kDark,
                              backgroundColor: Colors.white,
                              checkmarkColor: Colors.white,
                              side: BorderSide(
                                  color: selected ? _kDark : Colors.grey.shade300),
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _payNoteCtrl,
                          decoration: _inputDeco('Transaction ref / note (optional)'),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _savingPay ? null : () => _recordPayment(liveFee),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _kPrimary, foregroundColor: Colors.white,
                              shape: const StadiumBorder(),
                            ),
                            child: _savingPay
                                ? const SizedBox(width: 16, height: 16,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('Record Payment & Generate Receipt'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // ── Download receipt (shown after recording payment) ─────────
                if (_lastReceipt != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _kPrimary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _kPrimary.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.receipt_long_rounded, color: _kPrimary, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Receipt Generated',
                                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: _kDark)),
                                  Text(_lastReceipt!['receiptNumber'] as String,
                                      style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _downloadReceipt,
                            icon: const Icon(Icons.download_rounded, size: 16),
                            label: const Text('Download Receipt PDF'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _kPrimary, foregroundColor: Colors.white,
                              shape: const StadiumBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Receipt also saved to student\'s documents section.',
                          style: TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],

                // Payment history
                if (liveFee != null && liveFee.payments.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _sectionLabel('Payment History'),
                  const SizedBox(height: 8),
                  ...liveFee.payments.reversed.map((p) => _PaymentTile(
                        p: p,
                        schoolId:         widget.schoolId,
                        studentId:        widget.student.studentId,
                        studentName:      widget.student.name,
                        fatherName:       _fatherName,
                        admissionNo:      widget.student.admissionNo,
                        className:        _classOnlyName,
                        academicYear:     widget.academicYear,
                        feeComponents:    liveFee.feeComponents,
                        totalAmount:      liveFee.totalAmount,
                        remainingBalance: liveFee.totalPending,
                      )),
                ],

                // Consolidated receipt (when fully paid)
                if (liveFee != null && liveFee.isFullyPaid) ...[
                  const SizedBox(height: 16),
                  _ConsolidatedReceiptAdminButton(
                    fee: liveFee,
                    student: widget.student,
                    className: widget.className,
                    schoolId: widget.schoolId,
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─── Inline component row widget ─────────────────────────────────────────────
class _CompRowWidget extends StatelessWidget {
  final _CompRow row;
  final bool canDelete;
  final VoidCallback onDelete;
  final VoidCallback onChanged;
  const _CompRowWidget({
    required this.row,
    required this.canDelete,
    required this.onDelete,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: TextField(
              controller: row.nameCtrl,
              onChanged: (_) => onChanged(),
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Component name',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: _kDark, width: 1.5)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: TextField(
              controller: row.amtCtrl,
              onChanged: (_) => onChanged(),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Amount',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
                prefixText: '₹ ',
                prefixStyle: TextStyle(color: Colors.grey[600], fontSize: 12),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: _kDark, width: 1.5)),
              ),
            ),
          ),
          const SizedBox(width: 4),
          if (canDelete)
            IconButton(
              icon: Icon(Icons.remove_circle_outline_rounded, color: Colors.grey[400], size: 18),
              onPressed: onDelete,
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(),
            )
          else
            const SizedBox(width: 28),
        ],
      ),
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────
// Section header with left accent bar
Widget _sectionLabel(String text) => Row(
  children: [
    Container(
      width: 4,
      height: 18,
      decoration: BoxDecoration(
        color: _kDark,
        borderRadius: BorderRadius.circular(2),
      ),
    ),
    const SizedBox(width: 8),
    Text(text,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0A0F1E))),
  ],
);

InputDecoration _inputDeco(String hint) => InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _kDark)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      isDense: true,
    );

class _FeeItem extends StatelessWidget {
  final String label;
  final String value;
  final Color  color;
  const _FeeItem(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(value,
              style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11)),
        ],
      );
}

class _PaymentTile extends StatelessWidget {
  final Payment  p;
  final String   schoolId;
  final String   studentId;
  final String   studentName;
  final String   fatherName;
  final String   admissionNo;
  final String   className;
  final String   academicYear;
  final Map<String, double> feeComponents;
  final double   totalAmount;
  final double   remainingBalance;

  const _PaymentTile({
    required this.p,
    required this.schoolId,
    required this.studentId,
    required this.studentName,
    this.fatherName = '',
    this.admissionNo = '',
    required this.className,
    required this.academicYear,
    required this.feeComponents,
    required this.totalAmount,
    this.remainingBalance = 0,
  });

  IconData get _modeIcon {
    switch (p.mode) {
      case PaymentMode.CASH:   return Icons.payments_rounded;
      case PaymentMode.ONLINE: return Icons.language_rounded;
      case PaymentMode.CHEQUE: return Icons.receipt_long_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _kPrimary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kPrimary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: _kPrimary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(_modeIcon, color: _kPrimary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('₹${p.amount.toStringAsFixed(0)} via ${p.mode.name}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF0A0F1E))),
                if (p.transactionRef.isNotEmpty)
                  Text(p.transactionRef,
                      style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormat('d MMM yy').format(p.paidAt),
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
              const SizedBox(height: 4),
              _RedownloadButton(
                p:                p,
                schoolId:         schoolId,
                studentId:        studentId,
                studentName:      studentName,
                fatherName:       fatherName,
                admissionNo:      admissionNo,
                className:        className,
                academicYear:     academicYear,
                feeComponents:    feeComponents,
                totalAmount:      totalAmount,
                remainingBalance: remainingBalance,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RedownloadButton extends ConsumerStatefulWidget {
  final Payment  p;
  final String   schoolId;
  final String   studentId;
  final String   studentName;
  final String   fatherName;
  final String   admissionNo;
  final String   className;
  final String   academicYear;
  final Map<String, double> feeComponents;
  final double   totalAmount;
  final double   remainingBalance;

  const _RedownloadButton({
    required this.p,
    required this.schoolId,
    required this.studentId,
    required this.studentName,
    this.fatherName = '',
    this.admissionNo = '',
    required this.className,
    required this.academicYear,
    required this.feeComponents,
    required this.totalAmount,
    this.remainingBalance = 0,
  });

  @override
  ConsumerState<_RedownloadButton> createState() => _RedownloadButtonState();
}

class _RedownloadButtonState extends ConsumerState<_RedownloadButton> {
  bool _loading = false;

  Future<void> _download() async {
    setState(() => _loading = true);
    try {
      final fs = ref.read(firestoreServiceProvider);
      final school = await fs.getSchool(widget.schoolId);

      // Look up stored receipt number so re-downloads show the original SL number
      String receiptNumber = FeeReceiptService.buildReceiptNumber(
          widget.academicYear, widget.p.paymentId);
      try {
        final docs = await FirebaseFirestore.instance
            .collection('students')
            .doc(widget.studentId)
            .collection('studentDocuments')
            .where('paymentId', isEqualTo: widget.p.paymentId)
            .limit(1)
            .get();
        if (docs.docs.isNotEmpty) {
          final stored = docs.docs.first.data()['receiptNumber'] as String?;
          if (stored != null && stored.isNotEmpty) receiptNumber = stored;
        }
      } catch (_) {}

      final receiptData = ReceiptData(
        receiptNumber:    receiptNumber,
        schoolId:         widget.schoolId,
        schoolName:       school?.name ?? widget.schoolId,
        schoolAddress:    school?.address ?? '',
        schoolPhone:      school?.phone ?? '',
        schoolEmail:      school?.email ?? '',
        schoolLogoUrl:    school?.logoUrl ?? '',
        studentId:        widget.studentId,
        studentName:      widget.studentName,
        fatherName:       widget.fatherName,
        admissionNo:      widget.admissionNo,
        className:        widget.className,
        academicYear:     widget.academicYear,
        feeComponents:    widget.feeComponents,
        totalAmount:      widget.totalAmount,
        remainingBalance: widget.remainingBalance,
        payment:          widget.p,
      );
      final pdfBytes = await FeeReceiptService.generateReceiptPdf(receiptData);
      final safeReceipt = receiptNumber.replaceAll('/', '-');
      await Printing.sharePdf(bytes: pdfBytes, filename: '$safeReceipt.pdf');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Receipt error: $e')));
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _loading ? null : _download,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: _kDark.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(6),
        ),
        child: _loading
            ? const SizedBox(
                width: 12, height: 12,
                child: CircularProgressIndicator(color: _kDark, strokeWidth: 1.5))
            : const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.download_rounded, size: 10, color: _kDark),
                  SizedBox(width: 3),
                  Text('Receipt', style: TextStyle(fontSize: 9, color: _kDark, fontWeight: FontWeight.w600)),
                ],
              ),
      ),
    );
  }
}

// ─── Consolidated receipt button (admin) ─────────────────────────────────────
class _ConsolidatedReceiptAdminButton extends ConsumerStatefulWidget {
  final Fee    fee;
  final Student student;
  final String className;
  final String schoolId;
  const _ConsolidatedReceiptAdminButton({
    required this.fee,
    required this.student,
    required this.className,
    required this.schoolId,
  });

  @override
  ConsumerState<_ConsolidatedReceiptAdminButton> createState() =>
      _ConsolidatedReceiptAdminButtonState();
}

class _ConsolidatedReceiptAdminButtonState
    extends ConsumerState<_ConsolidatedReceiptAdminButton> {
  bool _loading = false;

  Future<void> _download() async {
    setState(() => _loading = true);
    try {
      final fs = ref.read(firestoreServiceProvider);
      final school = await fs.getSchool(widget.schoolId);

      // Fetch father name from raw student document
      String fatherName = '';
      try {
        final studentDoc = await FirebaseFirestore.instance
            .collection('students')
            .doc(widget.student.studentId)
            .get();
        fatherName = (studentDoc.data()?['fatherName'] as String?) ?? '';
      } catch (_) {}

      final receiptNumber = FeeReceiptService.buildConsolidatedReceiptNumber(
          widget.fee.academicYear, widget.student.studentId);
      final data = ConsolidatedReceiptData(
        receiptNumber: receiptNumber,
        schoolId:      widget.schoolId,
        schoolName:    school?.name ?? '',
        schoolAddress: school?.address ?? '',
        schoolPhone:   school?.phone ?? '',
        schoolEmail:   school?.email ?? '',
        schoolLogoUrl: school?.logoUrl ?? '',
        studentId:     widget.student.studentId,
        studentName:   widget.student.name,
        fatherName:    fatherName,
        admissionNo:   widget.student.admissionNo,
        className:     widget.className.split(' - ').first,
        rollNo:        widget.student.rollNo,
        academicYear:  widget.fee.academicYear,
        feeComponents: widget.fee.feeComponents,
        totalAmount:   widget.fee.totalAmount,
        totalPaid:     widget.fee.totalPaid,
        payments:      widget.fee.payments,
      );
      final pdfBytes =
          await FeeReceiptService.generateConsolidatedReceiptPdf(data);
      final safeReceipt = receiptNumber.replaceAll('/', '-');
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename:
            '${widget.student.name}-${widget.fee.academicYear}-$safeReceipt.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _loading ? null : _download,
        icon: _loading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : const Icon(Icons.download_rounded, size: 16),
        label: Text(_loading
            ? 'Generating...'
            : 'Download Full Receipt (Paid in Full)'),
        style: ElevatedButton.styleFrom(
          backgroundColor: _kPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}

// ── Apply Fees to Students Sheet ─────────────────────────────────────────────
class _ApplyFeesSheet extends StatefulWidget {
  final String schoolId;
  final String adminUid;
  final String adminName;
  final String academicYear;

  const _ApplyFeesSheet({
    required this.schoolId,
    required this.adminUid,
    required this.adminName,
    required this.academicYear,
  });

  @override
  State<_ApplyFeesSheet> createState() => _ApplyFeesSheetState();
}

class _ApplyFeesSheetState extends State<_ApplyFeesSheet> {
  final _db = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _classes = [];
  String? _selectedClassId;
  String? _selectedClassName;

  Map<String, dynamic>? _feeStructure;
  bool _loadingStructure = false;

  bool _applying = false;
  String? _error;
  String? _success;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    final snap = await _db
        .collection('classes')
        .where('schoolId', isEqualTo: widget.schoolId)
        .get();
    if (!mounted) return;
    setState(() {
      _classes = snap.docs
          .map((d) => {'id': d.id, 'name': d.data()['name'] ?? '', ...d.data()})
          .toList();
    });
  }

  Future<void> _loadFeeStructure(String classId) async {
    setState(() { _loadingStructure = true; _feeStructure = null; _error = null; });
    final snap = await _db
        .collection(FSC.feeStructure)
        .where('schoolId', isEqualTo: widget.schoolId)
        .where('classId', isEqualTo: classId)
        .where('academicYear', isEqualTo: widget.academicYear)
        .limit(1)
        .get();
    if (!mounted) return;
    setState(() {
      _feeStructure = snap.docs.isNotEmpty ? snap.docs.first.data() : null;
      _loadingStructure = false;
    });
  }

  Future<void> _applyFees() async {
    if (_selectedClassId == null || _feeStructure == null) return;
    setState(() { _applying = true; _error = null; _success = null; });
    try {
      // Get all active students in the class
      final studentsSnap = await _db
          .collection('students')
          .where('schoolId', isEqualTo: widget.schoolId)
          .where('classId', isEqualTo: _selectedClassId)
          .where('isActive', isEqualTo: true)
          .get();

      final components = Map<String, dynamic>.from(
          (_feeStructure!['components'] as List<dynamic>? ?? [])
              .fold<Map<String, dynamic>>({}, (map, c) {
        final comp = c as Map<String, dynamic>;
        map[comp['name'] as String] = (comp['amount'] as num).toDouble();
        return map;
      }));
      final totalFee = (_feeStructure!['totalFee'] as num?)?.toDouble() ?? 0.0;
      final academicYear = _feeStructure!['academicYear'] as String? ?? widget.academicYear;

      int assigned = 0;
      for (final student in studentsSnap.docs) {
        final studentId = student.id;
        final feeDocId =
            '${widget.schoolId}_${studentId}_${academicYear.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')}';

        // Skip if fee record already exists
        final existing = await _db.collection('fees').doc(feeDocId).get();
        if (existing.exists) continue;

        await _db.collection('fees').doc(feeDocId).set({
          'schoolId':      widget.schoolId,
          'studentId':     studentId,
          'studentName':   student.data()['name'] ?? '',
          'className':     _selectedClassName ?? '',
          'classId':       _selectedClassId,
          'totalAmount':   totalFee,
          'totalPaid':     0.0,
          'totalPending':  totalFee,
          'feeComponents': components,
          'academicYear':  academicYear,
          'payments':      [],
          'createdAt':     FieldValue.serverTimestamp(),
          'createdBy':     widget.adminUid,
          'createdByName': widget.adminName,
        });
        assigned++;
      }

      if (mounted) {
        setState(() {
          _success = 'Fee applied to $assigned student${assigned != 1 ? 's' : ''}.'
              '${studentsSnap.docs.length - assigned > 0 ? ' ${studentsSnap.docs.length - assigned} already had a fee record.' : ''}';
          _applying = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _error = 'Failed: $e'; _applying = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final components = (_feeStructure?['components'] as List<dynamic>?) ?? [];
    final totalFee = (_feeStructure?['totalFee'] as num?)?.toDouble() ?? 0.0;
    final fmt = NumberFormat('##,##,##0', 'en_IN');

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text('Apply Fees to Students',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _kDark)),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Text('Academic Year: ${widget.academicYear}',
                style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            const SizedBox(height: 20),

            // Class selector
            const Text('Select Class',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _kDark)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _selectedClassId,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                isDense: true,
              ),
              hint: const Text('Choose a class', style: TextStyle(fontSize: 13)),
              items: _classes.map((c) {
                final name = c['name'] as String;
                final section = (c['section'] as String?) ?? '';
                final label = section.isNotEmpty ? '$name-$section' : name;
                return DropdownMenuItem(value: c['id'] as String, child: Text(label, style: const TextStyle(fontSize: 13)));
              }).toList(),
              onChanged: (id) {
                if (id == null) return;
                final cls = _classes.firstWhere((c) => c['id'] == id);
                final name = cls['name'] as String;
                final section = (cls['section'] as String?) ?? '';
                setState(() {
                  _selectedClassId = id;
                  _selectedClassName = section.isNotEmpty ? '$name-$section' : name;
                  _feeStructure = null;
                  _error = null;
                  _success = null;
                });
                _loadFeeStructure(id);
              },
            ),

            const SizedBox(height: 16),

            // Fee structure preview
            if (_loadingStructure)
              const Center(child: CircularProgressIndicator(color: _kPrimary))
            else if (_selectedClassId != null && _feeStructure == null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: const Text(
                  'No fee structure found for this class and academic year.\nPlease set the fee structure first.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF92400E)),
                ),
              )
            else if (_feeStructure != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _kPrimary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _kPrimary.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Fee Structure',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _kDark)),
                    const SizedBox(height: 8),
                    ...components.map((c) {
                      final comp = c as Map<String, dynamic>;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(comp['name'] as String? ?? '',
                                style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                            Text('₹${fmt.format((comp['amount'] as num?)?.toDouble() ?? 0)}',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      );
                    }),
                    const Divider(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        Text('₹${fmt.format(totalFee)}',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: _kPrimary)),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
            ],
            if (_success != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_success!, style: const TextStyle(fontSize: 13, color: Color(0xFF065F46)))),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_feeStructure == null || _applying)
                    ? null
                    : _applyFees,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _applying
                    ? const SizedBox(
                        height: 18, width: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Apply Fees to All Students',
                        style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
