import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/models/lesson_plan.dart';

const _kPrimary = Color(0xFF065F46);
const _kDark    = Color(0xFF022C22);
const _kBg      = Color(0xFFF0FDF4);
class MyLessonPlansScreen extends ConsumerStatefulWidget {
  final String teacherUid;
  final String? classId;
  final String? className;

  const MyLessonPlansScreen({
    super.key,
    required this.teacherUid,
    this.classId,
    this.className,
  });

  @override
  ConsumerState<MyLessonPlansScreen> createState() =>
      _MyLessonPlansScreenState();
}

class _MyLessonPlansScreenState extends ConsumerState<MyLessonPlansScreen> {
  String _filterSubject = 'All';
  List<String> _subjects = ['All'];

  @override
  Widget build(BuildContext context) {
    final fs = ref.watch(firestoreServiceProvider);

    final stream = widget.classId != null
        ? fs.streamTeacherLessonPlans(widget.teacherUid)
        : fs.streamTeacherLessonPlans(widget.teacherUid);

    return Scaffold(
      backgroundColor: _kBg,
      // Pattern A — rounded bottom AppBar
      appBar: AppBar(
        backgroundColor: _kDark,
        foregroundColor: Colors.white,
        title: Text(
          widget.className != null
              ? 'Plans for ${widget.className}'
              : 'My Lesson Plans',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: StreamBuilder<List<LessonPlan>>(
        stream: stream,
        builder: (ctx, snap) {
          final all = snap.data ?? [];
          final plans = widget.classId != null
              ? all.where((p) => p.classId == widget.classId).toList()
              : all;

          // Build subject filter list
          final subjectSet = {'All', ...plans.map((p) => p.subject)};
          if (!subjectSet.containsAll(_subjects) ||
              _subjects.length != subjectSet.length) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => _subjects = subjectSet.toList());
            });
          }

          final filtered = _filterSubject == 'All'
              ? plans
              : plans.where((p) => p.subject == _filterSubject).toList();

          return Column(
            children: [
              // Subject filter chips
              if (_subjects.length > 1)
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _subjects.map((s) {
                        final selected = _filterSubject == s;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _filterSubject = s),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: selected
                                  ? _kPrimary
                                  : _kPrimary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: _kPrimary.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              s,
                              style: TextStyle(
                                color: selected ? Colors.white : _kPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

              // Plans list
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _kPrimary.withValues(alpha: 0.08),
                              ),
                              child: Icon(Icons.book_outlined,
                                  size: 38, color: _kPrimary.withValues(alpha: 0.5)),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No lesson plans yet',
                              style: TextStyle(
                                  color: Colors.grey[500], fontSize: 15),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) =>
                            _LessonPlanCard(plan: filtered[i]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LessonPlanCard extends StatelessWidget {
  final LessonPlan plan;
  const _LessonPlanCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    // Pattern B — left border accent on lesson card
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: const Border(left: BorderSide(color: _kPrimary, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: _kPrimary.withValues(alpha: 0.06),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _kPrimary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    plan.subject,
                    style: const TextStyle(
                        color: _kPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12),
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat('dd MMM yyyy').format(plan.date),
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _planRow('Topics', plan.topicsCovered, Icons.book_rounded),
                if (plan.homework.isNotEmpty)
                  _planRow('Homework', plan.homework, Icons.assignment_rounded),
                if (plan.notes.isNotEmpty)
                  _planRow('Notes', plan.notes, Icons.notes_rounded),
                if (plan.attachmentUrls.isNotEmpty)
                  _attachmentsSection(plan.attachmentUrls, plan.attachmentNames),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _attachmentsSection(List<String> urls, List<String> names) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.attach_file_rounded, size: 16, color: _kPrimary),
              const SizedBox(width: 8),
              Text(
                'Attachments',
                style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 11,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: List.generate(urls.length, (i) {
              final name = i < names.length ? names[i] : 'File ${i + 1}';
              final ext  = name.contains('.') ? name.split('.').last.toLowerCase() : '';
              return GestureDetector(
                onTap: () async {
                  final uri = Uri.tryParse(urls[i]);
                  if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _kPrimary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _kPrimary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_fileIcon(ext), color: _kPrimary, size: 14),
                      const SizedBox(width: 5),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 160),
                        child: Text(
                          name,
                          style: const TextStyle(
                              fontSize: 11,
                              color: _kPrimary,
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
      ),
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

  Widget _planRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: _kPrimary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              SizedBox(
                width: 260,
                child: Text(
                  value,
                  style: const TextStyle(fontSize: 13, height: 1.4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
