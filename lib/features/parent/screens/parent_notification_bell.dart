import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/models/student.dart';
import '../parent_dashboard.dart';
import 'apply_leave_screen.dart';
import 'announcements_screen.dart';

class ParentNotificationBell extends ConsumerWidget {
  final Student student;
  const ParentNotificationBell({super.key, required this.student});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final uid = userAsync.value?.uid ?? '';
    if (uid.isEmpty) {
      return const IconButton(
        icon: Icon(Icons.notifications_outlined, color: Colors.white),
        onPressed: null,
      );
    }
    final fs = ref.watch(firestoreServiceProvider);
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: fs.streamParentNotifications(uid),
      builder: (ctx, snap) {
        final notifs = snap.data ?? [];
        final unread = notifs.where((n) => n['isRead'] != true).length;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Colors.white),
              onPressed: () =>
                  _showNotificationsSheet(context, notifs, uid, ref),
            ),
            if (unread > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: kParentPrimary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      unread > 9 ? '9+' : '$unread',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _showNotificationsSheet(
    BuildContext context,
    List<Map<String, dynamic>> notifs,
    String uid,
    WidgetRef ref,
  ) {
    final fs = ref.read(firestoreServiceProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.92,
        minChildSize: 0.3,
        builder: (_, ctrl) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Notifications',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              const Divider(),
              Expanded(
                child: notifs.isEmpty
                    ? const Center(
                        child: Text('No notifications yet',
                            style: TextStyle(color: Colors.grey)))
                    : ListView.separated(
                        controller: ctrl,
                        itemCount: notifs.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final n = notifs[i];
                          final isRead = n['isRead'] == true;
                          final ts = (n['createdAt'] as Timestamp?)?.toDate();
                          final type = n['type'] as String? ?? '';
                          final isAbsent = type == 'ATTENDANCE_MARKED' &&
                              n['status'] == 'ABSENT';
                          final isAnnouncement = type == 'ANNOUNCEMENT';
                          final isFeePayment = type == 'FEE_PAYMENT';

                          IconData notifIcon;
                          Color notifColor;
                          if (isAbsent) {
                            notifIcon = Icons.cancel_rounded;
                            notifColor = const Color(0xFFEF4444);
                          } else if (isAnnouncement) {
                            notifIcon = Icons.campaign_rounded;
                            notifColor = kParentPrimary;
                          } else if (isFeePayment) {
                            notifIcon = Icons.account_balance_wallet_rounded;
                            notifColor = const Color(0xFF059669);
                          } else {
                            notifIcon = Icons.notifications_rounded;
                            notifColor = isRead ? Colors.grey : kParentPrimary;
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isRead
                                      ? Colors.grey[100]
                                      : notifColor.withValues(alpha: 0.1),
                                  child: Icon(notifIcon,
                                      color: notifColor, size: 20),
                                ),
                                title: Text(
                                  n['title'] as String? ?? '',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isRead
                                        ? FontWeight.w400
                                        : FontWeight.w700,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(n['body'] as String? ?? '',
                                        style: const TextStyle(fontSize: 12)),
                                    if (ts != null)
                                      Text(
                                        DateFormat('MMM d, hh:mm a').format(ts),
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey[400]),
                                      ),
                                  ],
                                ),
                                onTap: () {
                                  if (!isRead) {
                                    fs.markParentNotificationRead(
                                        uid, n['notifId'] as String);
                                  }
                                  if (isAnnouncement) {
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            AnnouncementsScreen(student: student),
                                      ),
                                    );
                                  }
                                  // FEE_PAYMENT: just mark read, no navigation needed
                                },
                              ),
                              if (isAbsent)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                ApplyLeaveScreen(student: student),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.edit_document,
                                          size: 15),
                                      label: const Text('Submit Leave Letter',
                                          style: TextStyle(fontSize: 12)),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: const Color(0xFFEF4444),
                                        side: const BorderSide(
                                            color: Color(0xFFEF4444)),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 6),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                      ),
                                    ),
                                  ),
                                ),
                              if (isAnnouncement &&
                                  n['requiresAck'] == true &&
                                  !isRead)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        fs.markParentNotificationRead(
                                            uid, n['notifId'] as String);
                                        final announcementId =
                                            n['announcementId'] as String?;
                                        if (announcementId != null) {
                                          fs.acknowledgeAnnouncement(
                                              announcementId, uid);
                                        }
                                      },
                                      icon: const Icon(Icons.done_rounded,
                                          size: 15),
                                      label: const Text('Acknowledge',
                                          style: TextStyle(fontSize: 12)),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: kParentPrimary,
                                        side: const BorderSide(
                                            color: kParentPrimary),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 6),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
