import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/models/student.dart';
import '../../../core/models/announcement.dart';
import '../parent_dashboard.dart';

class AnnouncementsScreen extends ConsumerWidget {
  final Student student;
  const AnnouncementsScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fs   = ref.watch(firestoreServiceProvider);
    final user = ref.watch(currentUserProvider).value;

    return Scaffold(
      backgroundColor: kParentBg,
      appBar: AppBar(
        backgroundColor: kParentDark,
        foregroundColor: Colors.white,
        title: const Text('Announcements',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: StreamBuilder<List<Announcement>>(
        stream: fs.streamAnnouncementsForParent(
            student.schoolId, student.classId),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting &&
              !snap.hasData) {
            return const Center(
                child: CircularProgressIndicator(color: kParentPrimary));
          }
          if (snap.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 48, color: Colors.red.withValues(alpha: 0.5)),
                  const SizedBox(height: 12),
                  const Text('Could not load announcements',
                      style: TextStyle(color: kParentDark)),
                  const SizedBox(height: 4),
                  Text('${snap.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.grey[500], fontSize: 11)),
                ],
              ),
            );
          }
          final list = snap.data ?? [];
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.campaign_outlined,
                      size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'No announcements yet',
                    style:
                        TextStyle(color: Colors.grey[500], fontSize: 15),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (ctx, i) => _AnnouncementCard(
              announcement: list[i],
              myUid: user?.uid ?? '',
              onAck: () {
                if (user == null) return;
                fs.acknowledgeAnnouncement(list[i].announcementId, user.uid);
              },
            ),
          );
        },
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final Announcement announcement;
  final String myUid;
  final VoidCallback onAck;
  const _AnnouncementCard(
      {required this.announcement,
      required this.myUid,
      required this.onAck});

  @override
  Widget build(BuildContext context) {
    final hasAcked = announcement.hasUserAcked(myUid);
    final audienceColor = _audienceColor(announcement.audience);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: hasAcked
              ? Colors.grey[200]!
              : kParentPrimary.withValues(alpha: 0.3),
          width: hasAcked ? 1 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header strip
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: kParentPrimary.withValues(alpha: 0.06),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: audienceColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    announcement.audience.name,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: audienceColor,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  announcement.publishedAt != null
                      ? DateFormat('MMM d, h:mm a')
                          .format(announcement.publishedAt!)
                      : '',
                  style: TextStyle(
                      color: Colors.grey[500], fontSize: 11),
                ),
                if (hasAcked) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.done_all_rounded,
                      color: Color(0xFF059669), size: 16),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  announcement.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: kParentDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  announcement.body,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                if (!hasAcked) ...[
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onAck,
                      icon: const Icon(Icons.done_rounded, size: 16),
                      label: const Text('Acknowledge'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kParentPrimary,
                        side: const BorderSide(color: kParentPrimary),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _audienceColor(AnnouncementAudience a) {
    switch (a) {
      case AnnouncementAudience.ALL:     return kParentPrimary;
      case AnnouncementAudience.PARENTS: return const Color(0xFFD97706);
      case AnnouncementAudience.CLASS:   return const Color(0xFF059669);
      default:                           return Colors.grey;
    }
  }
}
