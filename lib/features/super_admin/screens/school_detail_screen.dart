import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firestore_constants.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/models/school.dart';
import '../../../core/models/user_model.dart';
import '../../../core/models/invitation.dart';

class SchoolDetailScreen extends ConsumerStatefulWidget {
  final String schoolId;
  const SchoolDetailScreen({super.key, required this.schoolId});

  @override
  ConsumerState<SchoolDetailScreen> createState() =>
      _SchoolDetailScreenState();
}

class _SchoolDetailScreenState extends ConsumerState<SchoolDetailScreen> {
  final _nameCtrl  = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _inviting   = false;
  String? _currentPlan;
  bool _planSaving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _invitePrincipal() async {
    final name  = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    if (phone.isEmpty || phone.length != 10) return;
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) return;

    setState(() => _inviting = true);
    try {
      await ref.read(firestoreServiceProvider).createStaffInvitation(
            schoolId:    widget.schoolId,
            phone:       '+91$phone',
            role:        InvitationRole.PRINCIPAL,
            createdBy:   currentUser.uid,
            inviteeName: name,
          );
      if (mounted) {
        _phoneCtrl.clear();
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Principal invitation sent!'),
            backgroundColor: Color(0xFF059669),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send invitation.'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _inviting = false);
    }
  }

  void _showInviteSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _InvitePrincipalSheet(
        nameCtrl:  _nameCtrl,
        phoneCtrl: _phoneCtrl,
        inviting:  _inviting,
        onSubmit:  _invitePrincipal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: FutureBuilder<School?>(
        future:
            ref.read(firestoreServiceProvider).getSchool(widget.schoolId),
        builder: (context, schoolSnap) {
          if (schoolSnap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
                    color: Color(0xFFD97706)));
          }
          final school = schoolSnap.data;
          if (school == null) {
            return Scaffold(
              appBar: AppBar(
                  backgroundColor: const Color(0xFF022C22),
                  foregroundColor: Colors.white,
                  title: const Text('School')),
              body: const Center(child: Text('School not found')),
            );
          }
          return _buildContent(context, school);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, School school) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(school),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSchoolInfoCard(school),
                const SizedBox(height: 16),
                _buildPlanCard(school),
                const SizedBox(height: 16),
                _buildStatsRow(school),
                const SizedBox(height: 16),
                _buildPrincipalSection(school),
                const SizedBox(height: 16),
                _buildInvitationsSection(school),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  SliverAppBar _buildAppBar(School school) {
    return SliverAppBar(
      backgroundColor: const Color(0xFF022C22),
      foregroundColor: Colors.white,
      expandedHeight: 140,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.fromLTRB(56, 0, 16, 16),
        title: Text(
          school.name,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF022C22), Color(0xFF4C1D95)],
            ),
          ),
          child: Center(
            child: Container(
              width: 60,
              height: 60,
              margin: const EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  school.name.isNotEmpty
                      ? school.name[0].toUpperCase()
                      : 'S',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 26),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static const _planMeta = [
    (id: 'BASIC',    label: 'Basic',    price: '₹49/mo',  color: Color(0xFF059669), bg: Color(0xFFECFDF5), desc: 'Attendance, Announcements, Students'),
    (id: 'STANDARD', label: 'Standard', price: '₹99/mo',  color: Color(0xFF3B82F6), bg: Color(0xFFEFF6FF), desc: 'Basic + Fees, Leave, Timetable, Achievements'),
    (id: 'PREMIUM',  label: 'Premium',  price: '₹199/mo', color: Color(0xFFD97706), bg: Color(0xFFF3E8FF), desc: 'Everything — Chat, Expenses, Documents, Visitors'),
  ];

  Future<void> _updatePlan(String schoolId, String plan) async {
    setState(() => _planSaving = true);
    try {
      await ref.read(firestoreServiceProvider).updateSchoolPlan(schoolId, plan);
      if (mounted) setState(() { _currentPlan = plan; _planSaving = false; });
    } catch (_) {
      if (mounted) setState(() => _planSaving = false);
    }
  }

  Widget _buildPlanCard(School school) {
    final activePlan = _currentPlan ?? school.plan;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _cardTitle('Subscription Plan'),
              const Spacer(),
              if (_planSaving)
                const SizedBox(
                  width: 14, height: 14,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Color(0xFFD97706)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ..._planMeta.map((p) {
            final selected = activePlan.toUpperCase() == p.id;
            return GestureDetector(
              onTap: _planSaving ? null : () => _updatePlan(school.schoolId, p.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: selected ? p.bg : const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected ? p.color : const Color(0xFFE5E7EB),
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 18, height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected ? p.color : Colors.grey.shade400,
                          width: 2,
                        ),
                        color: selected ? p.color : Colors.transparent,
                      ),
                      child: selected
                          ? const Icon(Icons.check, color: Colors.white, size: 11)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.label,
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: selected ? p.color : const Color(0xFF0A0F1E))),
                          const SizedBox(height: 2),
                          Text(p.desc,
                              style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                        ],
                      ),
                    ),
                    Text(p.price,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: selected ? p.color : Colors.grey.shade400)),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSchoolInfoCard(School school) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle('School Information'),
          const SizedBox(height: 12),
          if (school.address.isNotEmpty)
            _infoRow(Icons.location_on_outlined, school.address),
          if (school.phone.isNotEmpty)
            _infoRow(Icons.phone_outlined, school.phone),
          if (school.email.isNotEmpty)
            _infoRow(Icons.email_outlined, school.email),
          _infoRow(Icons.calendar_today_outlined,
              'Academic Year: ${school.academicYear}'),
        ],
      ),
    );
  }

  Widget _buildStatsRow(School school) {
    return Row(
      children: [
        Expanded(
          child: _miniStat(school.schoolId, Icons.menu_book_rounded,
              const Color(0xFF3B82F6), 'Classes', FSC.classes, 'schoolId'),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _miniStat(school.schoolId, Icons.people_rounded,
              const Color(0xFF059669), 'Students', FSC.students, 'schoolId'),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _miniStat(school.schoolId, Icons.person_outline_rounded,
              const Color(0xFFF59E0B), 'Staff', FSC.users, 'schoolId'),
        ),
      ],
    );
  }

  Widget _miniStat(String schoolId, IconData icon, Color color, String label,
      String collection, String field) {
    return FutureBuilder<AggregateQuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection(collection)
          .where(field, isEqualTo: schoolId)
          .count()
          .get(),
      builder: (context, snap) {
        final count = snap.data?.count ?? 0;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(height: 8),
              Text(snap.hasData ? count.toString() : '—',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: color)),
              Text(label,
                  style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPrincipalSection(School school) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _cardTitle('Principal'),
              const Spacer(),
              GestureDetector(
                onTap: () => _showInviteSheet(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD97706).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded,
                          color: Color(0xFFD97706), size: 14),
                      SizedBox(width: 4),
                      Text('Invite',
                          style: TextStyle(
                              color: Color(0xFFD97706),
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          StreamBuilder<UserModel?>(
            stream: ref
                .read(firestoreServiceProvider)
                .streamSchoolPrincipal(school.schoolId),
            builder: (context, snap) {
              if (!snap.hasData || snap.data == null) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFFF59E0B)
                            .withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: Color(0xFFF59E0B), size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('No Principal Assigned',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: Color(0xFF92400E))),
                            Text(
                              'Tap "Invite" to send an invitation',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
              final principal = snap.data!;
              final initials = principal.name.isNotEmpty
                  ? principal.name
                      .trim()
                      .split(' ')
                      .take(2)
                      .map((w) => w[0].toUpperCase())
                      .join()
                  : 'P';
              return Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [
                        Color(0xFF3B82F6),
                        Color(0xFF1D4ED8)
                      ]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(initials,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(principal.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: Color(0xFF0A0F1E))),
                        Text(principal.phone,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[500])),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF059669).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('Active',
                        style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF059669),
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInvitationsSection(School school) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle('Pending Invitations'),
          const SizedBox(height: 12),
          StreamBuilder<List<Invitation>>(
            stream: ref
                .read(firestoreServiceProvider)
                .streamSchoolInvitations(school.schoolId),
            builder: (context, snap) {
              if (snap.hasError) {
                return Text('Error loading invitations',
                    style: TextStyle(
                        fontSize: 13, color: Colors.grey[400]));
              }
              if (!snap.hasData) {
                return const SizedBox(
                    height: 40,
                    child: Center(
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFFD97706))));
              }
              final pending = snap.data!
                  .where((i) => i.status == InvitationStatus.PENDING)
                  .toList();
              if (pending.isEmpty) {
                return Text('No pending invitations',
                    style: TextStyle(
                        fontSize: 13, color: Colors.grey[400]));
              }
              return Column(
                children: pending
                    .map((inv) => _invitationTile(inv))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _invitationTile(Invitation inv) {
    final roleColors = {
      InvitationRole.PRINCIPAL: const Color(0xFF3B82F6),
      InvitationRole.ADMIN:     const Color(0xFF059669),
      InvitationRole.TEACHER:   const Color(0xFFF59E0B),
      InvitationRole.PARENT:    const Color(0xFFD97706),
    };
    final color = roleColors[inv.role] ?? Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Icon(Icons.phone_outlined, color: Colors.grey[400], size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              inv.phone.isNotEmpty ? inv.phone : inv.email,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0A0F1E)),
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(inv.role.name,
                style: TextStyle(
                    fontSize: 10,
                    color: color,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2)),
        ],
      ),
      child: child,
    );
  }

  Widget _cardTitle(String title) {
    return Text(title,
        style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0A0F1E)));
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: Colors.grey[400]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          ),
        ],
      ),
    );
  }
}

// ─── Invite Principal Bottom Sheet ──────────────────────────────────────────

class _InvitePrincipalSheet extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController phoneCtrl;
  final bool inviting;
  final VoidCallback onSubmit;

  const _InvitePrincipalSheet({
    required this.nameCtrl,
    required this.phoneCtrl,
    required this.inviting,
    required this.onSubmit,
  });

  InputDecoration _deco(String label, String hint, IconData icon) =>
      InputDecoration(
        labelText:  label,
        hintText:   hint,
        prefixIcon: Icon(icon),
        filled:     true,
        fillColor:  const Color(0xFFF9FAFB),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD97706), width: 1.5),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft:  Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(
        left:   24,
        right:  24,
        top:    24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Invite Principal',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0A0F1E))),
          const SizedBox(height: 4),
          Text('Enter the principal\'s name and phone number',
              style: TextStyle(fontSize: 13, color: Colors.grey[500])),
          const SizedBox(height: 20),
          // Name field
          TextField(
            controller: nameCtrl,
            textCapitalization: TextCapitalization.words,
            autofocus: true,
            style: const TextStyle(fontSize: 15, color: Color(0xFF0A0F1E)),
            decoration: _deco('Full Name', 'e.g. Ramesh Kumar',
                Icons.person_outlined),
          ),
          const SizedBox(height: 12),
          // Phone with +91 prefix
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: const Text('+91',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Color(0xFF0A0F1E))),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  style: const TextStyle(
                      fontSize: 15, color: Color(0xFF0A0F1E)),
                  decoration: InputDecoration(
                    labelText:   'Mobile Number',
                    hintText:    '98765 43210',
                    counterText: '',
                    filled:      true,
                    fillColor:   const Color(0xFFF9FAFB),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[200]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: Color(0xFFD97706), width: 1.5),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: inviting ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD97706),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: inviting
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5))
                  : const Text('Send Invitation',
                      style: TextStyle(
                          color:      Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize:   15)),
            ),
          ),
        ],
      ),
    );
  }
}
