import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firestore_constants.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/models/student.dart';
import '../../../core/models/class_model.dart';
import '../../admin/screens/admin_student_detail_screen.dart';

class SchoolStudentsScreen extends ConsumerStatefulWidget {
  const SchoolStudentsScreen({super.key});

  @override
  ConsumerState<SchoolStudentsScreen> createState() =>
      _SchoolStudentsScreenState();
}

class _SchoolStudentsScreenState extends ConsumerState<SchoolStudentsScreen> {
  static const _green = Color(0xFF059669);
  static const _blue  = Color(0xFF3B82F6);

  List<ClassModel> _classes = [];
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(
        () => setState(() => _searchQuery = _searchCtrl.text.toLowerCase()));
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadClasses());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadClasses() async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;
    final fs = ref.read(firestoreServiceProvider);
    final classes = await fs.streamSchoolClasses(user.schoolId).first;
    if (mounted) setState(() => _classes = classes);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).value;
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
        title: const Text('All Students',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(FSC.students)
            .where('schoolId', isEqualTo: user.schoolId)
            .where('isActive', isEqualTo: true)
            .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: _blue));
          }
          if (snap.hasError) {
            return Center(
                child: Text('Error loading students',
                    style: TextStyle(color: Colors.grey[400])));
          }
          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) return _emptyState(context);

          final allStudents = <Student>[];
          for (final doc in docs) {
            try {
              allStudents.add(Student.fromFirestore(doc));
            } catch (_) {}
          }
          allStudents.sort((a, b) => a.name.compareTo(b.name));

          final students = _searchQuery.isEmpty
              ? allStudents
              : allStudents.where((s) {
                  final name = s.name.toLowerCase();
                  final cls  = _classes
                      .where((c) => c.classId == s.classId)
                      .map((c) => c.displayName.toLowerCase())
                      .firstOrNull ?? '';
                  final roll = s.rollNo.toLowerCase();
                  final adm  = s.admissionNo.toLowerCase();
                  return name.contains(_searchQuery) ||
                      cls.contains(_searchQuery) ||
                      roll.contains(_searchQuery) ||
                      adm.contains(_searchQuery);
                }).toList();

          return Column(
            children: [
              // Search bar
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                child: TextField(
                  controller: _searchCtrl,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search by name, class, roll or admission no…',
                    hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () => _searchCtrl.clear(),
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: _blue)),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
              ),
              // Count banner
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                color: Colors.white,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color:        _green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _searchQuery.isEmpty
                            ? '${students.length} students'
                            : '${students.length} of ${allStudents.length} students',
                        style: const TextStyle(
                            fontSize:   12,
                            fontWeight: FontWeight.w700,
                            color:      _green)),
                    ),
                    const Spacer(),
                    Text('Sorted A–Z',
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey[400])),
                  ],
                ),
              ),
              Expanded(
                child: students.isEmpty
                    ? Center(
                        child: Text(
                          'No students match "$_searchQuery"',
                          style: TextStyle(color: Colors.grey[400], fontSize: 14),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                        itemCount: students.length,
                        itemBuilder: (_, i) => _studentCard(students[i]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _studentCard(Student s) {
    final initials = s.name.isNotEmpty
        ? s.name.trim().split(' ').take(2).map((w) => w[0].toUpperCase()).join()
        : '?';
    final className = _classes
        .where((c) => c.classId == s.classId)
        .map((c) => c.displayName)
        .firstOrNull ?? '';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AdminStudentDetailScreen(student: s),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color:        _green.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(initials,
                    style: const TextStyle(
                        color: _green, fontWeight: FontWeight.w800, fontSize: 16)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize:   14,
                          color:      Color(0xFF0A0F1E))),
                  Text(
                    [
                      if (className.isNotEmpty) className,
                      if (s.rollNo.isNotEmpty) 'Roll: ${s.rollNo}'
                      else if (s.admissionNo.isNotEmpty) 'Adm: ${s.admissionNo}',
                    ].join(' · '),
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color:  _green.withValues(alpha: 0.1),
              shape:  BoxShape.circle,
            ),
            child: const Icon(Icons.people_outline_rounded,
                color: _green, size: 32),
          ),
          const SizedBox(height: 16),
          const Text('No students enrolled',
              style: TextStyle(
                  fontSize:   18,
                  fontWeight: FontWeight.w700,
                  color:      Color(0xFF0A0F1E))),
          const SizedBox(height: 8),
          Text('Students can be added from the Admin panel',
              style: TextStyle(fontSize: 14, color: Colors.grey[500])),
        ],
      ),
    );
  }
}
