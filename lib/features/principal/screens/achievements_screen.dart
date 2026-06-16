import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/constants/firestore_constants.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  static const _amber = Color(0xFFF59E0B);

  static const _categoryColors = {
    'Academic':  Color(0xFF3B82F6),
    'Sports':    Color(0xFF059669),
    'Arts':      Color(0xFFD97706),
    'Science':   Color(0xFF0EA5E9),
    'Leadership':Color(0xFFD97706),
    'Other':     Color(0xFF6B7280),
  };

  static const _categoryIcons = {
    'Academic':   Icons.menu_book_rounded,
    'Sports':     Icons.sports_soccer_rounded,
    'Arts':       Icons.palette_rounded,
    'Science':    Icons.science_rounded,
    'Leadership': Icons.star_rounded,
    'Other':      Icons.emoji_events_rounded,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
        title: const Text('Student Achievements',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(FSC.achievements)
            .where('schoolId', isEqualTo: user.schoolId)
            .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: _amber));
          }
          if (snap.hasError) {
            return Center(
                child: Text('Error loading achievements',
                    style: TextStyle(color: Colors.grey[400])));
          }

          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) return _emptyState();

          // Sort by createdAt desc
          final sorted = List.from(docs)
            ..sort((a, b) {
              final at = ((a.data() as Map)['createdAt'] as Timestamp?)
                      ?.toDate() ??
                  DateTime(0);
              final bt = ((b.data() as Map)['createdAt'] as Timestamp?)
                      ?.toDate() ??
                  DateTime(0);
              return bt.compareTo(at);
            });

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: sorted.length,
            itemBuilder: (_, i) {
              final d = sorted[i].data() as Map<String, dynamic>;
              return _achievementCard(d);
            },
          );
        },
      ),
    );
  }

  Widget _achievementCard(Map<String, dynamic> d) {
    final category   = d['category'] as String? ?? 'Other';
    final color      = _categoryColors[category] ?? const Color(0xFF6B7280);
    final icon       = _categoryIcons[category] ?? Icons.emoji_events_rounded;
    final studentName = d['studentName'] as String? ?? 'Student';
    final teacherName = d['teacherName'] as String? ?? '';
    final title       = d['title'] as String? ?? '';
    final description = d['description'] as String? ?? '';
    final createdAt   = (d['createdAt'] as Timestamp?)?.toDate();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          // Coloured top bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.only(
                topLeft:  Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withValues(alpha: 0.7)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(studentName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize:   15,
                              color:      Color(0xFF0A0F1E))),
                      if (teacherName.isNotEmpty)
                        Text('Shared by $teacherName',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[500])),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color:        color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: color.withValues(alpha: 0.3)),
                  ),
                  child: Text(category,
                      style: TextStyle(
                          fontSize:   10,
                          color:      color,
                          fontWeight: FontWeight.w700)),
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
                Row(
                  children: [
                    Icon(Icons.emoji_events_rounded,
                        color: _amber, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(title,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize:   14,
                              color:      Color(0xFF0A0F1E))),
                    ),
                  ],
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(description,
                      style: TextStyle(
                          fontSize: 13,
                          color:    Colors.grey[600],
                          height:   1.4)),
                ],
                if (createdAt != null) ...[
                  const SizedBox(height: 8),
                  Text(_timeAgo(createdAt),
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey[400])),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color:  _amber.withValues(alpha: 0.1),
              shape:  BoxShape.circle,
            ),
            child: const Icon(Icons.emoji_events_rounded,
                color: _amber, size: 36),
          ),
          const SizedBox(height: 16),
          const Text('No achievements yet',
              style: TextStyle(
                  fontSize:   18,
                  fontWeight: FontWeight.w700,
                  color:      Color(0xFF0A0F1E))),
          const SizedBox(height: 8),
          Text(
            'Teachers can share student achievements\nfrom their dashboard',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[500], height: 1.5),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 6)  return '${dt.day}/${dt.month}/${dt.year}';
    if (diff.inDays > 0)  return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}
