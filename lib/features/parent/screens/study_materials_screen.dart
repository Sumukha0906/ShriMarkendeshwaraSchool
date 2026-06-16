import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/models/student.dart';
import '../parent_dashboard.dart';

class StudyMaterialsScreen extends ConsumerWidget {
  final Student student;
  const StudyMaterialsScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fs = ref.watch(firestoreServiceProvider);

    return Scaffold(
      backgroundColor: kParentBg,
      appBar: AppBar(
        backgroundColor: kParentDark,
        foregroundColor: Colors.white,
        title: const Text('Notes & Materials',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: fs.streamClassStudyMaterials(student.classId),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: kParentPrimary));
          }
          final materials = snap.data ?? [];
          if (materials.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_outlined,
                      size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'No materials uploaded yet',
                    style:
                        TextStyle(color: Colors.grey[500], fontSize: 15),
                  ),
                ],
              ),
            );
          }

          // Group by subject
          final grouped = <String, List<Map<String, dynamic>>>{};
          for (final m in materials) {
            final subject = (m['subject'] as String?) ?? 'General';
            grouped.putIfAbsent(subject, () => []).add(m);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: grouped.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subject header
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [kParentPrimary, kParentAmber],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.bookmark_rounded,
                            color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          entry.key,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${entry.value.length} file${entry.value.length > 1 ? 's' : ''}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...entry.value.map((m) => _MaterialCard(material: m)),
                  const SizedBox(height: 16),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class _MaterialCard extends StatelessWidget {
  final Map<String, dynamic> material;
  const _MaterialCard({required this.material});

  @override
  Widget build(BuildContext context) {
    final title     = (material['title'] as String?) ?? 'Untitled';
    final desc      = (material['description'] as String?) ?? '';
    final fileUrls  = (material['fileUrls'] as List?)?.cast<Map>() ?? [];
    final createdAt =
        (material['createdAt'] as dynamic)?.toDate() as DateTime?;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: kParentDark,
                      ),
                    ),
                    if (desc.isNotEmpty)
                      Text(
                        desc,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey[500]),
                      ),
                    if (createdAt != null)
                      Text(
                        DateFormat('MMM d, yyyy').format(createdAt),
                        style: TextStyle(
                            fontSize: 10, color: Colors.grey[400]),
                      ),
                  ],
                ),
              ),
              Text(
                '${fileUrls.length} file${fileUrls.length != 1 ? 's' : ''}',
                style: TextStyle(fontSize: 11, color: Colors.grey[400]),
              ),
            ],
          ),
          if (fileUrls.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...fileUrls.map((f) {
              final name = (f['name'] as String?) ?? 'File';
              final url  = (f['url']  as String?) ?? '';
              final ext  = (f['ext']  as String?) ?? '';
              final (icon, color) = _fileTheme(ext);
              return InkWell(
                onTap: () async {
                  if (url.isNotEmpty) {
                    final uri = Uri.parse(url);
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(icon, color: color, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey[700]),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.open_in_new_rounded,
                          color: kParentPrimary, size: 14),
                    ],
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  (IconData, Color) _fileTheme(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return (Icons.picture_as_pdf_rounded, const Color(0xFFEF4444));
      case 'image':
        return (Icons.image_rounded, const Color(0xFF3B82F6));
      case 'ppt':
      case 'powerpoint':
        return (Icons.slideshow_rounded, const Color(0xFFD97706));
      default:
        return (Icons.insert_drive_file_rounded, const Color(0xFF6B7280));
    }
  }
}
