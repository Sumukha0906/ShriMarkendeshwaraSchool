import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/models/student.dart';
import '../../../core/models/user_model.dart';
import '../../../core/models/class_model.dart';
import '../../../core/models/special_request.dart';
import '../parent_dashboard.dart';

class SpecialRequestScreen extends ConsumerStatefulWidget {
  final Student student;
  const SpecialRequestScreen({super.key, required this.student});

  @override
  ConsumerState<SpecialRequestScreen> createState() =>
      _SpecialRequestScreenState();
}

class _SpecialRequestScreenState extends ConsumerState<SpecialRequestScreen> {
  final _subjectCtrl = TextEditingController();
  final _descCtrl    = TextEditingController();
  SpecialRequestType _type = SpecialRequestType.GENERAL;
  String? _selectedTeacherUid;
  String? _selectedTeacherName;
  bool _loading = false;

  static const _typeLabels = {
    SpecialRequestType.GENERAL:    'General',
    SpecialRequestType.MEDICAL:    'Medical',
    SpecialRequestType.BEHAVIORAL: 'Behavioral',
    SpecialRequestType.ACADEMIC:   'Academic',
    SpecialRequestType.TRANSPORT:  'Transport',
    SpecialRequestType.OTHER:      'Other',
  };

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_subjectCtrl.text.trim().isEmpty ||
        _descCtrl.text.trim().isEmpty ||
        _selectedTeacherUid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill all fields and select a teacher')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final user = await ref.read(currentUserProvider.future);
      final fs   = ref.read(firestoreServiceProvider);
      final req  = SpecialRequest(
        requestId:          '',
        schoolId:           widget.student.schoolId,
        classId:            widget.student.classId,
        studentId:          widget.student.studentId,
        studentName:        widget.student.name,
        parentUid:          user!.uid,
        parentName:         user.name,
        targetTeacherUid:   _selectedTeacherUid!,
        targetTeacherName:  _selectedTeacherName ?? '',
        type:               _type,
        subject:            _subjectCtrl.text.trim(),
        description:        _descCtrl.text.trim(),
      );
      await fs.createSpecialRequest(req);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Special request submitted!'),
            backgroundColor: kParentPrimary,
          ),
        );
      }
    } catch (e) {
      setState(() => _loading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final fs = ref.watch(firestoreServiceProvider);

    return Scaffold(
      backgroundColor: kParentBg,
      appBar: AppBar(
        backgroundColor: kParentDark,
        foregroundColor: Colors.white,
        title: const Text('Special Request',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type selector
            const Text(
              'Request Type',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: kParentDark),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: SpecialRequestType.values.map((t) {
                final sel = t == _type;
                return GestureDetector(
                  onTap: () => setState(() => _type = t),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? kParentPrimary : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: sel ? kParentPrimary : Colors.grey[300]!),
                    ),
                    child: Text(
                      _typeLabels[t] ?? t.name,
                      style: TextStyle(
                        color: sel ? Colors.white : Colors.grey[700],
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Teacher selector
            const Text(
              'Send To (Teacher)',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: kParentDark),
            ),
            const SizedBox(height: 10),
            if (widget.student.classId.isEmpty)
              const NoClassPlaceholder()
            else StreamBuilder<ClassModel?>(
              stream: Stream.fromFuture(
                  fs.getClass(widget.student.classId)),
              builder: (ctx, snap) {
                final cls = snap.data;
                if (cls == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Build teacher list: class teacher + subject teachers + proctor
                final teacherUids = <String, String>{};
                if (cls.classTeacherUid.isNotEmpty) {
                  teacherUids[cls.classTeacherUid] = 'Class Teacher';
                }
                if (cls.proctorTeacherUid.isNotEmpty) {
                  teacherUids[cls.proctorTeacherUid] = 'Mentor/Proctor';
                }
                for (final st in cls.subjectTeachers) {
                  teacherUids[st.teacherUid] =
                      '${st.subject} Teacher';
                }

                if (teacherUids.isEmpty) {
                  return Text('No teachers assigned yet',
                      style: TextStyle(color: Colors.grey[500]));
                }

                return Column(
                  children: teacherUids.entries.map((e) {
                    return FutureBuilder<UserModel?>(
                      future: fs.getUser(e.key),
                      builder: (ctx2, uSnap) {
                        final teacher = uSnap.data;
                        final name =
                            teacher?.name ?? 'Loading...';
                        final isSelected =
                            _selectedTeacherUid == e.key;
                        return GestureDetector(
                          onTap: () => setState(() {
                            _selectedTeacherUid  = e.key;
                            _selectedTeacherName = name;
                          }),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? kParentPrimary.withValues(alpha: 0.08)
                                  : Colors.white,
                              borderRadius:
                                  BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? kParentPrimary
                                    : Colors.grey[300]!,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: kParentPrimary
                                      .withValues(alpha: 0.1),
                                  child: Text(
                                    name.isNotEmpty
                                        ? name[0].toUpperCase()
                                        : 'T',
                                    style: const TextStyle(
                                      color: kParentPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                          color: kParentDark,
                                        ),
                                      ),
                                      Text(
                                        e.value,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    color: kParentPrimary,
                                    size: 20,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 20),

            // Subject
            const Text(
              'Subject / Title *',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: kParentDark),
            ),
            const SizedBox(height: 10),
            _buildField(_subjectCtrl, 'Brief subject of your request'),
            const SizedBox(height: 16),

            // Description
            const Text(
              'Description *',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: kParentDark),
            ),
            const SizedBox(height: 10),
            _buildField(
              _descCtrl,
              'Describe your request in detail...',
              maxLines: 5,
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kParentPrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text(
                        'Submit Request',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String hint,
      {int maxLines = 1}) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: kParentPrimary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}
