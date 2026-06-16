import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/models/student.dart';
import '../../../core/models/class_model.dart';
import 'admin_student_detail_screen.dart';

const _kPrimary      = Color(0xFF065F46);
const _kDark         = Color(0xFF022C22);
const _kBg           = Color(0xFFF0FDF4);
const _kNavy         = Color(0xFF0A0F1E);
const _kRed          = Color(0xFFEF4444);
// Sentinel value used in the class filter to represent "unassigned students".
const _kUnassigned   = '__unassigned__';

class AdminStudentsScreen extends ConsumerStatefulWidget {
  const AdminStudentsScreen({super.key});

  @override
  ConsumerState<AdminStudentsScreen> createState() =>
      _AdminStudentsScreenState();
}

class _AdminStudentsScreenState extends ConsumerState<AdminStudentsScreen> {
  String _searchQuery = '';
  String? _selectedClassId;
  List<ClassModel> _classes = [];
  bool _classesLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadClasses());
  }

  Future<void> _loadClasses() async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;
    final fs = ref.read(firestoreServiceProvider);
    fs.streamSchoolClasses(user.schoolId).first.then((classes) {
      if (mounted) {
        setState(() {
          _classes = classes;
          _classesLoaded = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.value;
    if (user == null) {
      return const Center(child: CircularProgressIndicator(color: _kPrimary));
    }
    final fs = ref.read(firestoreServiceProvider);

    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          // Header with search
          Container(
            padding: const EdgeInsets.fromLTRB(16, 52, 16, 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF022C22), _kDark],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pattern G — accent bar header
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 22,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD97706),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Students',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: const InputDecoration(
                      hintText: 'Search by name, roll no, admission no…',
                      prefixIcon: Icon(Icons.search_rounded,
                          color: _kPrimary),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      hintStyle: TextStyle(fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Class filter chips (includes "Unassigned" for easy assignment)
          if (_classesLoaded)
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                children: [
                  _ClassChip(
                    label: 'All',
                    selected: _selectedClassId == null,
                    onTap: () =>
                        setState(() => _selectedClassId = null),
                  ),
                  _ClassChip(
                    label: 'Unassigned',
                    selected: _selectedClassId == _kUnassigned,
                    onTap: () =>
                        setState(() => _selectedClassId = _kUnassigned),
                    color: const Color(0xFFF59E0B),
                  ),
                  ..._classes.map((cls) => _ClassChip(
                        label: cls.name,
                        selected: _selectedClassId == cls.classId,
                        onTap: () => setState(
                            () => _selectedClassId = cls.classId),
                      )),
                ],
              ),
            ),

          // Students list
          Expanded(
            child: StreamBuilder<List<Student>>(
              stream: fs.streamSchoolStudents(user.schoolId),
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: _kPrimary));
                }
                if (snap.hasError) {
                  return Center(
                      child: Text('Error: ${snap.error}',
                          style: const TextStyle(color: _kRed)));
                }

                var students = (snap.data ?? [])
                    .where((s) => s.isActive)
                    .toList();

                // Filter by class (or unassigned)
                if (_selectedClassId == _kUnassigned) {
                  students = students
                      .where((s) => s.classId.trim().isEmpty)
                      .toList();
                } else if (_selectedClassId != null) {
                  students = students
                      .where((s) => s.classId == _selectedClassId)
                      .toList();
                }

                // Filter by search query
                if (_searchQuery.isNotEmpty) {
                  final q = _searchQuery.toLowerCase();
                  students = students.where((s) {
                    return s.name.toLowerCase().contains(q) ||
                        s.rollNo.toLowerCase().contains(q) ||
                        s.admissionNo.toLowerCase().contains(q);
                  }).toList();
                }

                // Sort by name
                students.sort(
                    (a, b) => a.name.compareTo(b.name));

                if (students.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.people_outline_rounded,
                            size: 52,
                            color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'No students match your search'
                              : _selectedClassId == _kUnassigned
                                  ? 'All students are assigned to a class'
                                  : 'No students found',
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey.shade500),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: students.length,
                  itemBuilder: (_, i) {
                    final s = students[i];
                    final className = _classes
                        .where((c) => c.classId == s.classId)
                        .map((c) => c.name)
                        .firstOrNull ?? s.classId;

                    return _StudentCard(
                      student: s,
                      className: className,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AdminStudentDetailScreen(
                              student: s),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ClassChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;
  const _ClassChip(
      {required this.label,
      required this.selected,
      required this.onTap,
      this.color});

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? _kPrimary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(right: 8),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? activeColor : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : _kNavy,
          ),
        ),
      ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  final Student student;
  final String className;
  final VoidCallback onTap;
  const _StudentCard(
      {required this.student,
      required this.className,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Pattern B — left border accent
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: const Border(left: BorderSide(color: _kPrimary, width: 4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Avatar
              student.photoUrl.isNotEmpty
                  ? CircleAvatar(
                      radius: 24,
                      backgroundImage:
                          NetworkImage(student.photoUrl),
                    )
                  : Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                            colors: [_kPrimary, _kDark]),
                      ),
                      child: Center(
                        child: Text(
                          student.name.isNotEmpty
                              ? student.name[0].toUpperCase()
                              : 'S',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
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
                      student.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _kNavy,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            className,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500),
                          ),
                        ),
                        if (student.rollNo.isNotEmpty) ...[
                          Text(' · ',
                              style: TextStyle(
                                  color: Colors.grey.shade400)),
                          Flexible(
                            child: Text(
                              'Roll ${student.rollNo}',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (student.admissionNo.isNotEmpty)
                      Text(
                        'Adm: ${student.admissionNo}',
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade400),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: Color(0xFFCBD5E1)),
            ],
          ),
        ),
      ),
    );
  }
}

