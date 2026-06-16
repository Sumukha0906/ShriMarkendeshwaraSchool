import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/models/student.dart';
import '../../../core/models/marks.dart';
import '../parent_dashboard.dart';

class ReportCardScreen extends ConsumerWidget {
  final Student student;
  const ReportCardScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fs = ref.watch(firestoreServiceProvider);

    return Scaffold(
      backgroundColor: kParentBg,
      appBar: AppBar(
        backgroundColor: kParentDark,
        foregroundColor: Colors.white,
        title: const Text('Report Card',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: StreamBuilder<List<StudentMarks>>(
        stream: fs.streamAllStudentMarks(student.studentId),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: kParentPrimary));
          }
          final allMarks = snap.data ?? [];
          final marks = List<StudentMarks>.from(allMarks);
          marks.sort((a, b) {
            final yearCmp = b.academicYear.compareTo(a.academicYear);
            if (yearCmp != 0) return yearCmp;
            return b.term.compareTo(a.term);
          });

          if (marks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined,
                      size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'No report cards published yet',
                    style:
                        TextStyle(color: Colors.grey[500], fontSize: 15),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: marks.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (ctx, i) => _ReportCard(
              marks: marks[i],
              studentName: student.name,
            ),
          );
        },
      ),
    );
  }
}

class _ReportCard extends StatefulWidget {
  final StudentMarks marks;
  final String studentName;
  const _ReportCard({required this.marks, required this.studentName});

  @override
  State<_ReportCard> createState() => _ReportCardState();
}

class _ReportCardState extends State<_ReportCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final pct = widget.marks.percentage;
    final grade = _gradeFromPct(pct);
    final (gradeColor, gradeBg) = _gradeTheme(grade);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    kParentPrimary.withValues(alpha: 0.08),
                    kParentAmber.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(20),
                  bottom: _expanded
                      ? Radius.zero
                      : const Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: gradeBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      grade,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: gradeColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.marks.academicYear} — ${widget.marks.term}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: kParentDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '${widget.marks.totalObtained.toStringAsFixed(0)}/'
                              '${widget.marks.totalMax.toStringAsFixed(0)}',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 12),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: gradeColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${pct.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: gradeColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),
          ),

          // Subject breakdown (expandable)
          if (_expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: pct / 100,
                      backgroundColor: Colors.grey[200],
                      color: gradeColor,
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...widget.marks.subjects.map(
                      (s) => _SubjectRow(subject: s)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _gradeFromPct(double pct) {
    if (pct >= 90) return 'A+';
    if (pct >= 80) return 'A';
    if (pct >= 70) return 'B';
    if (pct >= 60) return 'C';
    if (pct >= 50) return 'D';
    return 'F';
  }

  (Color, Color) _gradeTheme(String g) {
    switch (g) {
      case 'A+': return (const Color(0xFF059669), const Color(0xFFD1FAE5));
      case 'A':  return (const Color(0xFF0EA5E9), const Color(0xFFE0F2FE));
      case 'B':  return (kParentPrimary, const Color(0xFFFFEDD5));
      case 'C':  return (kParentAmber, const Color(0xFFD1FAE5));
      case 'D':  return (const Color(0xFFD97706), const Color(0xFFEDE9FE));
      default:   return (const Color(0xFFEF4444), const Color(0xFFFEE2E2));
    }
  }
}

class _SubjectRow extends StatelessWidget {
  final SubjectMark subject;
  const _SubjectRow({required this.subject});

  @override
  Widget build(BuildContext context) {
    final pct = subject.maxMarks > 0
        ? (subject.marksObtained / subject.maxMarks) * 100
        : 0.0;
    final barColor = pct >= 75
        ? const Color(0xFF059669)
        : pct >= 50
            ? kParentAmber
            : const Color(0xFFEF4444);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  subject.subject,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: kParentDark,
                  ),
                ),
              ),
              Row(
                children: [
                  Text(
                    '${subject.marksObtained.toStringAsFixed(0)}/${subject.maxMarks.toStringAsFixed(0)}',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w700),
                  ),
                  if (subject.grade.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: barColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        subject.grade,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: barColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct / 100,
              backgroundColor: Colors.grey[200],
              color: barColor,
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }
}
