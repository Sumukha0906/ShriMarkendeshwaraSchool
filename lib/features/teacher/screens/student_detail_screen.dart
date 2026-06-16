import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/models/student.dart';
import '../../../core/models/user_model.dart';

const _kPrimary  = Color(0xFF065F46);
const _kDark     = Color(0xFF022C22);
const _kBg       = Color(0xFFF0FDF4);
const _kAmber    = Color(0xFFF59E0B);
const _kRed      = Color(0xFFEF4444);
const _kPurple   = Color(0xFFD97706);
const _kBlue     = Color(0xFF3B82F6);

/// Dual-mode screen:
/// - [showClassList] = true  → lists all students in [classId]
/// - [showClassList] = false → shows detail for [studentId]
class StudentDetailScreen extends ConsumerStatefulWidget {
  final String? studentId;
  final String classId;
  final bool showClassList;

  const StudentDetailScreen({
    super.key,
    this.studentId,
    required this.classId,
    this.showClassList = false,
  });

  @override
  ConsumerState<StudentDetailScreen> createState() =>
      _StudentDetailScreenState();
}

class _StudentDetailScreenState extends ConsumerState<StudentDetailScreen> {
  // ── build ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (widget.showClassList) return _ClassStudentList(classId: widget.classId);
    return _StudentDetailView(studentId: widget.studentId ?? '');
  }
}

// ═══════════════════════════════════════════════════════════════
// Class student list
// ═══════════════════════════════════════════════════════════════
class _ClassStudentList extends ConsumerWidget {
  final String classId;
  const _ClassStudentList({required this.classId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fs = ref.watch(firestoreServiceProvider);

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kDark,
        foregroundColor: Colors.white,
        title: const Text('Students',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: StreamBuilder<List<Student>>(
        stream: fs.streamStudentsByClass(classId),
        builder: (ctx, snap) {
          final students = snap.data ?? [];

          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: _kPrimary));
          }

          if (students.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 60,
                      color: _kPrimary.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text('No students in this class',
                      style: TextStyle(color: Colors.grey[500])),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: students.length,
            itemBuilder: (_, i) => _StudentListCard(student: students[i]),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Expandable student list card
// ═══════════════════════════════════════════════════════════════
class _StudentListCard extends ConsumerStatefulWidget {
  final Student student;
  const _StudentListCard({required this.student});
  @override
  ConsumerState<_StudentListCard> createState() => _StudentListCardState();
}

class _StudentListCardState extends ConsumerState<_StudentListCard> {
  bool _expanded = false;
  Map<String, dynamic>? _rawData;
  bool _loading = false;

  Future<void> _loadRawData() async {
    if (_rawData != null) return;
    setState(() => _loading = true);
    final fs = ref.read(firestoreServiceProvider);
    final data = await fs.getStudentRawDoc(widget.student.studentId);
    if (mounted) setState(() { _rawData = data; _loading = false; });
  }

  Future<void> _call(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.student;
    final initials = s.name
        .split(' ').take(2)
        .map((w) => w.isNotEmpty ? w[0] : '').join().toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
      ),
      child: Column(
        children: [
          // ── Header row ──────────────────────────────────────
          InkWell(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            onTap: () {
              setState(() => _expanded = !_expanded);
              if (!_expanded) _loadRawData();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  s.photoUrl.isNotEmpty
                      ? CircleAvatar(radius: 24, backgroundImage: NetworkImage(s.photoUrl))
                      : CircleAvatar(
                          radius: 24,
                          backgroundColor: _kPrimary.withValues(alpha: 0.15),
                          child: Text(initials,
                              style: const TextStyle(
                                  color: _kPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
                        ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.name,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                        const SizedBox(height: 2),
                        Text(
                          'Roll: ${s.rollNo.isNotEmpty ? s.rollNo : '—'}  •  Adm: ${s.admissionNo.isNotEmpty ? s.admissionNo : '—'}',
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down_rounded, color: _kPrimary),
                  ),
                ],
              ),
            ),
          ),

          // ── Expanded section ─────────────────────────────────
          if (_expanded) ...[
            Divider(height: 1, color: Colors.grey[100]),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: _loading
                  ? const Center(child: Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(color: _kPrimary, strokeWidth: 2)))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Basic quick info
                        if (s.dob.isNotEmpty || s.medicalHistory.bloodGroup.isNotEmpty)
                          Wrap(
                            spacing: 12,
                            children: [
                              if (s.dob.isNotEmpty)
                                _QuickChip(Icons.cake_rounded, s.dob, Colors.pink),
                              if (s.medicalHistory.bloodGroup.isNotEmpty)
                                _QuickChip(Icons.water_drop_rounded,
                                    s.medicalHistory.bloodGroup, _kRed),
                            ],
                          ),
                        if (s.dob.isNotEmpty || s.medicalHistory.bloodGroup.isNotEmpty)
                          const SizedBox(height: 12),

                        // Parent call buttons from raw data
                        if (_rawData != null) ...[
                          _buildParentCallRow('Mother',
                              _rawData!['motherName'] as String? ?? '',
                              _rawData!['motherPhone'] as String? ?? '',
                              _kPurple),
                          const SizedBox(height: 8),
                          _buildParentCallRow('Father',
                              _rawData!['fatherName'] as String? ?? '',
                              _rawData!['fatherPhone'] as String? ?? '',
                              _kBlue),
                          const SizedBox(height: 12),
                        ],

                        // Full profile button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      _StudentDetailView(studentId: s.studentId)),
                            ),
                            icon: const Icon(Icons.person_rounded, size: 16),
                            label: const Text('View Full Profile'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _kPrimary,
                              side: const BorderSide(color: _kPrimary),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildParentCallRow(String label, String name, String phone, Color color) {
    final hasPhone = phone.isNotEmpty && phone != '+91';
    return Row(
      children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(Icons.person_outline_rounded, color: color, size: 15),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(fontSize: 10, color: Colors.grey[500],
                      fontWeight: FontWeight.w600)),
              Text(name.isNotEmpty ? name : '—',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              if (hasPhone)
                Text(phone, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            ],
          ),
        ),
        if (hasPhone) ...[
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            icon: Icon(Icons.call_rounded, color: color, size: 20),
            tooltip: 'Call $label',
            onPressed: () => _call(phone),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            icon: Icon(Icons.copy_rounded, color: Colors.grey[400], size: 17),
            tooltip: 'Copy number',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: phone));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Number copied')));
            },
          ),
        ],
      ],
    );
  }
}

class _QuickChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _QuickChip(this.icon, this.text, this.color);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Single student detail view
// ═══════════════════════════════════════════════════════════════
class _StudentDetailView extends ConsumerStatefulWidget {
  final String studentId;
  const _StudentDetailView({required this.studentId});

  @override
  ConsumerState<_StudentDetailView> createState() => _StudentDetailViewState();
}

class _StudentDetailViewState extends ConsumerState<_StudentDetailView> {
  @override
  Widget build(BuildContext context) {
    final fs        = ref.watch(firestoreServiceProvider);
    final userAsync = ref.watch(currentUserProvider);
    final teacherUid = userAsync.value?.uid ?? '';

    return FutureBuilder<Student?>(
      future: fs.getStudent(widget.studentId),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: _kBg,
            body: Center(child: CircularProgressIndicator(color: _kPrimary)),
          );
        }

        final s = snap.data;
        if (s == null) {
          return Scaffold(
            backgroundColor: _kBg,
            appBar: AppBar(
              backgroundColor: _kDark,
              foregroundColor: Colors.white,
              title: const Text('Student'),
            ),
            body: const Center(child: Text('Student not found')),
          );
        }

        final initials = s.name
            .split(' ')
            .take(2)
            .map((w) => w.isNotEmpty ? w[0] : '')
            .join()
            .toUpperCase();

        return Scaffold(
          backgroundColor: _kBg,
          body: CustomScrollView(
            slivers: [
              // ── Hero header ──────────────────────────────────
              SliverAppBar(
                expandedHeight: 200,
                backgroundColor: _kDark,
                foregroundColor: Colors.white,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF022C22), Color(0xFF065F46)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        s.photoUrl.isNotEmpty
                            ? CircleAvatar(
                                radius: 44,
                                backgroundImage: NetworkImage(s.photoUrl),
                              )
                            : CircleAvatar(
                                radius: 44,
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.2),
                                child: Text(
                                  initials,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                        const SizedBox(height: 10),
                        Text(
                          s.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Roll: ${s.rollNo.isNotEmpty ? s.rollNo : '—'}  •  Adm: ${s.admissionNo.isNotEmpty ? s.admissionNo : '—'}',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ── Basic info ───────────────────────────
                      _SectionCard(
                        icon: Icons.person_rounded,
                        color: _kPrimary,
                        title: 'Personal Info',
                        children: [
                          _InfoRow('Gender', s.gender.isNotEmpty ? s.gender : '—'),
                          _InfoRow('Date of Birth', s.dob.isNotEmpty ? s.dob : '—'),
                          _InfoRow('Address', s.address.isNotEmpty ? s.address : '—'),
                          _InfoRow('Academic Year', s.academicYear),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // ── Parent contact ───────────────────────
                      if (s.parentUid.isNotEmpty)
                        _ParentContactCard(parentUid: s.parentUid),
                      if (s.parentUid.isNotEmpty) const SizedBox(height: 14),

                      // ── Medical info ─────────────────────────
                      _SectionCard(
                        icon: Icons.medical_services_rounded,
                        color: _kAmber,
                        title: 'Medical Info',
                        children: [
                          _InfoRow('Blood Group',
                              s.medicalHistory.bloodGroup.isNotEmpty
                                  ? s.medicalHistory.bloodGroup
                                  : '—'),
                          if (s.medicalHistory.allergies.isNotEmpty)
                            _ChipsRow('Allergies', s.medicalHistory.allergies,
                                Colors.red[50]!, _kRed),
                          if (s.medicalHistory.conditions.isNotEmpty)
                            _ChipsRow('Conditions', s.medicalHistory.conditions,
                                Colors.amber[50]!, _kAmber),
                          if (s.medicalHistory.vaccinationNotes.isNotEmpty)
                            _InfoRow('Vaccination Notes',
                                s.medicalHistory.vaccinationNotes),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // ── Emergency contact ────────────────────
                      if (s.medicalHistory.emergencyContact != null)
                        _EmergencyContactCard(
                            contact: s.medicalHistory.emergencyContact!,
                            onCall: (phone) async {
                              final uri = Uri.parse('tel:$phone');
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri);
                              }
                            }),
                      if (s.medicalHistory.emergencyContact != null)
                        const SizedBox(height: 14),

                      // ── Private notes ────────────────────────
                      if (teacherUid.isNotEmpty)
                        _TeacherNotesSection(
                          teacherUid: teacherUid,
                          studentId: s.studentId,
                        ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Parent contact card (fetched async)
// ═══════════════════════════════════════════════════════════════
class _ParentContactCard extends ConsumerWidget {
  final String parentUid;
  const _ParentContactCard({required this.parentUid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fs = ref.watch(firestoreServiceProvider);

    return FutureBuilder<UserModel?>(
      future: fs.getUser(parentUid),
      builder: (ctx, snap) {
        final parent = snap.data;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: _kPurple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.family_restroom_rounded,
                        color: _kPurple, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Parent / Guardian',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ],
              ),
              const Divider(height: 20),
              if (snap.connectionState == ConnectionState.waiting)
                const Center(
                    child: CircularProgressIndicator(
                        color: _kPrimary, strokeWidth: 2))
              else if (parent == null)
                Text('Parent not linked yet',
                    style: TextStyle(color: Colors.grey[400], fontSize: 13))
              else ...[
                _InfoRow('Name', parent.name),
                _InfoRow('Phone', parent.phone),
                _InfoRow('Role',
                    parent.role.name[0] + parent.role.name.substring(1).toLowerCase()),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final uri = Uri.parse('tel:${parent.phone}');
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          }
                        },
                        icon: const Icon(Icons.call_rounded,
                            color: Colors.white, size: 16),
                        label: const Text('Call',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _kPrimary,
                          padding:
                              const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Clipboard.setData(
                              ClipboardData(text: parent.phone));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Phone number copied')),
                          );
                        },
                        icon: const Icon(Icons.copy_rounded,
                            size: 16, color: _kPrimary),
                        label: const Text('Copy',
                            style: TextStyle(
                                color: _kPrimary,
                                fontWeight: FontWeight.w700)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: _kPrimary),
                          padding:
                              const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Emergency contact card
// ═══════════════════════════════════════════════════════════════
class _EmergencyContactCard extends StatelessWidget {
  final EmergencyContact contact;
  final Future<void> Function(String phone) onCall;

  const _EmergencyContactCard(
      {required this.contact, required this.onCall});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kRed.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: _kRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.emergency_rounded,
                    color: _kRed, size: 18),
              ),
              const SizedBox(width: 10),
              const Text(
                'Emergency Contact',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: _kRed),
              ),
            ],
          ),
          const Divider(height: 20),
          _InfoRow('Name', contact.name),
          _InfoRow('Phone', contact.phone),
          if (contact.relation.isNotEmpty)
            _InfoRow('Relation', contact.relation),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => onCall(contact.phone),
              icon: const Icon(Icons.emergency_rounded,
                  color: Colors.white, size: 16),
              label: const Text('Call Emergency Contact',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kRed,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Private teacher notes section
// ═══════════════════════════════════════════════════════════════
class _TeacherNotesSection extends ConsumerStatefulWidget {
  final String teacherUid;
  final String studentId;

  const _TeacherNotesSection(
      {required this.teacherUid, required this.studentId});

  @override
  ConsumerState<_TeacherNotesSection> createState() =>
      _TeacherNotesSectionState();
}

class _TeacherNotesSectionState
    extends ConsumerState<_TeacherNotesSection> {
  final _ctrl        = TextEditingController();
  bool _showForm     = false;
  bool _saving       = false;
  String? _editId;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _saving = true);
    final fs   = ref.read(firestoreServiceProvider);
    final user = ref.read(currentUserProvider).value;
    try {
      if (_editId != null) {
        await fs.updateTeacherNote(_editId!, text);
      } else {
        await fs.saveTeacherNote({
          'teacherUid':  widget.teacherUid,
          'studentId':   widget.studentId,
          'note':        text,
          'teacherName': user?.name ?? 'Teacher',
          'createdAt':   DateTime.now().toIso8601String(),
        });
      }
      setState(() {
        _saving   = false;
        _showForm = false;
        _editId   = null;
      });
      _ctrl.clear();
    } catch (e) {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fs = ref.watch(firestoreServiceProvider);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBlue.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: _kBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.sticky_note_2_rounded,
                    color: _kBlue, size: 18),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Private Notes',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    Text(
                      'Only visible to you',
                      style: TextStyle(
                          color: Color(0xFF9CA3AF), fontSize: 10),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showForm = !_showForm;
                    if (!_showForm) {
                      _ctrl.clear();
                      _editId = null;
                    }
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _kBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _showForm ? 'Cancel' : '+ Add Note',
                    style: const TextStyle(
                        color: _kBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),

          // Add / edit form
          if (_showForm) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _ctrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Write a private note about this student...',
                hintStyle:
                    TextStyle(color: Colors.grey[400], fontSize: 13),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey[300]!)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey[300]!)),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kBlue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text(
                        _editId != null ? 'Update Note' : 'Save Note',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ],

          // Existing notes stream
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: fs.streamTeacherStudentNotes(
                widget.teacherUid, widget.studentId),
            builder: (ctx, snap) {
              final notes = snap.data ?? [];
              if (notes.isEmpty && !_showForm) {
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    'No notes yet. Tap "+ Add Note" to add a private note.',
                    style: TextStyle(
                        color: Colors.grey[400], fontSize: 12),
                  ),
                );
              }
              if (notes.isEmpty) return const SizedBox();

              return Column(
                children: notes.map((n) {
                  final noteId = n['id'] as String? ?? '';
                  final text   = n['note'] as String? ?? '';
                  final date   = n['createdAt'] as String? ?? '';

                  return Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _kBlue.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: _kBlue.withValues(alpha: 0.15)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(text,
                            style: const TextStyle(fontSize: 13)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              _formatDate(date),
                              style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 10),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _editId   = noteId;
                                  _showForm = true;
                                });
                                _ctrl.text = text;
                              },
                              child: const Icon(Icons.edit_rounded,
                                  size: 14, color: _kBlue),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () async {
                                final fs =
                                    ref.read(firestoreServiceProvider);
                                await fs.deleteTeacherNote(noteId);
                              },
                              child: const Icon(Icons.delete_rounded,
                                  size: 14, color: _kRed),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return iso;
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// Shared UI widgets
// ═══════════════════════════════════════════════════════════════
class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    // Pattern H — top accent stripe on section cards
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(top: BorderSide(color: color, width: 3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pattern G — section header with accent bar
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ],
          ),
          const Divider(height: 20),
          ...children,
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipsRow extends StatelessWidget {
  final String label;
  final List<String> items;
  final Color bgColor;
  final Color textColor;

  const _ChipsRow(this.label, this.items, this.bgColor, this.textColor);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: items
                  .map((item) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item,
                          style: TextStyle(
                              color: textColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
