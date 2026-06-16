import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/models/invitation.dart';

class InviteStaffScreen extends ConsumerStatefulWidget {
  const InviteStaffScreen({super.key});

  @override
  ConsumerState<InviteStaffScreen> createState() => _InviteStaffScreenState();
}

class _InviteStaffScreenState extends ConsumerState<InviteStaffScreen>
    with SingleTickerProviderStateMixin {
  final _nameCtrl  = TextEditingController();
  final _phoneCtrl = TextEditingController();
  InvitationRole _role = InvitationRole.TEACHER;
  bool _isLoading      = false;
  String? _error;
  bool _success        = false;
  late TabController _tabController;

  static const _blue   = Color(0xFF3B82F6);
  static const _amber  = Color(0xFFF59E0B);
  static const _green  = Color(0xFF059669);
  static const _rose   = Color(0xFFDC2626);
  static const _indigo = Color(0xFF065F46);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _tabController.dispose();
    super.dispose();
  }

  String get _fullPhone => '+91${_phoneCtrl.text.trim()}';

  Future<void> _submit() async {
    final name  = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();

    if (name.isEmpty) {
      setState(() => _error = 'Please enter the staff member\'s name');
      return;
    }
    if (phone.isEmpty || phone.length != 10) {
      setState(() => _error = 'Enter a valid 10-digit mobile number');
      return;
    }

    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) return;

    setState(() { _isLoading = true; _error = null; });
    try {
      await ref.read(firestoreServiceProvider).createStaffInvitation(
            schoolId:    currentUser.schoolId,
            phone:       _fullPhone,
            role:        _role,
            createdBy:   currentUser.uid,
            inviteeName: name,
          );
      if (mounted) {
        setState(() { _isLoading = false; _success = true; });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to send invitation. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
        title: const Text('Invite Staff',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        elevation: 0,
        bottom: _success
            ? null
            : TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                labelStyle: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13),
                tabs: const [
                  Tab(text: 'Send Invite'),
                  Tab(text: 'All Invitations'),
                ],
              ),
      ),
      body: _success
          ? _buildSuccess()
          : TabBarView(
              controller: _tabController,
              children: [
                _buildForm(),
                _buildInvitationsList(),
              ],
            ),
    );
  }

  // ─── FORM ────────────────────────────────────────────────────────────────

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _buildRoleCard(),
          const SizedBox(height: 16),
          _buildNameCard(),
          const SizedBox(height: 16),
          _buildPhoneCard(),
          if (_error != null) ...[
            const SizedBox(height: 12),
            _buildError(),
          ],
          const SizedBox(height: 24),
          _buildInfoBanner(),
          const SizedBox(height: 32),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildRoleCard() {
    return _card(
      label: 'ROLE',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _roleOption(InvitationRole.TEACHER, 'Teacher',
                  Icons.person_outline_rounded, _amber)),
              const SizedBox(width: 10),
              Expanded(child: _roleOption(InvitationRole.ADMIN, 'Admin',
                  Icons.admin_panel_settings_outlined, _green)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _roleOption(InvitationRole.ADMINISTRATOR, 'Administrator',
                  Icons.shield_outlined, _indigo)),
              const SizedBox(width: 10),
              Expanded(child: _roleOption(InvitationRole.MANAGEMENT, 'Management',
                  Icons.business_center_outlined, _rose)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNameCard() {
    return _card(
      label: 'FULL NAME',
      child: TextField(
        controller: _nameCtrl,
        textCapitalization: TextCapitalization.words,
        style: const TextStyle(fontSize: 15, color: Color(0xFF0A0F1E)),
        decoration: _inputDeco('e.g. Priya Sharma', Icons.person_outlined),
        onChanged: (_) => setState(() => _error = null),
      ),
    );
  }

  Widget _buildPhoneCard() {
    return _card(
      label: 'MOBILE NUMBER',
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
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
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              maxLength:   10,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(fontSize: 15, color: Color(0xFF0A0F1E)),
              decoration: InputDecoration(
                hintText:    '98765 43210',
                hintStyle:   TextStyle(color: Colors.grey[400]),
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
                  borderSide: const BorderSide(color: _blue, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 16),
              ),
              onChanged: (_) => setState(() => _error = null),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 16),
          const SizedBox(width: 8),
          Text(_error!,
              style: const TextStyle(color: Color(0xFFEF4444), fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _blue.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: _blue, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'The staff member will receive this invitation when they log in with +91 ${_phoneCtrl.text.isEmpty ? "their number" : _phoneCtrl.text}.',
              style: TextStyle(
                  fontSize: 12, color: Colors.blueGrey[600], height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
              colors: [Color(0xFF1D4ED8), Color(0xFF3B82F6)]),
          boxShadow: [
            BoxShadow(
              color:      _blue.withValues(alpha: 0.35),
              blurRadius: 16,
              offset:     const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor:     Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.send_rounded,
                        color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Send Invitation to ${_role == InvitationRole.TEACHER ? 'Teacher' : _role == InvitationRole.ADMIN ? 'Admin' : _role == InvitationRole.ADMINISTRATOR ? 'Administrator' : 'Management'}',
                      style: const TextStyle(
                          color:      Colors.white,
                          fontSize:   15,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // ─── INVITATIONS LIST ────────────────────────────────────────────────────

  Widget _buildInvitationsList() {
    final user = ref.watch(currentUserProvider).value;
    if (user == null) return const SizedBox.shrink();

    return StreamBuilder<List<Invitation>>(
      stream: ref.watch(firestoreServiceProvider)
          .streamSchoolInvitations(user.schoolId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: _blue));
        }
        if (snap.hasError) {
          return Center(
              child: Text('Error loading invitations',
                  style: TextStyle(color: Colors.grey[400])));
        }

        final all = (snap.data ?? [])
            .where((i) =>
                i.role == InvitationRole.TEACHER ||
                i.role == InvitationRole.ADMIN ||
                i.role == InvitationRole.ADMINISTRATOR ||
                i.role == InvitationRole.MANAGEMENT)
            .toList();

        if (all.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mail_outline_rounded,
                    size: 48, color: Colors.grey[300]),
                const SizedBox(height: 12),
                Text('No invitations sent yet',
                    style: TextStyle(
                        color:      Colors.grey[400],
                        fontSize:   15,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('Invite teachers and admins from the Send Invite tab',
                    style: TextStyle(color: Colors.grey[300], fontSize: 12),
                    textAlign: TextAlign.center),
              ],
            ),
          );
        }

        final pending  = all.where((i) => i.status == InvitationStatus.PENDING).toList();
        final accepted = all.where((i) => i.status == InvitationStatus.ACCEPTED).toList();

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          children: [
            if (pending.isNotEmpty) ...[
              _listSection('Pending (${pending.length})',
                  const Color(0xFFF59E0B)),
              const SizedBox(height: 8),
              ...pending.map(_invitationTile),
              const SizedBox(height: 20),
            ],
            if (accepted.isNotEmpty) ...[
              _listSection('Accepted (${accepted.length})',
                  const Color(0xFF059669)),
              const SizedBox(height: 8),
              ...accepted.map(_invitationTile),
            ],
          ],
        );
      },
    );
  }

  Widget _listSection(String label, Color color) {
    return Text(label,
        style: TextStyle(
            fontSize:   12,
            fontWeight: FontWeight.w700,
            color:      color,
            letterSpacing: 0.5));
  }

  Widget _invitationTile(Invitation inv) {
    final isTeacher = inv.role == InvitationRole.TEACHER;
    final isAdministrator = inv.role == InvitationRole.ADMINISTRATOR;
    final roleColor = inv.role == InvitationRole.MANAGEMENT
        ? _rose
        : isTeacher
            ? _amber
            : isAdministrator
                ? _indigo
                : _green;
    final isPending = inv.status == InvitationStatus.PENDING;
    final statusColor = isPending ? _amber : _green;
    final displayName = inv.inviteeName.isNotEmpty
        ? inv.inviteeName
        : inv.phone;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color:      Colors.black.withValues(alpha: 0.04),
              blurRadius: 8)
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color:        roleColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                inv.inviteeName.isNotEmpty
                    ? inv.inviteeName[0].toUpperCase()
                    : '?',
                style: TextStyle(
                    color:      roleColor,
                    fontWeight: FontWeight.w800,
                    fontSize:   18),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(displayName,
                    style: const TextStyle(
                        fontSize:   14,
                        fontWeight: FontWeight.w700,
                        color:      Color(0xFF0A0F1E))),
                if (inv.inviteeName.isNotEmpty)
                  Text(inv.phone,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color:        roleColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                    inv.role == InvitationRole.MANAGEMENT
                        ? 'Management'
                        : isTeacher
                            ? 'Teacher'
                            : isAdministrator
                                ? 'Administrator'
                                : 'Admin',
                    style: TextStyle(
                        fontSize:   10,
                        color:      roleColor,
                        fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color:        statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(isPending ? 'Pending' : 'Accepted',
                    style: TextStyle(
                        fontSize:   10,
                        color:      statusColor,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── SUCCESS ─────────────────────────────────────────────────────────────

  Widget _buildSuccess() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color:  _green.withValues(alpha: 0.1),
                shape:  BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_outline_rounded,
                  color: _green, size: 40),
            ),
            const SizedBox(height: 20),
            const Text('Invitation Sent!',
                style: TextStyle(
                    fontSize:   22,
                    fontWeight: FontWeight.w800,
                    color:      Color(0xFF0A0F1E))),
            const SizedBox(height: 8),
            Text(
              '${_nameCtrl.text.trim()} will be able to join when they log in with +91 ${_phoneCtrl.text.trim()}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[500], height: 1.5),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _success = false;
                        _nameCtrl.clear();
                        _phoneCtrl.clear();
                        _role    = InvitationRole.TEACHER;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Invite Another'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => context.pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _blue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Done',
                        style: TextStyle(
                            color:      Colors.white,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── HELPERS ─────────────────────────────────────────────────────────────

  Widget _roleOption(InvitationRole role, String label, IconData icon,
      Color color) {
    final selected = _role == role;
    return GestureDetector(
      onTap: () => setState(() => _role = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.1) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : Colors.grey[200]!,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? color : Colors.grey[400], size: 26),
            const SizedBox(height: 6),
            Text(label,
                style: TextStyle(
                    fontSize:   13,
                    fontWeight: FontWeight.w700,
                    color: selected ? color : Colors.grey[500])),
          ],
        ),
      ),
    );
  }

  Widget _card({required String label, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color:      Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset:     const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize:      10,
                  fontWeight:    FontWeight.w700,
                  color:         _blue,
                  letterSpacing: 0.8)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  InputDecoration _inputDeco(String hint, IconData icon) => InputDecoration(
        hintText:   hint,
        hintStyle:  TextStyle(color: Colors.grey[400], fontSize: 14),
        prefixIcon: Icon(icon, size: 18, color: Colors.grey[400]),
        filled:     true,
        fillColor:  const Color(0xFFF9FAFB),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _blue, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 16),
      );
}
