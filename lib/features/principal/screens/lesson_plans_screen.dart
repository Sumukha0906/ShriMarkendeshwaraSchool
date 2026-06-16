import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/models/lesson_plan.dart';
import '../../../core/models/class_model.dart';

class LessonPlansScreen extends ConsumerStatefulWidget {
  const LessonPlansScreen({super.key});

  @override
  ConsumerState<LessonPlansScreen> createState() => _LessonPlansScreenState();
}

class _LessonPlansScreenState extends ConsumerState<LessonPlansScreen> {
  DateTime _selectedDate = DateTime.now();

  static const _blue = Color(0xFF3B82F6);

  void _pickDate() async {
    final picked = await showDatePicker(
      context:     context,
      initialDate: _selectedDate,
      firstDate:   DateTime(2020),
      lastDate:    DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: _blue),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).value;
    if (user == null) return const SizedBox.shrink();

    final dateLabel = _isToday(_selectedDate)
        ? 'Today'
        : '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
        title: const Text('Lesson Plans',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        elevation: 0,
        actions: [
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_today_rounded,
                      size: 14, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(dateLabel,
                      style: const TextStyle(
                          color:      Colors.white,
                          fontSize:   12,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDateBar(dateLabel),
          Expanded(
            child: _buildPlansByClass(user.schoolId),
          ),
        ],
      ),
    );
  }

  Widget _buildDateBar(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          Icon(Icons.today_rounded, size: 16, color: Colors.grey[500]),
          const SizedBox(width: 8),
          Text('Showing plans for: ',
              style: TextStyle(fontSize: 13, color: Colors.grey[500])),
          Text(label,
              style: const TextStyle(
                  fontSize:   13,
                  fontWeight: FontWeight.w700,
                  color:      Color(0xFF0A0F1E))),
          const Spacer(),
          // Day navigation
          GestureDetector(
            onTap: () => setState(() =>
                _selectedDate = _selectedDate.subtract(const Duration(days: 1))),
            child: Icon(Icons.chevron_left_rounded,
                color: Colors.grey[400], size: 20),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: _isToday(_selectedDate)
                ? null
                : () => setState(() =>
                    _selectedDate = _selectedDate.add(const Duration(days: 1))),
            child: Icon(Icons.chevron_right_rounded,
                color: _isToday(_selectedDate)
                    ? Colors.grey[200]
                    : Colors.grey[400],
                size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildPlansByClass(String schoolId) {
    // Stream classes, then for each class stream lesson plans for selected date
    return StreamBuilder<List<ClassModel>>(
      stream: ref
          .watch(firestoreServiceProvider)
          .streamSchoolClasses(schoolId),
      builder: (context, classSnap) {
        if (classSnap.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: _blue));
        }
        final classes = classSnap.data ?? [];
        if (classes.isEmpty) {
          return _emptyState('No classes found',
              'Create classes first to see lesson plans');
        }

        return StreamBuilder<List<LessonPlan>>(
          stream: ref
              .watch(firestoreServiceProvider)
              .streamSchoolLessonPlans(schoolId, date: _selectedDate),
          builder: (context, planSnap) {
            if (planSnap.connectionState == ConnectionState.waiting &&
                !planSnap.hasData) {
              return const Center(
                  child: CircularProgressIndicator(color: _blue));
            }

            final plans = planSnap.data ?? [];

            if (plans.isEmpty) {
              return _emptyState(
                'No lesson plans for this day',
                'Teachers haven\'t submitted any plans yet',
              );
            }

            // Group plans by classId
            final byClass = <String, List<LessonPlan>>{};
            for (final plan in plans) {
              byClass.putIfAbsent(plan.classId, () => []).add(plan);
            }

            final classesWithPlans = classes
                .where((c) => byClass.containsKey(c.classId))
                .toList();

            if (classesWithPlans.isEmpty) {
              return _emptyState(
                'No lesson plans for this day',
                'Teachers haven\'t submitted any plans yet',
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: classesWithPlans.length,
              itemBuilder: (_, i) {
                final cls      = classesWithPlans[i];
                final clsPlans = byClass[cls.classId] ?? [];
                return _classCard(cls, clsPlans);
              },
            );
          },
        );
      },
    );
  }

  Widget _classCard(ClassModel cls, List<LessonPlan> plans) {
    final className = cls.section.isNotEmpty
        ? '${cls.name} – ${cls.section}'
        : cls.name;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color:      Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset:     const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Class header
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color:        _blue.withValues(alpha: 0.06),
              borderRadius: const BorderRadius.only(
                topLeft:  Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color:        _blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.class_rounded,
                      color: _blue, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(className,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize:   14,
                          color:      Color(0xFF0A0F1E))),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color:        _blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('${plans.length} subject${plans.length > 1 ? 's' : ''}',
                      style: const TextStyle(
                          fontSize:   10,
                          color:      _blue,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
          // Plans
          ...plans.map((plan) => _planTile(plan)),
        ],
      ),
    );
  }

  Widget _planTile(LessonPlan plan) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(color: Colors.grey[100]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color:        const Color(0xFF3B82F6).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(plan.subject,
                    style: const TextStyle(
                        fontSize:   11,
                        color:      _blue,
                        fontWeight: FontWeight.w700)),
              ),
              const Spacer(),
              Text(_timeAgo(plan.createdAt),
                  style: TextStyle(fontSize: 10, color: Colors.grey[400])),
            ],
          ),
          const SizedBox(height: 8),
          Text(plan.topicsCovered,
              style: const TextStyle(
                  fontSize:   13,
                  fontWeight: FontWeight.w600,
                  color:      Color(0xFF0A0F1E))),
          if (plan.homework.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.assignment_outlined,
                    size: 13, color: Color(0xFFD97706)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text('HW: ${plan.homework}',
                      style: const TextStyle(
                          fontSize: 12,
                          color:    Color(0xFFD97706))),
                ),
              ],
            ),
          ],
          if (plan.notes.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.notes_rounded,
                    size: 13, color: Colors.grey[400]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(plan.notes,
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey[500])),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _emptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color:  _blue.withValues(alpha: 0.1),
              shape:  BoxShape.circle,
            ),
            child: const Icon(Icons.book_outlined, color: _blue, size: 32),
          ),
          const SizedBox(height: 16),
          Text(title,
              style: const TextStyle(
                  fontSize:   18,
                  fontWeight: FontWeight.w700,
                  color:      Color(0xFF0A0F1E))),
          const SizedBox(height: 8),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[500])),
        ],
      ),
    );
  }

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  String _timeAgo(DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}
