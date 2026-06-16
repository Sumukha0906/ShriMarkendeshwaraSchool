import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/firestore_constants.dart';

const _kPrimary = Color(0xFFDC2626);
const _kGreen   = Color(0xFF059669);
const _kAmber   = Color(0xFFF59E0B);
const _kNavy    = Color(0xFF0A0F1E);

class ManageStudentsScreen extends StatefulWidget {
  final String schoolId;
  final String academicYear;
  const ManageStudentsScreen({
    super.key,
    required this.schoolId,
    required this.academicYear,
  });

  @override
  State<ManageStudentsScreen> createState() => _ManageStudentsScreenState();
}

class _ManageStudentsScreenState extends State<ManageStudentsScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF1F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7F1D1D),
        foregroundColor: Colors.white,
        title: const Text('Manage Students',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search by name or admission no…',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                prefixIcon: Icon(Icons.search_rounded,
                    color: Colors.grey[400], size: 20),
                suffixIcon: _query.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                        child: Icon(Icons.clear_rounded,
                            color: Colors.grey[400], size: 18),
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
          // Student list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(FSC.students)
                  .where('schoolId', isEqualTo: widget.schoolId)
                  .where('isActive', isEqualTo: true)
                  .snapshots(),
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: _kPrimary));
                }
                var docs = snap.data?.docs ?? [];
                if (_query.isNotEmpty) {
                  docs = docs.where((d) {
                    final data = d.data() as Map<String, dynamic>;
                    final name = (data['name'] as String? ?? '').toLowerCase();
                    final admNo =
                        (data['admissionNo'] as String? ?? '').toLowerCase();
                    return name.contains(_query) || admNo.contains(_query);
                  }).toList();
                }
                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.school_outlined,
                            size: 48, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        Text(
                          _query.isEmpty
                              ? 'No students found'
                              : 'No students match "$_query"',
                          style: TextStyle(
                              color: Colors.grey[400], fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (_, i) {
                    final data = docs[i].data() as Map<String, dynamic>;
                    final studentId = docs[i].id;
                    return _StudentTile(
                      studentId:    studentId,
                      data:         data,
                      schoolId:     widget.schoolId,
                      academicYear: widget.academicYear,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Student Tile ─────────────────────────────────────────────────────────────
class _StudentTile extends StatelessWidget {
  final String studentId;
  final Map<String, dynamic> data;
  final String schoolId;
  final String academicYear;
  const _StudentTile({
    required this.studentId,
    required this.data,
    required this.schoolId,
    required this.academicYear,
  });

  @override
  Widget build(BuildContext context) {
    final name    = (data['name']    as String?) ?? 'Student';
    final admNo   = (data['admissionNo'] as String?) ?? '';

    final initials = name.trim().split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();

    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: _kPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(initials,
                    style: const TextStyle(
                        color: _kPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 15)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: _kNavy)),
                  const SizedBox(height: 2),
                  if (admNo.isNotEmpty)
                    Text('Adm: $admNo',
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey[500])),
                ],
              ),
            ),
            // Fee badge (async)
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(FSC.fees)
                  .where('studentId', isEqualTo: studentId)
                  .where('academicYear', isEqualTo: academicYear)
                  .limit(1)
                  .snapshots(),
              builder: (ctx, fSnap) {
                final docs = fSnap.data?.docs ?? [];
                if (docs.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('No fee set',
                        style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[400],
                            fontWeight: FontWeight.w600)),
                  );
                }
                final fData = docs.first.data() as Map<String, dynamic>;
                final paid    = ((fData['totalPaid']    as num?) ?? 0).toDouble();
                final pending = ((fData['totalPending'] as num?) ?? 0).toDouble();
                final isPaid  = pending <= 0;
                final color   = isPaid ? _kGreen : _kAmber;
                final fmt     = NumberFormat('##,##,##0', 'en_IN');
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('₹${fmt.format(paid + pending)}',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: _kNavy)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isPaid ? 'PAID' : '₹${fmt.format(pending)} due',
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: color),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right_rounded,
                color: Colors.grey[300], size: 18),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _StudentDetailSheet(
        studentId:    studentId,
        data:         data,
        academicYear: academicYear,
      ),
    );
  }
}

// ── Student Detail Sheet ──────────────────────────────────────────────────────
class _StudentDetailSheet extends StatelessWidget {
  final String studentId;
  final Map<String, dynamic> data;
  final String academicYear;
  const _StudentDetailSheet({
    required this.studentId,
    required this.data,
    required this.academicYear,
  });

  @override
  Widget build(BuildContext context) {
    final name     = (data['name']        as String?) ?? 'Student';
    final admNo    = (data['admissionNo'] as String?) ?? '';
    final gender   = (data['gender']      as String?) ?? '';
    final dob      = (data['dob']         as String?) ?? '';
    final address  = (data['address']     as String?) ?? '';
    final fmt      = NumberFormat('##,##,##0', 'en_IN');

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (_, ctrl) => Container(
        padding: const EdgeInsets.all(24),
        child: ListView(
          controller: ctrl,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(name,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _kNavy)),
            if (admNo.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('Admission No: $admNo',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            ],
            const SizedBox(height: 20),
            // Personal info
            _infoRow('Gender',  gender.isEmpty  ? '—' : gender,  Icons.person_outlined),
            _infoRow('DOB',     dob.isEmpty     ? '—' : dob,     Icons.cake_outlined),
            _infoRow('Address', address.isEmpty ? '—' : address, Icons.location_on_outlined),
            const SizedBox(height: 20),
            const Text('Fee Summary',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _kNavy)),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(FSC.fees)
                  .where('studentId', isEqualTo: studentId)
                  .where('academicYear', isEqualTo: academicYear)
                  .limit(1)
                  .snapshots(),
              builder: (ctx, fSnap) {
                if (fSnap.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: _kPrimary, strokeWidth: 2));
                }
                final docs = fSnap.data?.docs ?? [];
                if (docs.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Text('No fee record for $academicYear',
                        style:
                            TextStyle(color: Colors.grey[400], fontSize: 13)),
                  );
                }
                final fd      = docs.first.data() as Map<String, dynamic>;
                final total   = ((fd['totalAmount']   as num?) ?? 0).toDouble();
                final paid    = ((fd['totalPaid']     as num?) ?? 0).toDouble();
                final pending = ((fd['totalPending']  as num?) ?? 0).toDouble();
                return Column(
                  children: [
                    _feeRow('Total Fee',  '₹${fmt.format(total)}',   Colors.grey[700]!),
                    _feeRow('Paid',       '₹${fmt.format(paid)}',    _kGreen),
                    _feeRow('Pending',    '₹${fmt.format(pending)}', _kAmber),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[400]),
          const SizedBox(width: 8),
          Text('$label: ',
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w600)),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 12,
                    color: _kNavy,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _feeRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500)),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: color)),
        ],
      ),
    );
  }
}
