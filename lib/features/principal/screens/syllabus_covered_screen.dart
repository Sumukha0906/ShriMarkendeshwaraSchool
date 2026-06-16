import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/class_model.dart';
import '../../../core/models/lesson_plan.dart';
import '../../../core/providers/core_providers.dart';

class SyllabusCoveredScreen extends ConsumerStatefulWidget {
  const SyllabusCoveredScreen({super.key});

  @override
  ConsumerState<SyllabusCoveredScreen> createState() =>
      _SyllabusCoveredScreenState();
}

class _SyllabusCoveredScreenState extends ConsumerState<SyllabusCoveredScreen> {
  static const _blue = Color(0xFF3B82F6);
  static const _bg   = Color(0xFFF5F6FA);

  ClassModel? _selectedClass;
  String?     _selectedSubject;

  @override
  Widget build(BuildContext context) {
    final user     = ref.watch(currentUserProvider).value;
    final schoolId = user?.schoolId ?? '';

    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: StreamBuilder<List<ClassModel>>(
              stream: ref
                  .watch(firestoreServiceProvider)
                  .streamSchoolClasses(schoolId),
              builder: (context, snap) {
                final classes = snap.data ?? [];
                return _buildBody(classes);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F1F3D), Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Syllabus Covered',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800)),
                Text('Lesson plans by class & subject',
                    style: TextStyle(
                        color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.library_books_rounded,
              color: Colors.white70, size: 22),
        ],
      ),
    );
  }

  Widget _buildBody(List<ClassModel> classes) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Class selector
          _sectionLabel('Select Class'),
          const SizedBox(height: 10),
          _buildClassChips(classes),
          const SizedBox(height: 20),

          // Subject selector (only if class is selected)
          if (_selectedClass != null) ...[
            _sectionLabel('Select Subject'),
            const SizedBox(height: 10),
            _buildSubjectChips(_selectedClass!),
            const SizedBox(height: 20),
          ],

          // Lesson plans list
          if (_selectedClass != null) ...[
            _sectionLabel(_selectedSubject != null
                ? 'Lesson Plans — $_selectedSubject'
                : 'All Lesson Plans — ${_selectedClass!.displayName}'),
            const SizedBox(height: 10),
            _buildLessonPlansList(),
          ] else ...[
            _buildEmptyClassPrompt(),
          ],
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0A0F1E)),
      );

  Widget _buildClassChips(List<ClassModel> classes) {
    if (classes.isEmpty) {
      return Text('No classes found',
          style: TextStyle(color: Colors.grey[400], fontSize: 13));
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: classes.map((cls) {
        final selected = _selectedClass?.classId == cls.classId;
        return GestureDetector(
          onTap: () => setState(() {
            _selectedClass   = cls;
            _selectedSubject = null;
          }),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? _blue : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: selected
                      ? _blue
                      : const Color(0xFFE5E7EB)),
              boxShadow: selected
                  ? [
                      BoxShadow(
                          color: _blue.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 2))
                    ]
                  : [],
            ),
            child: Text(
              cls.displayName,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : const Color(0xFF374151)),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSubjectChips(ClassModel cls) {
    final subjects = cls.subjectTeachers.map((st) => st.subject).toList();
    if (subjects.isEmpty) {
      return Text('No subjects assigned yet',
          style: TextStyle(color: Colors.grey[400], fontSize: 13));
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // "All" chip
        GestureDetector(
          onTap: () => setState(() => _selectedSubject = null),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _selectedSubject == null
                  ? _blue
                  : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: _selectedSubject == null
                      ? _blue
                      : const Color(0xFFE5E7EB)),
            ),
            child: Text('All',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _selectedSubject == null
                        ? Colors.white
                        : const Color(0xFF374151))),
          ),
        ),
        ...subjects.map((sub) {
          final selected = _selectedSubject == sub;
          return GestureDetector(
            onTap: () => setState(() => _selectedSubject = sub),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? _blue : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: selected
                        ? _blue
                        : const Color(0xFFE5E7EB)),
                boxShadow: selected
                    ? [
                        BoxShadow(
                            color: _blue.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 2))
                      ]
                    : [],
              ),
              child: Text(
                sub,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : const Color(0xFF374151)),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildLessonPlansList() {
    final fs = ref.watch(firestoreServiceProvider);
    return StreamBuilder<List<LessonPlan>>(
      stream: fs.streamClassLessonPlans(
        _selectedClass!.classId,
        subject: _selectedSubject ?? '',
      ),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
              child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(color: _blue),
          ));
        }
        final plans = snap.data ?? [];
        if (plans.isEmpty) {
          return _emptyPlans();
        }
        return Column(
          children: plans.map(_planTile).toList(),
        );
      },
    );
  }

  Widget _planTile(LessonPlan plan) {
    final dateStr =
        '${plan.date.day}/${plan.date.month}/${plan.date.year}';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8)
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date badge
          Container(
            width: 44,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: _blue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  plan.date.day.toString(),
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _blue,
                      height: 1.0),
                ),
                Text(
                  _monthAbbr(plan.date.month),
                  style: const TextStyle(
                      fontSize: 10,
                      color: _blue,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: _blue.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(plan.subject,
                          style: const TextStyle(
                              fontSize: 10,
                              color: _blue,
                              fontWeight: FontWeight.w700)),
                    ),
                    const Spacer(),
                    Text(dateStr,
                        style: TextStyle(
                            fontSize: 10, color: Colors.grey[400])),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  plan.topicsCovered,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0A0F1E)),
                ),
                if (plan.homework.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.assignment_outlined,
                          size: 12, color: Color(0xFFD97706)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'HW: ${plan.homework}',
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFFD97706)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                if (plan.notes.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    plan.notes,
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey[500]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyPlans() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Icon(Icons.library_books_outlined, size: 36, color: Colors.grey[300]),
          const SizedBox(height: 10),
          Text(
            _selectedSubject != null
                ? 'No lesson plans for $_selectedSubject yet'
                : 'No lesson plans posted yet',
            style: TextStyle(
                color: Colors.grey[400],
                fontSize: 13,
                fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text('Teachers post lesson plans from their dashboard',
              style: TextStyle(color: Colors.grey[300], fontSize: 11),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildEmptyClassPrompt() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: _blue.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.touch_app_rounded, color: _blue, size: 28),
          ),
          const SizedBox(height: 12),
          const Text('Select a class above',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0A0F1E))),
          const SizedBox(height: 4),
          Text('Then optionally filter by subject to see lesson plans',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  String _monthAbbr(int m) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[m.clamp(1, 12)];
  }
}
