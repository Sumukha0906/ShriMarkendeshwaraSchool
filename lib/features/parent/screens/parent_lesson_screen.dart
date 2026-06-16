import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/models/student.dart';
import '../../../core/models/lesson_plan.dart';
import '../parent_dashboard.dart';

/// Shows lesson plans for the student's class.
/// Default: today (after 9 AM) or yesterday (before 9 AM).
/// Parent can navigate dates with arrows or tap the date chip.
class ParentLessonScreen extends ConsumerStatefulWidget {
  final Student student;
  final DateTime? initialDate;
  const ParentLessonScreen({super.key, required this.student, this.initialDate});

  @override
  ConsumerState<ParentLessonScreen> createState() =>
      _ParentLessonScreenState();
}

class _ParentLessonScreenState extends ConsumerState<ParentLessonScreen> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.initialDate != null) {
      _selectedDate = DateTime(
        widget.initialDate!.year,
        widget.initialDate!.month,
        widget.initialDate!.day,
      );
    } else {
      final now = DateTime.now();
      _selectedDate = now.hour >= 9
          ? DateTime(now.year, now.month, now.day)
          : DateTime(now.year, now.month, now.day - 1);
    }
  }

  void _prevDay() =>
      setState(() => _selectedDate = _selectedDate.subtract(const Duration(days: 1)));
  void _nextDay() {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    if (_selectedDate.isBefore(
        DateTime(tomorrow.year, tomorrow.month, tomorrow.day))) {
      setState(() => _selectedDate = _selectedDate.add(const Duration(days: 1)));
    }
  }

  bool get _isToday {
    final now = DateTime.now();
    return _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final fs = ref.watch(firestoreServiceProvider);
    return Scaffold(
      backgroundColor: kParentBg,
      appBar: AppBar(
        backgroundColor: kParentDark,
        foregroundColor: Colors.white,
        title: const Text("Lesson Plans",
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          // Date navigator
          Container(
            color: kParentDark,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _prevDay,
                  icon: const Icon(Icons.chevron_left_rounded,
                      color: Colors.white),
                ),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2024),
                      lastDate: DateTime.now().add(const Duration(days: 1)),
                      builder: (ctx, child) => Theme(
                        data: ThemeData.light().copyWith(
                          colorScheme:
                              const ColorScheme.light(primary: kParentPrimary),
                        ),
                        child: child!,
                      ),
                    );
                    if (picked != null) setState(() => _selectedDate = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            color: kParentAmber, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          _isToday
                              ? "Today — ${DateFormat('MMM d').format(_selectedDate)}"
                              : DateFormat('EEEE, MMM d, yyyy')
                                  .format(_selectedDate),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _nextDay,
                  icon: const Icon(Icons.chevron_right_rounded,
                      color: Colors.white),
                ),
              ],
            ),
          ),

          // Lesson plans list
          Expanded(
            child: StreamBuilder<List<LessonPlan>>(
              stream: fs.streamLessonPlansForClass(
                  widget.student.classId,
                  date: _selectedDate),
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: kParentPrimary));
                }
                final plans = snap.data ?? [];
                if (plans.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.menu_book_outlined,
                            size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'No lesson plans for this day',
                          style: TextStyle(
                              color: Colors.grey[500], fontSize: 15),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Your teacher may not have posted yet',
                          style: TextStyle(
                              color: Colors.grey[400], fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: plans.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) => _LessonCard(plan: plans[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  final LessonPlan plan;
  const _LessonCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kParentAmber.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  kParentAmber.withValues(alpha: 0.15),
                  kParentPrimary.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: kParentAmber,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.auto_stories_rounded,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    plan.subject,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: kParentDark,
                    ),
                  ),
                ),
                Text(
                  DateFormat('h:mm a').format(plan.createdAt ?? plan.date),
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoRow(Icons.topic_rounded, 'Topics Covered',
                    plan.topicsCovered),
                if (plan.homework.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: kParentPrimary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: kParentPrimary.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.assignment_rounded,
                            color: kParentPrimary, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Homework',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: kParentPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                plan.homework,
                                style: const TextStyle(
                                    fontSize: 13, color: kParentDark),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (plan.notes.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _infoRow(Icons.notes_rounded, 'Notes', plan.notes),
                ],
                if (plan.attachmentUrls.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _attachmentsSection(plan.attachmentUrls, plan.attachmentNames),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _attachmentsSection(List<String> urls, List<String> names) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.attach_file_rounded,
                color: kParentPrimary, size: 16),
            const SizedBox(width: 6),
            Text(
              'Attachments',
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: List.generate(urls.length, (i) {
            final name = i < names.length ? names[i] : 'File ${i + 1}';
            final ext  = name.contains('.') ? name.split('.').last.toLowerCase() : '';
            return GestureDetector(
              onTap: () async {
                final uri = Uri.tryParse(urls[i]);
                if (uri != null) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: kParentPrimary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: kParentPrimary.withValues(alpha: 0.25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_fileIcon(ext), color: kParentPrimary, size: 15),
                    const SizedBox(width: 5),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 160),
                      child: Text(
                        name,
                        style: const TextStyle(
                            fontSize: 11,
                            color: kParentPrimary,
                            fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  IconData _fileIcon(String ext) {
    switch (ext) {
      case 'pdf':  return Icons.picture_as_pdf_rounded;
      case 'png':
      case 'jpg':
      case 'jpeg': return Icons.image_rounded;
      case 'doc':
      case 'docx': return Icons.description_rounded;
      default:     return Icons.insert_drive_file_rounded;
    }
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 13, color: kParentDark),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
