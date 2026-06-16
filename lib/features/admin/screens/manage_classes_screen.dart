import 'package:shalalink/core/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firestore_constants.dart';
import '../../../core/models/class_model.dart';
import '../../../core/providers/core_providers.dart';
import '../../principal/screens/manage_class_teachers_screen.dart';
import '../../principal/screens/manage_timetable_screen.dart';

class ManageClassesScreen extends ConsumerStatefulWidget {
  const ManageClassesScreen({super.key});

  @override
  ConsumerState<ManageClassesScreen> createState() =>
      _ManageClassesScreenState();
}

class _ManageClassesScreenState extends ConsumerState<ManageClassesScreen> {
  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.value;
    if (user == null) return const SizedBox();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ───────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            decoration: const BoxDecoration(
              color: Color(0xFF0A0F1E),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Classes',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'View all classes & sections',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Classes list ──────────────────────────────────
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(FSC.classes)
                  .where('schoolId', isEqualTo: user.schoolId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF059669),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyClasses(context);
                }

                final classes = snapshot.data!.docs
                    .map((d) => ClassModel.fromFirestore(d))
                    .toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: classes.length,
                  itemBuilder: (context, index) =>
                      _buildClassCard(context, classes[index], user.schoolId),
                );
              },
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildClassCard(
      BuildContext context, ClassModel cls, String schoolId) {
    final userAsync = ref.read(currentUserProvider);
    final isPrincipal = userAsync.value?.isPrincipal ?? false;
    final isSchoolAdmin = userAsync.value?.isSchoolAdmin ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: const Border(
          left: BorderSide(color: Color(0xFF065F46), width: 4),
          top: BorderSide(color: Color(0xFFD97706), width: 2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF059669), Color(0xFF065F46)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      cls.name.length > 2 ? cls.name.substring(0, 2) : cls.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cls.displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0A0F1E),
                        ),
                      ),
                      if (cls.classTeacherUid.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        const Row(
                          children: [
                            Icon(Icons.school_rounded, size: 12,
                                color: Color(0xFF059669)),
                            SizedBox(width: 4),
                            Flexible(
                              child: Text('Class teacher set',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF059669),
                                      fontWeight: FontWeight.w500)),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                Divider(color: Colors.grey.shade100),
                const SizedBox(height: 8),

                // Row 1: Students + Timetable
                Row(
                  children: [
                    Expanded(
                      child: _buildClassAction(
                        icon: Icons.people_alt_rounded,
                        label: 'Students',
                        color: const Color(0xFF3B82F6),
                        onTap: () => _showStudentsInClass(
                            context, cls, schoolId),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildClassAction(
                        icon: Icons.schedule_rounded,
                        label: 'Timetable',
                        color: const Color(0xFFF59E0B),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ManageTimetableScreen(cls: cls),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Row 2: Assign Teachers (Principal or Admin)
                if (isPrincipal || isSchoolAdmin) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildClassAction(
                          icon: Icons.manage_accounts_rounded,
                          label: 'Assign Teachers',
                          color: const Color(0xFF1D4ED8),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ManageClassTeachersScreen(cls: cls),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyClasses(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.class_rounded,
                color: Color(0xFF059669),
                size: 36,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Classes Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0A0F1E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Contact your school administrator to create classes',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStudentsInClass(
      BuildContext context, ClassModel cls, String schoolId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF059669), Color(0xFF065F46)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        cls.name.length > 2
                            ? cls.name.substring(0, 2)
                            : cls.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      cls.displayName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0A0F1E),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: Colors.grey.shade100, height: 1),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection(FSC.students)
                    .where('classId', isEqualTo: cls.classId)
                    .snapshots(),
                builder: (context, snapshot) {
                  final activeDocs = snapshot.data?.docs.where((d) =>
                      (d.data() as Map<String, dynamic>)['isActive'] == true).toList() ?? [];
                  if (!snapshot.hasData || activeDocs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline,
                              size: 48,
                              color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text(
                            'No students in this class',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: activeDocs.length,
                    separatorBuilder: (_, __) =>
                        Divider(color: Colors.grey.shade100),
                    itemBuilder: (context, index) {
                      final doc = activeDocs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFECFDF5),
                          child: Text(
                            (data['name'] as String? ?? 'S')[0]
                                .toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFF059669),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        title: Text(
                          data['name'] as String? ?? 'Unknown',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          'Roll: ${data['rollNo'] ?? '—'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        trailing: PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert_rounded,
                              color: Colors.grey.shade400),
                          onSelected: (value) {
                            if (value == 'remove') {
                              _removeStudentFromClass(
                                  context, doc.id, data['name'] ?? 'Student', cls);
                            } else if (value == 'transfer') {
                              _transferStudentDialog(
                                  context, doc.id, data['name'] ?? 'Student',
                                  cls, schoolId);
                            }
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                              value: 'transfer',
                              child: Row(
                                children: [
                                  Icon(Icons.swap_horiz_rounded,
                                      size: 18, color: Color(0xFF3B82F6)),
                                  SizedBox(width: 8),
                                  Text('Transfer to Class'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'remove',
                              child: Row(
                                children: [
                                  Icon(Icons.remove_circle_outline_rounded,
                                      size: 18, color: Color(0xFFEF4444)),
                                  SizedBox(width: 8),
                                  Text('Remove from Class',
                                      style: TextStyle(
                                          color: Color(0xFFEF4444))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _removeStudentFromClass(
      BuildContext context, String studentId, String studentName, ClassModel cls) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove Student'),
        content: Text(
            'Remove $studentName from ${cls.displayName}? The student will be unassigned from this class.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Remove',
                  style: TextStyle(color: Color(0xFFEF4444)))),
        ],
      ),
    );
    if (confirmed != true) return;

    await FirebaseFirestore.instance
        .collection(FSC.students)
        .doc(studentId)
        .update({'classId': null});

    await FirebaseFirestore.instance
        .collection(FSC.classes)
        .doc(cls.classId)
        .update({'studentCount': FieldValue.increment(-1)});

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$studentName removed from ${cls.displayName}')),
      );
    }
  }

  void _transferStudentDialog(BuildContext context, String studentId,
      String studentName, ClassModel currentCls, String schoolId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        maxChildSize: 0.85,
        builder: (ctx, scrollCtrl) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(Icons.swap_horiz_rounded,
                      color: Color(0xFF3B82F6)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Transfer Student',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700)),
                        Text('Select a class for $studentName',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: Colors.grey.shade100, height: 1),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection(FSC.classes)
                    .where('schoolId', isEqualTo: schoolId)
                    .snapshots(),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final classes = snap.data!.docs
                      .where((d) => d.id != currentCls.classId)
                      .toList();
                  if (classes.isEmpty) {
                    return Center(
                      child: Text('No other classes available',
                          style: TextStyle(color: Colors.grey.shade500)),
                    );
                  }
                  return ListView.separated(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.all(16),
                    itemCount: classes.length,
                    separatorBuilder: (_, __) =>
                        Divider(color: Colors.grey.shade100),
                    itemBuilder: (context, i) {
                      final clsData =
                          classes[i].data() as Map<String, dynamic>;
                      final targetName =
                          '${clsData['name'] ?? ''}${clsData['section']?.isNotEmpty == true ? ' - ${clsData['section']}' : ''}';
                      return ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.class_rounded,
                              color: Color(0xFF3B82F6), size: 20),
                        ),
                        title: Text(targetName,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14)),
                        subtitle: null,
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () async {
                          Navigator.pop(ctx);
                          await FirebaseFirestore.instance
                              .collection(FSC.students)
                              .doc(studentId)
                              .update({'classId': classes[i].id});
                          await Future.wait([
                            FirebaseFirestore.instance
                                .collection(FSC.classes)
                                .doc(currentCls.classId)
                                .update({
                              'studentCount': FieldValue.increment(-1)
                            }),
                            FirebaseFirestore.instance
                                .collection(FSC.classes)
                                .doc(classes[i].id)
                                .update({
                              'studentCount': FieldValue.increment(1)
                            }),
                          ]);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      '$studentName transferred to $targetName')),
                            );
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

}