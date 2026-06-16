import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firestore_constants.dart';

const _kPrimary = Color(0xFFDC2626);
const _kDark    = Color(0xFF7F1D1D);
const _kGreen   = Color(0xFF059669);
const _kNavy    = Color(0xFF0A0F1E);

// ── Component row model ───────────────────────────────────────────────────────
class _ComponentRow {
  final TextEditingController nameCtrl;
  final TextEditingController amountCtrl;
  _ComponentRow({String name = '', String amount = ''})
      : nameCtrl  = TextEditingController(text: name),
        amountCtrl = TextEditingController(text: amount);
  void dispose() {
    nameCtrl.dispose();
    amountCtrl.dispose();
  }
}

// ── Suggested component names ────────────────────────────────────────────────
const _kSuggestions = [
  'Tuition Fee',
  'Transport Fee',
  'Lab Fee',
  'Sports Fee',
  'Library Fee',
  'Exam Fee',
  'Activity Fee',
  'Development Fee',
];

class SetFeeScreen extends StatefulWidget {
  final String schoolId;
  final String adminUid;
  final String academicYear;
  const SetFeeScreen({
    super.key,
    required this.schoolId,
    required this.adminUid,
    required this.academicYear,
  });

  @override
  State<SetFeeScreen> createState() => _SetFeeScreenState();
}

class _SetFeeScreenState extends State<SetFeeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF1F2),
      appBar: AppBar(
        backgroundColor: _kDark,
        foregroundColor: Colors.white,
        title: const Text('Set Fee',
            style: TextStyle(fontWeight: FontWeight.w700)),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          tabs: const [
            Tab(text: 'By Class'),
            Tab(text: 'Individual Student'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _ByClassTab(
            schoolId:     widget.schoolId,
            adminUid:     widget.adminUid,
            academicYear: widget.academicYear,
          ),
          _ByStudentTab(
            schoolId:     widget.schoolId,
            adminUid:     widget.adminUid,
            academicYear: widget.academicYear,
          ),
        ],
      ),
    );
  }
}

// ── By Class Tab ──────────────────────────────────────────────────────────────
class _ByClassTab extends StatefulWidget {
  final String schoolId;
  final String adminUid;
  final String academicYear;
  const _ByClassTab({
    required this.schoolId,
    required this.adminUid,
    required this.academicYear,
  });

  @override
  State<_ByClassTab> createState() => _ByClassTabState();
}

class _ByClassTabState extends State<_ByClassTab> {
  String? _selectedClassId;
  String? _selectedClassName;
  final List<_ComponentRow> _components = [];
  bool _isSaving   = false;
  String? _error;
  String? _successMsg;
  List<QueryDocumentSnapshot> _classDocs = [];

  @override
  void initState() {
    super.initState();
    _components.add(_ComponentRow());
  }

  @override
  void dispose() {
    for (final c in _components) {
      c.dispose();
    }
    super.dispose();
  }

  double get _total => _components.fold(0.0, (acc, c) {
    return acc + (double.tryParse(c.amountCtrl.text.trim()) ?? 0.0);
  });

  Map<String, double> _buildComponentMap() {
    final map = <String, double>{};
    for (final c in _components) {
      final name   = c.nameCtrl.text.trim();
      final amount = double.tryParse(c.amountCtrl.text.trim()) ?? 0.0;
      if (name.isNotEmpty && amount > 0) map[name] = amount;
    }
    return map;
  }

  Future<void> _save(List<QueryDocumentSnapshot> students) async {
    if (_selectedClassId == null) {
      setState(() => _error = 'Select a class first');
      return;
    }
    final components = _buildComponentMap();
    if (components.isEmpty) {
      setState(() => _error = 'Add at least one fee component with amount > 0');
      return;
    }
    if (students.isEmpty) {
      setState(() => _error = 'No active students in this class');
      return;
    }
    final total = components.values.fold(0.0, (a, b) => a + b);
    setState(() { _isSaving = true; _error = null; _successMsg = null; });
    try {
      final db    = FirebaseFirestore.instance;
      final batch = db.batch();
      for (final doc in students) {
        final sData      = doc.data() as Map<String, dynamic>;
        final studentId  = doc.id;
        final studentName = (sData['name'] as String?) ?? '';
        final existing = await db
            .collection(FSC.fees)
            .where('studentId', isEqualTo: studentId)
            .where('academicYear', isEqualTo: widget.academicYear)
            .limit(1)
            .get();
        if (existing.docs.isNotEmpty) {
          final feeDoc  = existing.docs.first;
          final paid    = ((feeDoc['totalPaid']  as num?) ?? 0).toDouble();
          final newPend = (total - paid).clamp(0, double.infinity);
          batch.update(feeDoc.reference, {
            'totalAmount':    total,
            'feeComponents':  components,
            'totalPending':   newPend,
            'updatedAt':      Timestamp.now(),
          });
        } else {
          final ref = db.collection(FSC.fees).doc();
          batch.set(ref, {
            'feeId':          ref.id,
            'schoolId':       widget.schoolId,
            'studentId':      studentId,
            'studentName':    studentName,
            'classId':        _selectedClassId,
            'className':      _selectedClassName ?? '',
            'academicYear':   widget.academicYear,
            'feeComponents':  components,
            'totalAmount':    total,
            'totalPaid':      0.0,
            'totalPending':   total,
            'payments':       [],
            'feeHeads':       [],
            'updatedAt':      Timestamp.now(),
          });
        }
      }
      await batch.commit();
      if (mounted) {
        setState(() {
          _isSaving   = false;
          _successMsg =
              'Fee ₹${total.toStringAsFixed(0)} (${components.length} components) set for ${students.length} student${students.length == 1 ? '' : 's'} in ${_selectedClassName ?? ''}';
        });
      }
    } catch (e) {
      if (mounted) setState(() { _isSaving = false; _error = 'Failed: $e'; });
    }
  }

  void _addComponent() {
    setState(() => _components.add(_ComponentRow()));
  }

  void _removeComponent(int index) {
    if (_components.length <= 1) return;
    _components[index].dispose();
    setState(() => _components.removeAt(index));
  }

  void _showSuggestions(int index) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Quick add',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _kSuggestions.map((s) => GestureDetector(
                onTap: () {
                  setState(() => _components[index].nameCtrl.text = s);
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _kPrimary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: _kPrimary.withValues(alpha: 0.25)),
                  ),
                  child: Text(s,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _kPrimary)),
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(FSC.classes)
          .where('schoolId', isEqualTo: widget.schoolId)
          .snapshots(),
      builder: (ctx, classSnap) {
        if (classSnap.connectionState == ConnectionState.waiting &&
            _classDocs.isEmpty) {
          return const Center(
              child: CircularProgressIndicator(color: _kPrimary));
        }
        if (classSnap.hasData) {
          _classDocs = classSnap.data!.docs
              .where((d) => (d.data() as Map)['isActive'] != false)
              .toList();
          _classDocs.sort((a, b) {
            final aName = ((a.data() as Map)['name'] as String?) ?? '';
            final bName = ((b.data() as Map)['name'] as String?) ?? '';
            return aName.compareTo(bName);
          });
        }

        return StreamBuilder<QuerySnapshot>(
          stream: _selectedClassId == null
              ? null
              : FirebaseFirestore.instance
                  .collection(FSC.students)
                  .where('classId', isEqualTo: _selectedClassId)
                  .where('isActive', isEqualTo: true)
                  .snapshots(),
          builder: (ctx2, sSnap) {
            final students = sSnap.data?.docs ?? [];
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select Class',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _kNavy)),
                  const SizedBox(height: 10),
                  if (_classDocs.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Text(
                        classSnap.connectionState == ConnectionState.waiting
                            ? 'Loading classes…'
                            : 'No classes found for this school',
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey[500]),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedClassId,
                        isExpanded: true,
                        underline: const SizedBox.shrink(),
                        hint: Text('Choose class',
                            style: TextStyle(
                                color: Colors.grey[400], fontSize: 14)),
                        items: _classDocs.map((d) {
                          final data  = d.data() as Map<String, dynamic>;
                          final label = (data['name'] as String?) ?? d.id;
                          return DropdownMenuItem(
                              value: d.id, child: Text(label));
                        }).toList(),
                        onChanged: (v) {
                          if (v == null) return;
                          final data = _classDocs
                              .firstWhere((d) => d.id == v)
                              .data() as Map<String, dynamic>;
                          setState(() {
                            _selectedClassId   = v;
                            _selectedClassName =
                                (data['name'] as String?) ?? v;
                            _successMsg = null;
                            _error      = null;
                          });
                        },
                      ),
                    ),
                  const SizedBox(height: 16),
                  if (_selectedClassId != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _kNavy.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.class_rounded,
                              size: 16, color: _kNavy),
                          const SizedBox(width: 8),
                          Text(
                            '${students.length} student${students.length == 1 ? '' : 's'} in $_selectedClassName',
                            style: const TextStyle(
                                fontSize: 12,
                                color: _kNavy,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Fee Components ─────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Fee Components',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _kNavy)),
                      TextButton.icon(
                        onPressed: _addComponent,
                        icon: const Icon(Icons.add_rounded,
                            size: 16, color: _kPrimary),
                        label: const Text('Add',
                            style: TextStyle(
                                color: _kPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w700)),
                        style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(_components.length, (i) =>
                    _ComponentRowWidget(
                      row:        _components[i],
                      index:      i,
                      canDelete:  _components.length > 1,
                      onDelete:   () => _removeComponent(i),
                      onSuggest:  () => _showSuggestions(i),
                      onChanged:  () => setState(() {}),
                    ),
                  ),

                  // ── Total ──────────────────────────────────────────────
                  const SizedBox(height: 8),
                  _TotalBanner(total: _total),
                  const SizedBox(height: 12),

                  if (_error != null) ...[
                    Text(_error!,
                        style: const TextStyle(
                            color: _kPrimary, fontSize: 12)),
                    const SizedBox(height: 8),
                  ],
                  if (_successMsg != null) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _kGreen.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: _kGreen.withValues(alpha: 0.3)),
                      ),
                      child: Text(_successMsg!,
                          style: const TextStyle(
                              color: _kGreen,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 8),
                  ],
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : () => _save(students),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kPrimary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text('Set Fee for Class',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ── By Student Tab ────────────────────────────────────────────────────────────
class _ByStudentTab extends StatefulWidget {
  final String schoolId;
  final String adminUid;
  final String academicYear;
  const _ByStudentTab({
    required this.schoolId,
    required this.adminUid,
    required this.academicYear,
  });

  @override
  State<_ByStudentTab> createState() => _ByStudentTabState();
}

class _ByStudentTabState extends State<_ByStudentTab> {
  final _searchCtrl = TextEditingController();
  String _query     = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openFeeEditor(String studentId, String studentName, String classId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _StudentFeeEditor(
        studentId:    studentId,
        studentName:  studentName,
        classId:      classId,
        schoolId:     widget.schoolId,
        academicYear: widget.academicYear,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(FSC.students)
          .where('schoolId', isEqualTo: widget.schoolId)
          .where('isActive', isEqualTo: true)
          .snapshots(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: _kPrimary));
        }
        final allDocs = snap.data?.docs ?? [];
        final filtered = _query.isEmpty
            ? allDocs
            : allDocs.where((d) {
                final name = ((d.data() as Map)['name'] as String? ?? '')
                    .toLowerCase();
                final admNo = ((d.data() as Map)['admissionNo'] as String? ?? '')
                    .toLowerCase();
                return name.contains(_query) || admNo.contains(_query);
              }).toList();

        return Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() {
                  _query = v.trim().toLowerCase();
                }),
                decoration: InputDecoration(
                  hintText: 'Search by name or admission no…',
                  hintStyle: TextStyle(
                      color: Colors.grey[400], fontSize: 13),
                  prefixIcon: Icon(Icons.search_rounded,
                      color: Colors.grey[400], size: 20),
                  suffixIcon: _query.isNotEmpty
                      ? GestureDetector(
                          onTap: () => setState(() {
                            _searchCtrl.clear();
                            _query = '';
                          }),
                          child: Icon(Icons.clear_rounded,
                              color: Colors.grey[400], size: 18),
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                ),
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        _query.isEmpty
                            ? 'No students found'
                            : 'No students match "$_query"',
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey[400]),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final doc       = filtered[i];
                        final data      = doc.data() as Map<String, dynamic>;
                        final name      = (data['name'] as String?) ?? 'Student';
                        final admNo     = (data['admissionNo'] as String?) ?? '';
                        final classId   = (data['classId'] as String?) ?? '';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(name,
                                        style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: _kNavy)),
                                    if (admNo.isNotEmpty)
                                      Text('Adm: $admNo',
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey[500])),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _openFeeEditor(
                                    doc.id, name, classId),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _kPrimary.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: _kPrimary.withValues(alpha: 0.25)),
                                  ),
                                  child: const Text('Set Fee',
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: _kPrimary)),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

// ── Student Fee Editor (bottom sheet) ────────────────────────────────────────
class _StudentFeeEditor extends StatefulWidget {
  final String studentId;
  final String studentName;
  final String classId;
  final String schoolId;
  final String academicYear;
  const _StudentFeeEditor({
    required this.studentId,
    required this.studentName,
    required this.classId,
    required this.schoolId,
    required this.academicYear,
  });

  @override
  State<_StudentFeeEditor> createState() => _StudentFeeEditorState();
}

class _StudentFeeEditorState extends State<_StudentFeeEditor> {
  final List<_ComponentRow> _components = [];
  bool   _loading  = true;
  bool   _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  @override
  void dispose() {
    for (final c in _components) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadExisting() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection(FSC.fees)
          .where('studentId', isEqualTo: widget.studentId)
          .where('academicYear', isEqualTo: widget.academicYear)
          .limit(1)
          .get();
      if (snap.docs.isNotEmpty) {
        final data = snap.docs.first.data();
        final raw  = (data['feeComponents'] as Map<String, dynamic>?) ?? {};
        if (raw.isNotEmpty) {
          for (final entry in raw.entries) {
            _components.add(_ComponentRow(
                name:   entry.key,
                amount: (entry.value as num).toDouble().toStringAsFixed(0)));
          }
        }
      }
    } catch (_) {}
    if (_components.isEmpty) _components.add(_ComponentRow());
    if (mounted) setState(() => _loading = false);
  }

  double get _total => _components.fold(0.0, (acc, c) {
    return acc + (double.tryParse(c.amountCtrl.text.trim()) ?? 0.0);
  });

  Map<String, double> _buildComponentMap() {
    final map = <String, double>{};
    for (final c in _components) {
      final name   = c.nameCtrl.text.trim();
      final amount = double.tryParse(c.amountCtrl.text.trim()) ?? 0.0;
      if (name.isNotEmpty && amount > 0) map[name] = amount;
    }
    return map;
  }

  Future<void> _save() async {
    final components = _buildComponentMap();
    if (components.isEmpty) {
      setState(() => _error = 'Add at least one component with amount > 0');
      return;
    }
    final total = components.values.fold(0.0, (a, b) => a + b);
    setState(() { _isSaving = true; _error = null; });
    try {
      final db = FirebaseFirestore.instance;
      final existing = await db
          .collection(FSC.fees)
          .where('studentId', isEqualTo: widget.studentId)
          .where('academicYear', isEqualTo: widget.academicYear)
          .limit(1)
          .get();
      if (existing.docs.isNotEmpty) {
        final feeDoc  = existing.docs.first;
        final paid    = ((feeDoc['totalPaid'] as num?) ?? 0).toDouble();
        final newPend = (total - paid).clamp(0, double.infinity);
        await feeDoc.reference.update({
          'feeComponents': components,
          'totalAmount':   total,
          'totalPending':  newPend,
          'updatedAt':     Timestamp.now(),
        });
      } else {
        final ref = db.collection(FSC.fees).doc();
        await ref.set({
          'feeId':          ref.id,
          'schoolId':       widget.schoolId,
          'studentId':      widget.studentId,
          'studentName':    widget.studentName,
          'classId':        widget.classId,
          'academicYear':   widget.academicYear,
          'feeComponents':  components,
          'totalAmount':    total,
          'totalPaid':      0.0,
          'totalPending':   total,
          'payments':       [],
          'feeHeads':       [],
          'updatedAt':      Timestamp.now(),
        });
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) setState(() { _isSaving = false; _error = 'Failed: $e'; });
    }
  }

  void _showSuggestions(int index) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Quick add',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _kSuggestions.map((s) => GestureDetector(
                onTap: () {
                  setState(() => _components[index].nameCtrl.text = s);
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _kPrimary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: _kPrimary.withValues(alpha: 0.25)),
                  ),
                  child: Text(s,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _kPrimary)),
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85),
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: _kPrimary))
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: _kGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.person_rounded,
                            color: _kGreen, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.studentName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: _kNavy)),
                            const Text('Set fee components',
                                style: TextStyle(
                                    fontSize: 12, color: Color(0xFF6B7280))),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Components',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _kNavy)),
                      TextButton.icon(
                        onPressed: () =>
                            setState(() => _components.add(_ComponentRow())),
                        icon: const Icon(Icons.add_rounded,
                            size: 16, color: _kPrimary),
                        label: const Text('Add',
                            style: TextStyle(
                                color: _kPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w700)),
                        style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          ...List.generate(_components.length, (i) =>
                            _ComponentRowWidget(
                              row:       _components[i],
                              index:     i,
                              canDelete: _components.length > 1,
                              onDelete:  () {
                                _components[i].dispose();
                                setState(() => _components.removeAt(i));
                              },
                              onSuggest: () => _showSuggestions(i),
                              onChanged: () => setState(() {}),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _TotalBanner(total: _total),
                        ],
                      ),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Text(_error!,
                        style: const TextStyle(
                            color: _kPrimary, fontSize: 12)),
                  ],
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kPrimary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : Text(
                              'Save  ₹${_total.toStringAsFixed(0)}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15)),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ── Shared Widgets ────────────────────────────────────────────────────────────
class _ComponentRowWidget extends StatelessWidget {
  final _ComponentRow row;
  final int index;
  final bool canDelete;
  final VoidCallback onDelete;
  final VoidCallback onSuggest;
  final VoidCallback onChanged;
  const _ComponentRowWidget({
    required this.row,
    required this.index,
    required this.canDelete,
    required this.onDelete,
    required this.onSuggest,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: GestureDetector(
              onLongPress: onSuggest,
              child: TextField(
                controller: row.nameCtrl,
                onChanged: (_) => onChanged(),
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Component name',
                  hintStyle: TextStyle(
                      color: Colors.grey[400], fontSize: 12),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 10),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: _kPrimary, width: 1.5)),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.lightbulb_outline_rounded,
                        size: 14, color: Colors.grey[400]),
                    onPressed: onSuggest,
                    tooltip: 'Suggestions',
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: TextField(
              controller: row.amountCtrl,
              onChanged: (_) => onChanged(),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Amount',
                hintStyle: TextStyle(
                    color: Colors.grey[400], fontSize: 12),
                prefixText: '₹ ',
                prefixStyle: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 10),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: _kPrimary, width: 1.5)),
              ),
            ),
          ),
          const SizedBox(width: 4),
          if (canDelete)
            IconButton(
              icon: Icon(Icons.remove_circle_outline_rounded,
                  color: Colors.grey[400], size: 20),
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

class _TotalBanner extends StatelessWidget {
  final double total;
  const _TotalBanner({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_kNavy, _kNavy.withValues(alpha: 0.85)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Total Annual Fee',
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
          Text(
            '₹ ${total.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

