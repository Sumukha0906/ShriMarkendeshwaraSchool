import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/models/student.dart';
import '../../../core/models/class_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/constants/firestore_constants.dart';

// ─── Admin Student Detail Screen ─────────────────────────────────────────────
// Shows full student info + documents (admin/principal/management only)
// Documents section is hidden from teachers.

const _kPrimary = Color(0xFF065F46);
const _kDark    = Color(0xFF022C22);
const _kBg      = Color(0xFFF0FDF4);
const _kAmber   = Color(0xFFF59E0B);
const _kGreen   = Color(0xFF059669);
const _kRed     = Color(0xFFEF4444);
const _kNavy    = Color(0xFF0A0F1E);

const _kDocTypes = [
  'Aadhaar Card',
  'PAN Card',
  'Birth Certificate',
  'Transfer Certificate',
  'Marksheet',
  'Passport',
  'Caste Certificate',
  'Medical Certificate',
  'Other',
];

class AdminStudentDetailScreen extends ConsumerStatefulWidget {
  final Student student;

  const AdminStudentDetailScreen({super.key, required this.student});

  @override
  ConsumerState<AdminStudentDetailScreen> createState() =>
      _AdminStudentDetailScreenState();
}

class _AdminStudentDetailScreenState
    extends ConsumerState<AdminStudentDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  Map<String, dynamic>? _extraData;
  bool _loadingExtra = true;
  Map<String, dynamic>? _feeData;
  bool _loadingFee = true;
  List<ClassModel> _classes = [];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    _loadExtra();
    _loadFee();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadClasses());
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _loadClasses() async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;
    final classes = await ref
        .read(firestoreServiceProvider)
        .streamSchoolClasses(user.schoolId)
        .first;
    if (mounted) setState(() => _classes = classes);
  }

  void _showTransferSheet(BuildContext ctx, UserModel user) {
    final otherClasses = _classes
        .where((c) => c.classId != widget.student.classId)
        .toList();

    if (otherClasses.isEmpty) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text('No other classes available to transfer to.')),
      );
      return;
    }

    String? selectedClassId;
    // Declared outside the builder so it persists across StatefulBuilder
    // rebuilds — if declared inside, setSheetState resets it to false.
    bool saving = false;

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (sheetCtx, setSheetState) {
          Future<void> doTransfer() async {
            if (selectedClassId == null) return;
            setSheetState(() => saving = true);
            try {
              final fromClass = _classes.where((c) => c.classId == widget.student.classId).firstOrNull;
              final toClass   = _classes.where((c) => c.classId == selectedClassId).firstOrNull;
              await ref.read(firestoreServiceProvider).transferStudentClass(
                    studentId:        widget.student.studentId,
                    oldClassId:       widget.student.classId,
                    newClassId:       selectedClassId!,
                    transferredByUid: user.uid,
                    oldClassName:     fromClass?.name ?? '',
                    newClassName:     toClass?.name ?? '',
                    transferredByName: user.name,
                  );
              // Use sheetCtx.mounted — ctx (parent screen) may rebuild due to
              // Firestore stream updates after the transfer, making it stale.
              if (sheetCtx.mounted) {
                Navigator.pop(sheetCtx);
              }
              if (ctx.mounted) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(
                    content: Text('${widget.student.name} transferred successfully'),
                    backgroundColor: _kGreen,
                  ),
                );
              }
            } catch (e) {
              if (ctx.mounted) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: _kRed,
                  ),
                );
              }
              setSheetState(() => saving = false);
            }
          }

          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.fromLTRB(
                20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Transfer to Class',
                    style: TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w800,
                        color: _kNavy)),
                const SizedBox(height: 4),
                Text('Moving: ${widget.student.name}',
                    style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                const SizedBox(height: 16),
                ...otherClasses.map((cls) {
                  final picked = selectedClassId == cls.classId;
                  return GestureDetector(
                    onTap: () => setSheetState(() => selectedClassId = cls.classId),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: picked
                            ? _kPrimary.withValues(alpha: 0.08)
                            : const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: picked ? _kPrimary : const Color(0xFFE5E7EB),
                            width: picked ? 2 : 1),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.class_rounded,
                              color: picked ? _kPrimary : Colors.grey[400],
                              size: 18),
                          const SizedBox(width: 10),
                          Text(cls.displayName,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: picked ? _kPrimary : _kNavy)),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: (saving || selectedClassId == null)
                        ? null
                        : doTransfer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kPrimary,
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                    ),
                    child: saving
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5))
                        : const Text('Transfer Student',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 15)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _loadExtra() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(FSC.students)
          .doc(widget.student.studentId)
          .get();
      if (mounted) {
        setState(() {
          _extraData = doc.data();
          _loadingExtra = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingExtra = false);
    }
  }

  Future<void> _loadFee() async {
    try {
      const academicYear = '2026-27';
      final snap = await FirebaseFirestore.instance
          .collection(FSC.fees)
          .where('schoolId', isEqualTo: widget.student.schoolId)
          .where('studentId', isEqualTo: widget.student.studentId)
          .where('academicYear', isEqualTo: academicYear)
          .limit(1)
          .get();
      if (mounted) {
        setState(() {
          _feeData = snap.docs.isNotEmpty
              ? snap.docs.first.data()
              : null;
          _loadingFee = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingFee = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.value;
    final canViewDocs = user != null &&
        (user.role == UserRole.ADMIN ||
            user.role == UserRole.PRINCIPAL ||
            user.role == UserRole.MANAGEMENT ||
            user.role == UserRole.SUPER_ADMIN);

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kDark,
        foregroundColor: Colors.white,
        title: Text(
          widget.student.name,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          if (user != null &&
              (user.role == UserRole.PRINCIPAL ||
                  user.role == UserRole.SUPER_ADMIN))
            IconButton(
              icon: const Icon(Icons.swap_horiz_rounded),
              tooltip: 'Transfer Class',
              onPressed: () => _showTransferSheet(context, user),
            ),
        ],
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: _kAmber,
          labelColor: _kAmber,
          unselectedLabelColor: Colors.white60,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          tabs: [
            const Tab(text: 'Profile'),
            const Tab(text: 'Parents'),
            if (canViewDocs) const Tab(text: 'Documents'),
            if (!canViewDocs) const Tab(text: 'Medical'),
            const Tab(text: 'Fee'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _ProfileTab(
              student: widget.student, extraData: _extraData,
              loading: _loadingExtra),
          _ParentsTab(extraData: _extraData, loading: _loadingExtra),
          if (canViewDocs)
            _DocumentsTab(student: widget.student, user: user)
          else
            _MedicalTab(student: widget.student),
          _FeeTab(feeData: _feeData, loading: _loadingFee),
        ],
      ),
    );
  }
}

// ── Profile Tab ──────────────────────────────────────────────────────────────
class _ProfileTab extends StatelessWidget {
  final Student student;
  final Map<String, dynamic>? extraData;
  final bool loading;

  const _ProfileTab(
      {required this.student, required this.extraData, required this.loading});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar header
          Center(
            child: Column(
              children: [
                const SizedBox(height: 8),
                student.photoUrl.isNotEmpty
                    ? CircleAvatar(
                        radius: 44,
                        backgroundImage: NetworkImage(student.photoUrl),
                      )
                    : Container(
                        width: 88,
                        height: 88,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [_kPrimary, _kDark],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            student.name.isNotEmpty
                                ? student.name[0].toUpperCase()
                                : 'S',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                const SizedBox(height: 10),
                Text(
                  student.name,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: _kNavy),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Badge(
                      label: student.isActive ? 'Active' : 'Inactive',
                      color: student.isActive ? _kGreen : _kRed,
                    ),
                    const SizedBox(width: 8),
                    _Badge(label: student.academicYear, color: _kPrimary),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _SectionCard(
            title: 'Personal Details',
            icon: Icons.person_rounded,
            children: [
              _InfoRow('Admission No', student.admissionNo),
              _InfoRow('Roll No', student.rollNo),
              _InfoRow('Date of Birth', student.dob),
              _InfoRow('Gender', student.gender),
              _InfoRow('Address', student.address),
              _InfoRow('Academic Year', student.academicYear),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Medical',
            icon: Icons.medical_services_rounded,
            children: [
              _InfoRow('Blood Group',
                  student.medicalHistory.bloodGroup.isEmpty
                      ? '—'
                      : student.medicalHistory.bloodGroup),
              if (student.medicalHistory.allergies.isNotEmpty)
                _InfoRow('Allergies',
                    student.medicalHistory.allergies.join(', ')),
              if (student.medicalHistory.conditions.isNotEmpty)
                _InfoRow('Conditions',
                    student.medicalHistory.conditions.join(', ')),
              if (student.medicalHistory.vaccinationNotes.isNotEmpty)
                _InfoRow('Vaccination Notes',
                    student.medicalHistory.vaccinationNotes),
            ],
          ),
          if (student.medicalHistory.emergencyContact != null) ...[
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Emergency Contact',
              icon: Icons.emergency_rounded,
              children: [
                _InfoRow('Name',
                    student.medicalHistory.emergencyContact!.name),
                _InfoRow('Phone',
                    student.medicalHistory.emergencyContact!.phone),
                _InfoRow('Relation',
                    student.medicalHistory.emergencyContact!.relation),
              ],
            ),
          ],
          // Class transfer history
          Builder(builder: (context) {
            final history = ((extraData?['classHistory']) as List?)
                ?.map((e) => e as Map<String, dynamic>)
                .toList() ?? [];
            if (history.isEmpty) return const SizedBox.shrink();
            return Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.swap_horiz_rounded,
                              size: 16, color: _kPrimary),
                          SizedBox(width: 6),
                          Text('Class Transfer History',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _kPrimary)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ...history.reversed.map((h) {
                        final from = (h['fromClassName'] as String?) ?? '';
                        final to   = (h['toClassName']   as String?) ?? '';
                        final by   = (h['transferredByName'] as String?) ?? '';
                        final ts   = h['transferredAt'] as Timestamp?;
                        final dateStr = ts != null
                            ? '${ts.toDate().day}/${ts.toDate().month}/${ts.toDate().year}'
                            : '';
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 8, height: 8,
                                margin: const EdgeInsets.only(top: 5, right: 8),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _kPrimary,
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${from.isEmpty ? "No class" : from} → $to',
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: _kNavy),
                                    ),
                                    if (dateStr.isNotEmpty || by.isNotEmpty)
                                      Text(
                                        [if (dateStr.isNotEmpty) dateStr, if (by.isNotEmpty) 'by $by'].join(' · '),
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[500]),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Parents Tab ──────────────────────────────────────────────────────────────
class _ParentsTab extends StatelessWidget {
  final Map<String, dynamic>? extraData;
  final bool loading;

  const _ParentsTab({required this.extraData, required this.loading});

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(
          child: CircularProgressIndicator(color: _kPrimary));
    }
    final motherName =
        (extraData?['motherName'] as String?) ?? '—';
    final motherPhone =
        (extraData?['motherPhone'] as String?) ?? '—';
    final fatherName =
        (extraData?['fatherName'] as String?) ?? '—';
    final fatherPhone =
        (extraData?['fatherPhone'] as String?) ?? '—';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 8),
          _SectionCard(
            title: 'Mother',
            icon: Icons.woman_rounded,
            iconColor: const Color(0xFFDB2777),
            children: [
              _InfoRow('Name', motherName),
              _InfoRow('Phone', motherPhone),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Father',
            icon: Icons.man_rounded,
            iconColor: const Color(0xFF2563EB),
            children: [
              _InfoRow('Name', fatherName),
              _InfoRow('Phone', fatherPhone),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Medical Tab (for non-admin roles) ────────────────────────────────────────
class _MedicalTab extends StatelessWidget {
  final Student student;
  const _MedicalTab({required this.student});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 8),
          _SectionCard(
            title: 'Medical Information',
            icon: Icons.medical_services_rounded,
            children: [
              _InfoRow('Blood Group',
                  student.medicalHistory.bloodGroup.isEmpty
                      ? '—'
                      : student.medicalHistory.bloodGroup),
              if (student.medicalHistory.allergies.isNotEmpty)
                _InfoRow('Allergies',
                    student.medicalHistory.allergies.join(', ')),
              if (student.medicalHistory.conditions.isNotEmpty)
                _InfoRow('Conditions',
                    student.medicalHistory.conditions.join(', ')),
              if (student.medicalHistory.vaccinationNotes.isNotEmpty)
                _InfoRow('Vaccination Notes',
                    student.medicalHistory.vaccinationNotes),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Documents Tab ────────────────────────────────────────────────────────────
class _DocumentsTab extends ConsumerStatefulWidget {
  final Student student;
  final UserModel user;
  const _DocumentsTab({required this.student, required this.user});

  @override
  ConsumerState<_DocumentsTab> createState() => _DocumentsTabState();
}

class _DocumentsTabState extends ConsumerState<_DocumentsTab> {
  bool _uploading = false;
  String _uploadProgress = '';

  Future<void> _uploadDocument() async {
    // Pick doctype + optional custom name
    String? selectedType;
    String customName = '';
    final nameCtrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) {
        String? picked;
        return StatefulBuilder(
          builder: (ctx, setSt) => AlertDialog(
            title: const Text('Select Document Type'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ..._kDocTypes.map((t) => ListTile(
                        dense: true,
                        title: Text(t, style: const TextStyle(fontSize: 14)),
                        leading: Icon(
                          picked == t ? Icons.radio_button_checked : Icons.radio_button_off,
                          color: picked == t ? _kPrimary : Colors.grey,
                          size: 20,
                        ),
                        onTap: () => setSt(() => picked = t),
                      )),
                  const Divider(height: 16),
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Document Name (optional)',
                      hintText: 'e.g. Mother, Father, Self',
                      helperText: 'Will be saved as "Aadhaar Card Mother" etc.',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (_) => setSt(() {}),
                  ),
                  if (picked != null && nameCtrl.text.trim().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Will save as: "$picked ${nameCtrl.text.trim()}"',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: picked == null ? null : () {
                  selectedType = picked;
                  customName   = nameCtrl.text.trim();
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(backgroundColor: _kPrimary, foregroundColor: Colors.white),
                child: const Text('Next'),
              ),
            ],
          ),
        );
      },
    );
    if (selectedType == null || !mounted) { nameCtrl.dispose(); return; }
    WidgetsBinding.instance.addPostFrameCallback((_) => nameCtrl.dispose());

    // Pick file
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
    );
    if (result == null || result.files.isEmpty) return;
    final pickedFile = result.files.first;
    if (pickedFile.path == null) return;

    setState(() {
      _uploading = true;
      _uploadProgress = 'Uploading…';
    });

    try {
      final file = File(pickedFile.path!);
      final fileName =
          '${widget.student.studentId}_${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name}';
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('student_documents/${widget.student.studentId}/$fileName');

      final uploadTask = storageRef.putFile(file);
      uploadTask.snapshotEvents.listen((snap) {
        if (mounted) {
          final pct = (snap.bytesTransferred / snap.totalBytes * 100)
              .toStringAsFixed(0);
          setState(() => _uploadProgress = 'Uploading $pct%…');
        }
      });

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      final displayName = customName.isNotEmpty
          ? '$selectedType $customName'
          : selectedType!;
      final fs = ref.read(firestoreServiceProvider);
      await fs.saveStudentDocument(widget.student.studentId, {
        'docType':       selectedType,
        'displayName':   displayName,
        'fileName':      pickedFile.name,
        'downloadUrl':   downloadUrl,
        'uploadedByUid': widget.user.uid,
        'uploadedByName': widget.user.name,
        'storagePath':   storageRef.fullPath,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Document uploaded successfully'),
            backgroundColor: _kGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: _kRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _deleteDocument(String docId, String storagePath) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Document'),
        content:
            const Text('Are you sure you want to delete this document?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: _kRed, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      // Delete from Storage
      try {
        await FirebaseStorage.instance.ref(storagePath).delete();
      } catch (_) {}
      // Delete from Firestore
      final fs = ref.read(firestoreServiceProvider);
      await fs.deleteStudentDocument(widget.student.studentId, docId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Document deleted'),
              backgroundColor: Colors.grey),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'),
              backgroundColor: _kRed),
        );
      }
    }
  }

  Future<void> _openDocument(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot open document')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fs = ref.read(firestoreServiceProvider);

    return Column(
      children: [
        // Upload button
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: SizedBox(
            width: double.infinity,
            child: _uploading
                ? Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _kPrimary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: _kPrimary)),
                        const SizedBox(width: 10),
                        Text(_uploadProgress,
                            style: const TextStyle(
                                color: _kPrimary,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  )
                : ElevatedButton.icon(
                    onPressed: _uploadDocument,
                    icon: const Icon(Icons.upload_file_rounded),
                    label: const Text('Upload Document'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: const StadiumBorder(),
                    ),
                  ),
          ),
        ),
        // Documents list
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: fs.streamStudentDocuments(widget.student.studentId),
            builder: (ctx, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: _kPrimary));
              }
              final docs = snap.data ?? [];
              if (docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.folder_open_rounded,
                          size: 52,
                          color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text('No documents uploaded',
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey.shade500)),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                itemCount: docs.length,
                itemBuilder: (_, i) {
                  final doc = docs[i];
                  final docId = doc['docId'] as String;
                  final docType     = (doc['docType'] as String?) ?? 'Document';
                  final displayName = (doc['displayName'] as String?) ?? docType;
                  final fileName = (doc['fileName'] as String?) ?? '';
                  final downloadUrl =
                      (doc['downloadUrl'] as String?) ?? '';
                  final uploadedBy =
                      (doc['uploadedByName'] as String?) ?? '—';
                  final storagePath =
                      (doc['storagePath'] as String?) ?? '';
                  final ts = doc['uploadedAt'] as Timestamp?;
                  final dateStr = ts != null
                      ? DateFormat('dd MMM yyyy').format(ts.toDate())
                      : '—';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: _kPrimary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.description_rounded,
                            color: _kPrimary, size: 22),
                      ),
                      title: Text(displayName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: _kNavy)),
                      subtitle: Text(
                        '$fileName\nUploaded by $uploadedBy · $dateStr',
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade500),
                        maxLines: 2,
                      ),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (downloadUrl.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.open_in_new_rounded,
                                  color: _kPrimary, size: 20),
                              onPressed: () =>
                                  _openDocument(downloadUrl),
                            ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded,
                                color: _kRed, size: 20),
                            onPressed: () =>
                                _deleteDocument(docId, storagePath),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Fee Tab ──────────────────────────────────────────────────────────────────
class _FeeTab extends StatelessWidget {
  final Map<String, dynamic>? feeData;
  final bool loading;
  const _FeeTab({required this.feeData, required this.loading});

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(
          child: CircularProgressIndicator(color: _kPrimary));
    }
    if (feeData == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_rounded,
                size: 52, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text('No fee record found',
                style: TextStyle(
                    fontSize: 15, color: Colors.grey.shade500)),
          ],
        ),
      );
    }

    final fmt = NumberFormat('##,##,##0', 'en_IN');
    final paid = ((feeData!['totalPaid'] as num?) ?? 0).toDouble();
    final pending =
        ((feeData!['totalPending'] as num?) ?? 0).toDouble();
    final total = paid + pending;
    final pct = total > 0 ? (paid / total) : 0.0;

    final feeHeads =
        (feeData!['feeHeads'] as List<dynamic>?) ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 8),
          // Summary card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [_kDark, _kPrimary]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Fee',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                          Text('₹ ${fmt.format(total)}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                            '${(pct * 100).toStringAsFixed(0)}% paid',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12)),
                        Text(
                          pending > 0
                              ? '₹ ${fmt.format(pending)} due'
                              : 'Fully paid',
                          style: TextStyle(
                            color: pending > 0
                                ? _kAmber
                                : _kGreen,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct.toDouble(),
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(_kGreen),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _FeePill('Paid', '₹ ${fmt.format(paid)}', _kGreen),
                    const SizedBox(width: 8),
                    _FeePill(
                        'Pending', '₹ ${fmt.format(pending)}', _kAmber),
                  ],
                ),
              ],
            ),
          ),
          if (feeHeads.isNotEmpty) ...[
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Fee Breakdown',
              icon: Icons.list_alt_rounded,
              children: feeHeads.map<Widget>((h) {
                final head = h as Map<String, dynamic>;
                final hName = (head['name'] as String?) ?? '—';
                final hAmt = ((head['amount'] as num?) ?? 0).toDouble();
                final hPaid =
                    ((head['paid'] as num?) ?? 0).toDouble();
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(hName,
                            style: const TextStyle(
                                fontSize: 13, color: _kNavy)),
                      ),
                      Text('₹ ${fmt.format(hPaid)}/${fmt.format(hAmt)}',
                          style: TextStyle(
                              fontSize: 12,
                              color: hPaid >= hAmt
                                  ? _kGreen
                                  : _kAmber,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _FeePill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _FeePill(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    color: color,
                    fontWeight: FontWeight.w500)),
            Text(value,
                style: TextStyle(
                    fontSize: 13,
                    color: color,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

// ── Shared UI components ─────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? iconColor;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    this.iconColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? _kPrimary;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        // Top accent border on every section card
        border: const Border(top: BorderSide(color: _kPrimary, width: 3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            // Section header wrapped in colored-left-bar Row
            child: Row(
              children: [
                Container(width: 4, height: 20, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 8),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _kNavy,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty || value == '—') {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: TextStyle(
                    fontSize: 13, color: Colors.grey.shade500)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _kNavy)),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color)),
    );
  }
}
