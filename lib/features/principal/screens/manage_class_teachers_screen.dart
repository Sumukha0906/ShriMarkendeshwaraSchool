import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/models/class_model.dart';
import '../../../core/models/user_model.dart';
import 'assign_student_subjects_screen.dart';

const _blue   = Color(0xFF3B82F6);
const _dark   = Color(0xFF1D4ED8);
const _bg     = Color(0xFFF0F7FF);
const _green  = Color(0xFF059669);
const _purple = Color(0xFFD97706);
const _red    = Color(0xFFEF4444);

class ManageClassTeachersScreen extends ConsumerStatefulWidget {
  final ClassModel cls;

  const ManageClassTeachersScreen({super.key, required this.cls});

  @override
  ConsumerState<ManageClassTeachersScreen> createState() =>
      _ManageClassTeachersScreenState();
}

class _ManageClassTeachersScreenState
    extends ConsumerState<ManageClassTeachersScreen> {
  late ClassModel _cls;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _cls = widget.cls;
  }

  // ── Firestore save helpers ────────────────────────────────────

  Future<void> _saveClass(ClassModel updated) async {
    setState(() {
      _saving = true;
      _cls    = updated;
    });
    try {
      final fs = ref.read(firestoreServiceProvider);
      await fs.updateClass(updated);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: _red),
        );
      }
    }
    setState(() => _saving = false);
  }

  // ── Assign class teacher ──────────────────────────────────────

  Future<void> _assignClassTeacher() async {
    final picked = await _showTeacherPicker(
      title:       'Assign Class Teacher',
      excludeUids: [],
    );
    if (picked == null) return;
    await _saveClass(_cls.copyWith(classTeacherUid: picked.uid));
    _showSuccess('Class teacher assigned: ${picked.name}');
  }

  Future<void> _removeClassTeacher() async {
    final confirm = await _confirmRemove('Remove class teacher assignment?');
    if (!confirm) return;
    await _saveClass(_cls.copyWith(classTeacherUid: ''));
    _showSuccess('Class teacher removed');
  }

  // ── Assign proctor ────────────────────────────────────────────

  Future<void> _assignProctor() async {
    final picked = await _showTeacherPicker(
      title:       'Assign Mentor / Proctor',
      excludeUids: [],
    );
    if (picked == null) return;
    await _saveClass(_cls.copyWith(proctorTeacherUid: picked.uid));
    _showSuccess('Proctor assigned: ${picked.name}');
  }

  Future<void> _removeProctor() async {
    final confirm = await _confirmRemove('Remove mentor/proctor assignment?');
    if (!confirm) return;
    await _saveClass(_cls.copyWith(proctorTeacherUid: ''));
    _showSuccess('Proctor removed');
  }

  // ── Subject teachers ──────────────────────────────────────────

  Future<void> _addSubjectTeacher() async {
    String? subject;
    UserModel? teacher;

    // Step 1 — subject name
    subject = await _showSubjectInput();
    if (subject == null || subject.isEmpty) return;

    // Step 2 — pick teacher
    teacher = await _showTeacherPicker(
      title:       'Assign Teacher for $subject',
      excludeUids: [],
    );
    if (teacher == null) return;

    // Check duplicate subject
    final exists = _cls.subjectTeachers.any(
        (st) => st.subject.toLowerCase() == subject!.toLowerCase());
    if (exists) {
      _showError('$subject already has an assigned teacher. Remove it first.');
      return;
    }

    final updated = _cls.copyWith(
      subjectTeachers: [
        ..._cls.subjectTeachers,
        SubjectTeacher(teacherUid: teacher.uid, subject: subject),
      ],
    );
    await _saveClass(updated);
    _showSuccess('${teacher.name} assigned for $subject');
  }

  Future<void> _removeSubjectTeacher(SubjectTeacher st) async {
    final confirm = await _confirmRemove('Remove ${st.subject} teacher?');
    if (!confirm) return;
    final updated = _cls.copyWith(
      subjectTeachers:
          _cls.subjectTeachers.where((s) => s != st).toList(),
    );
    await _saveClass(updated);
    _showSuccess('${st.subject} teacher removed');
  }

  Future<void> _changeSubjectTeacher(SubjectTeacher existing) async {
    final picked = await _showTeacherPicker(
      title:       'Change Teacher for ${existing.subject}',
      excludeUids: [],
    );
    if (picked == null) return;
    final list = _cls.subjectTeachers.map((st) {
      if (st.subject == existing.subject) {
        return SubjectTeacher(teacherUid: picked.uid, subject: st.subject);
      }
      return st;
    }).toList();
    await _saveClass(_cls.copyWith(subjectTeachers: list));
    _showSuccess('${existing.subject} teacher changed to ${picked.name}');
  }

  // ── UI helpers ────────────────────────────────────────────────

  void _showSuccess(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: _green),
    );
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: _red),
    );
  }

  Future<bool> _confirmRemove(String msg) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Confirm',
                style: TextStyle(fontWeight: FontWeight.w700)),
            content: Text(msg),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('Cancel',
                    style: TextStyle(color: Colors.grey[600])),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(backgroundColor: _red),
                child: const Text('Remove',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<String?> _showSubjectInput() async {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Subject Name',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: 'e.g. Mathematics, Science, English...',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            style: ElevatedButton.styleFrom(backgroundColor: _blue),
            child: const Text('Next',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<UserModel?> _showTeacherPicker({
    required String title,
    required List<String> excludeUids,
  }) {
    final fs = ref.read(firestoreServiceProvider);
    final userAsync = ref.read(currentUserProvider);
    final schoolId = userAsync.value?.schoolId ?? '';
    String filter = '';

    return showModalBottomSheet<UserModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => SizedBox(
          height: MediaQuery.of(ctx).size.height * 0.75,
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    TextField(
                      onChanged: (v) => setSheet(() => filter = v.toLowerCase()),
                      decoration: InputDecoration(
                        hintText: 'Search teachers...',
                        hintStyle:
                            TextStyle(color: Colors.grey[400], fontSize: 13),
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[200]!)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[200]!)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 20),
              Expanded(
                child: StreamBuilder<List<UserModel>>(
                  stream: fs.streamSchoolTeachers(schoolId),
                  builder: (_, snap) {
                    final all = snap.data ?? [];
                    final filtered = filter.isEmpty
                        ? all
                        : all
                            .where((t) =>
                                t.name.toLowerCase().contains(filter))
                            .toList();

                    if (filtered.isEmpty) {
                      return Center(
                        child: Text('No teachers found',
                            style: TextStyle(color: Colors.grey[400])),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final t = filtered[i];
                        final initials = t.name
                            .split(' ')
                            .take(2)
                            .map((w) => w.isNotEmpty ? w[0] : '')
                            .join()
                            .toUpperCase();

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _blue.withValues(alpha: 0.15),
                            child: Text(initials,
                                style: const TextStyle(
                                    color: _blue,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13)),
                          ),
                          title: Text(t.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 14)),
                          subtitle: Text(t.phone,
                              style: TextStyle(
                                  color: Colors.grey[500], fontSize: 12)),
                          trailing: const Icon(Icons.chevron_right,
                              color: _blue),
                          onTap: () => Navigator.pop(ctx, t),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final schoolId = ref.watch(currentUserProvider).value?.schoolId ?? '';

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _dark,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_cls.displayName,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 16)),
            const Text('Manage Teachers',
                style:
                    TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Info banner ───────────────────────────────────
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _blue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _blue.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: _blue, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Only the Principal can assign or change teachers for classes.',
                      style: TextStyle(
                          color: _blue,
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Class Teacher ─────────────────────────────────
            _sectionHeader(
              Icons.school_rounded,
              'Class Teacher',
              _green,
              subtitle: 'Primary teacher responsible for the class',
            ),
            const SizedBox(height: 10),
            _ClassTeacherCard(
              teacherUid: _cls.classTeacherUid,
              schoolId:   schoolId,
              onAssign:   _assignClassTeacher,
              onRemove:   _removeClassTeacher,
              color:      _green,
            ),
            const SizedBox(height: 24),

            // ── Subject Teachers ──────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _sectionHeader(
                    Icons.menu_book_rounded,
                    'Subject Teachers',
                    _blue,
                    subtitle: 'Assign one teacher per subject',
                  ),
                ),
                GestureDetector(
                  onTap: _addSubjectTeacher,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: _blue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.add, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text('Add',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (_cls.subjectTeachers.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: _blue.withValues(alpha: 0.15)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.menu_book_outlined,
                        size: 40,
                        color: _blue.withValues(alpha: 0.3)),
                    const SizedBox(height: 10),
                    Text('No subject teachers assigned yet',
                        style:
                            TextStyle(color: Colors.grey[400], fontSize: 13)),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _addSubjectTeacher,
                      icon:
                          const Icon(Icons.add, color: _blue, size: 16),
                      label: const Text('Add Subject Teacher',
                          style: TextStyle(
                              color: _blue, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              )
            else
              ..._cls.subjectTeachers.map((st) => _SubjectTeacherCard(
                    st:        st,
                    schoolId:  schoolId,
                    onChange:  () => _changeSubjectTeacher(st),
                    onRemove:  () => _removeSubjectTeacher(st),
                  )),
            const SizedBox(height: 24),

            // ── Mentor / Proctor ──────────────────────────────
            _sectionHeader(
              Icons.supervisor_account_rounded,
              'Mentor / Proctor',
              _purple,
              subtitle: 'A teacher who mentors and oversees students',
            ),
            const SizedBox(height: 10),
            _ClassTeacherCard(
              teacherUid: _cls.proctorTeacherUid,
              schoolId:   schoolId,
              onAssign:   _assignProctor,
              onRemove:   _removeProctor,
              color:      _purple,
              emptyLabel: 'No mentor/proctor assigned',
              assignLabel:'Assign Mentor',
            ),
            const SizedBox(height: 24),

            // ── Student Subject Enrollment ────────────────────
            const Divider(height: 32),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.assignment_ind_rounded,
                    color: Color(0xFF3B82F6), size: 20),
              ),
              title: const Text('Student Subject Enrollment',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              subtitle: Text(
                'Assign elective subjects to specific students',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AssignStudentSubjectsScreen(
                    classModel: _cls,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(IconData icon, String title, Color color,
      {String? subtitle}) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 15)),
            if (subtitle != null)
              Text(subtitle,
                  style:
                      TextStyle(color: Colors.grey[500], fontSize: 11)),
          ],
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Card: single teacher slot (class teacher or proctor)
// ═══════════════════════════════════════════════════════════════
class _ClassTeacherCard extends ConsumerWidget {
  final String teacherUid;
  final String schoolId;
  final VoidCallback onAssign;
  final VoidCallback onRemove;
  final Color color;
  final String emptyLabel;
  final String assignLabel;

  const _ClassTeacherCard({
    required this.teacherUid,
    required this.schoolId,
    required this.onAssign,
    required this.onRemove,
    required this.color,
    this.emptyLabel  = 'No class teacher assigned',
    this.assignLabel = 'Assign Teacher',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (teacherUid.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Icon(Icons.person_off_rounded,
                color: color.withValues(alpha: 0.4), size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Text(emptyLabel,
                  style: TextStyle(color: Colors.grey[400], fontSize: 13)),
            ),
            GestureDetector(
              onTap: onAssign,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(assignLabel,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12)),
              ),
            ),
          ],
        ),
      );
    }

    final fs = ref.watch(firestoreServiceProvider);
    return FutureBuilder<UserModel?>(
      future: fs.getUser(teacherUid),
      builder: (ctx, snap) {
        final teacher = snap.data;
        final name = teacher?.name ?? '...';
        final initials = name
            .split(' ')
            .take(2)
            .map((w) => w.isNotEmpty ? w[0] : '')
            .join()
            .toUpperCase();

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: color.withValues(alpha: 0.15),
                child: Text(initials,
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w800,
                        fontSize: 14)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14)),
                    if (teacher != null)
                      Text(teacher.phone,
                          style: TextStyle(
                              color: Colors.grey[500], fontSize: 12)),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'change') onAssign();
                  if (v == 'remove') onRemove();
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                      value: 'change',
                      child: Text('Change Teacher')),
                  const PopupMenuItem(
                      value: 'remove',
                      child: Text('Remove',
                          style: TextStyle(color: Color(0xFFEF4444)))),
                ],
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.more_vert_rounded,
                      size: 18, color: Colors.grey[600]),
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
// Card: subject teacher row
// ═══════════════════════════════════════════════════════════════
class _SubjectTeacherCard extends ConsumerWidget {
  final SubjectTeacher st;
  final String schoolId;
  final VoidCallback onChange;
  final VoidCallback onRemove;

  const _SubjectTeacherCard({
    required this.st,
    required this.schoolId,
    required this.onChange,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fs = ref.watch(firestoreServiceProvider);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _blue.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          // Subject badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              st.subject,
              style: const TextStyle(
                  color: _blue,
                  fontWeight: FontWeight.w700,
                  fontSize: 12),
            ),
          ),
          const SizedBox(width: 12),
          // Teacher name
          Expanded(
            child: FutureBuilder<UserModel?>(
              future: fs.getUser(st.teacherUid),
              builder: (_, snap) {
                final name = snap.data?.name ?? '...';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                    if (snap.data != null)
                      Text(snap.data!.phone,
                          style: TextStyle(
                              color: Colors.grey[500], fontSize: 11)),
                  ],
                );
              },
            ),
          ),
          // Actions
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'change') onChange();
              if (v == 'remove') onRemove();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                  value: 'change', child: Text('Change Teacher')),
              const PopupMenuItem(
                  value: 'remove',
                  child: Text('Remove Subject',
                      style: TextStyle(color: Color(0xFFEF4444)))),
            ],
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.more_vert_rounded,
                  size: 16, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }
}
