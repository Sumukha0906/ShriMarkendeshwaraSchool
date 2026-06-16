import 'package:flutter/material.dart';
import 'marks_entry_screen.dart';
import 'marks_results_screen.dart';

const _kPrimary = Color(0xFF065F46);
const _kDark    = Color(0xFF022C22);
const _kBg      = Color(0xFFF0FDF4);
const _kBlue    = Color(0xFF3B82F6);

class MarksHubScreen extends StatelessWidget {
  final String schoolId;
  final String teacherUid;
  final String? preselectedClassId;

  const MarksHubScreen({
    super.key,
    required this.schoolId,
    required this.teacherUid,
    this.preselectedClassId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      // Pattern A — rounded bottom AppBar
      appBar: AppBar(
        backgroundColor: _kDark,
        foregroundColor: Colors.white,
        title: const Text('Marks',
            style: TextStyle(fontWeight: FontWeight.w700)),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            // Pattern G — accent bar section header
            Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    color: _kPrimary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'What would you like to do?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _HubCard(
              icon: Icons.add_chart_rounded,
              title: 'Record New Test Marks',
              subtitle: 'Enter marks for a new exam or unit test',
              color: _kPrimary,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MarksEntryScreen(
                    schoolId: schoolId,
                    teacherUid: teacherUid,
                    preselectedClassId: preselectedClassId,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _HubCard(
              icon: Icons.assignment_outlined,
              title: 'View Previous Test Results',
              subtitle: 'Browse results from tests already recorded',
              color: _kBlue,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MarksResultsScreen(
                    schoolId: schoolId,
                    teacherUid: teacherUid,
                    preselectedClassId: preselectedClassId,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HubCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _HubCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      // Pattern H — top accent stripe
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border(top: BorderSide(color: color, width: 3)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: color, size: 22),
          ],
        ),
      ),
    );
  }
}
