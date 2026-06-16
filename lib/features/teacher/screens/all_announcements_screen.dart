import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/models/announcement.dart';

const _kPrimary = Color(0xFF065F46);
const _kOrange  = Color(0xFFD97706);
const _kBg      = Color(0xFFF0FDF4);
const _kDark    = Color(0xFF022C22);

class AllAnnouncementsScreen extends ConsumerWidget {
  final String schoolId;
  final String teacherUid;

  const AllAnnouncementsScreen({
    super.key,
    required this.schoolId,
    required this.teacherUid,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fs = ref.watch(firestoreServiceProvider);

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kDark,
        foregroundColor: Colors.white,
        title: const Text('Announcements',
            style: TextStyle(fontWeight: FontWeight.w700)),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: StreamBuilder<List<Announcement>>(
        stream: fs.streamAnnouncementsForTeacher(schoolId),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: _kPrimary));
          }
          final items = snap.data ?? [];
          // Pattern I — improved empty state
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: _kOrange.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.campaign_outlined,
                        size: 40, color: _kOrange),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No announcements',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Nothing to show yet',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (_, i) {
              final a     = items[i];
              final isNew = !a.hasUserAcked(teacherUid);
              return _AnnouncementCard(
                announcement: a,
                teacherUid:   teacherUid,
                isNew:        isNew,
                onTap: () {
                  if (isNew) {
                    fs.acknowledgeAnnouncement(a.announcementId, teacherUid);
                  }
                  _showDetail(context, a);
                },
              );
            },
          );
        },
      ),
    );
  }

  void _showDetail(BuildContext context, Announcement a) {
    final fmt = DateFormat('d MMM yyyy, h:mm a');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize:     0.9,
        minChildSize:     0.4,
        builder: (_, ctrl) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            controller: ctrl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _kOrange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    a.audience.name,
                    style: const TextStyle(
                        fontSize: 11,
                        color: _kOrange,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  a.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0A0F1E),
                  ),
                ),
                const SizedBox(height: 8),
                if (a.publishedAt != null)
                  Text(
                    fmt.format(a.publishedAt!),
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey[500]),
                  ),
                const Divider(height: 24),
                Text(
                  a.body,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF374151),
                    height: 1.6,
                  ),
                ),
                if (a.createdByName.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Posted by: ${a.createdByName}',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final Announcement announcement;
  final String teacherUid;
  final bool isNew;
  final VoidCallback onTap;

  const _AnnouncementCard({
    required this.announcement,
    required this.teacherUid,
    required this.isNew,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final a   = announcement;
    final fmt = DateFormat('d MMM yyyy');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isNew
              ? _kOrange.withValues(alpha: 0.06)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: BorderSide(color: _kOrange, width: 4),
            top: BorderSide(
              color: isNew
                  ? _kOrange.withValues(alpha: 0.3)
                  : Colors.grey.withValues(alpha: 0.12),
              width: 1,
            ),
            right: BorderSide(
              color: isNew
                  ? _kOrange.withValues(alpha: 0.3)
                  : Colors.grey.withValues(alpha: 0.12),
              width: 1,
            ),
            bottom: BorderSide(
              color: isNew
                  ? _kOrange.withValues(alpha: 0.3)
                  : Colors.grey.withValues(alpha: 0.12),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _kOrange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.campaign_rounded,
                  color: _kOrange, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          a.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: isNew
                                ? const Color(0xFF0A0F1E)
                                : const Color(0xFF374151),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isNew)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 6),
                          decoration: const BoxDecoration(
                            color: _kOrange,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    a.body,
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _kPrimary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          a.audience.name,
                          style: const TextStyle(
                              fontSize: 9,
                              color: _kPrimary,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                      const Spacer(),
                      if (a.publishedAt != null)
                        Text(
                          fmt.format(a.publishedAt!),
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey[400]),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
