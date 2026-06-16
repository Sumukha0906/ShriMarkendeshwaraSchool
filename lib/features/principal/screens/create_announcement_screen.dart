import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/models/announcement.dart';
import '../../../core/models/class_model.dart';

class CreateAnnouncementScreen extends ConsumerStatefulWidget {
  const CreateAnnouncementScreen({super.key});

  @override
  ConsumerState<CreateAnnouncementScreen> createState() =>
      _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState
    extends ConsumerState<CreateAnnouncementScreen> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl  = TextEditingController();
  final _formKey   = GlobalKey<FormState>();

  AnnouncementAudience _audience   = AnnouncementAudience.ALL;
  ClassModel?          _selectedClass;
  bool                 _requiresAck = false;
  bool                 _isLoading   = false;
  String?              _error;

  static const _blue = Color(0xFF3B82F6);

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_audience == AnnouncementAudience.CLASS && _selectedClass == null) {
      setState(() => _error = 'Please select a class');
      return;
    }

    final user = ref.read(currentUserProvider).value;
    if (user == null) return;

    setState(() {
      _isLoading = true;
      _error     = null;
    });

    try {
      await ref.read(firestoreServiceProvider).createAnnouncement(
            Announcement(
              announcementId: '',
              schoolId:       user.schoolId,
              title:          _titleCtrl.text.trim(),
              body:           _bodyCtrl.text.trim(),
              createdBy:      user.uid,
              createdByName:  user.name,
              audience:       _audience,
              targetClassId:  _audience == AnnouncementAudience.CLASS
                  ? (_selectedClass?.classId ?? '')
                  : '',
              targetClassName: _audience == AnnouncementAudience.CLASS
                  ? (_selectedClass?.section.isNotEmpty == true
                      ? '${_selectedClass!.name} – ${_selectedClass!.section}'
                      : _selectedClass?.name ?? '')
                  : '',
              requiresAck:    _requiresAck,
            ),
          );
      if (mounted) context.pop();
    } catch (_) {
      setState(() {
        _isLoading = false;
        _error     = 'Failed to post announcement. Please try again.';
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
        title: const Text('New Announcement',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAudienceSelector(),
              const SizedBox(height: 16),
              _buildTitleField(),
              const SizedBox(height: 16),
              _buildBodyField(),
              if (_audience == AnnouncementAudience.CLASS) ...[
                const SizedBox(height: 16),
                _buildClassSelector(),
              ],
              const SizedBox(height: 16),
              _buildAckToggle(),
              if (_error != null) ...[
                const SizedBox(height: 12),
                _buildErrorBanner(),
              ],
              const SizedBox(height: 32),
              _buildSubmitButton(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAudienceSelector() {
    final options = [
      (AnnouncementAudience.ALL,      'All',      Icons.people_rounded,            const Color(0xFF3B82F6)),
      (AnnouncementAudience.STAFF,    'Staff',    Icons.badge_rounded,             const Color(0xFF059669)),
      (AnnouncementAudience.TEACHERS, 'Teachers', Icons.school_rounded,            const Color(0xFF065F46)),
      (AnnouncementAudience.PARENTS,  'Parents',  Icons.family_restroom_rounded,   const Color(0xFFD97706)),
      (AnnouncementAudience.CLASS,    'A Class',  Icons.class_rounded,             const Color(0xFFF59E0B)),
    ];
    return _card(
      label: 'SEND TO',
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: options.map((o) {
          final selected = _audience == o.$1;
          return GestureDetector(
            onTap: () => setState(() {
              _audience      = o.$1;
              _selectedClass = null;
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 72,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              decoration: BoxDecoration(
                color:  selected
                    ? o.$4.withValues(alpha: 0.12)
                    : const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? o.$4 : const Color(0xFFE5E7EB),
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(o.$3,
                      color: selected ? o.$4 : Colors.grey[400], size: 22),
                  const SizedBox(height: 5),
                  Text(o.$2,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize:   11,
                          fontWeight: FontWeight.w600,
                          color: selected ? o.$4 : Colors.grey[500])),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTitleField() {
    return _card(
      label: 'TITLE',
      child: TextFormField(
        controller: _titleCtrl,
        style: const TextStyle(fontSize: 15, color: Color(0xFF0A0F1E)),
        decoration: _inputDeco('e.g. School closed tomorrow'),
        validator: (v) =>
            (v?.trim().isEmpty ?? true) ? 'Title is required' : null,
      ),
    );
  }

  Widget _buildBodyField() {
    return _card(
      label: 'MESSAGE',
      child: TextFormField(
        controller: _bodyCtrl,
        maxLines: 5,
        style: const TextStyle(fontSize: 14, color: Color(0xFF0A0F1E)),
        decoration: _inputDeco('Write your announcement here...'),
        validator: (v) =>
            (v?.trim().isEmpty ?? true) ? 'Message is required' : null,
      ),
    );
  }

  Widget _buildClassSelector() {
    final user = ref.read(currentUserProvider).value;
    if (user == null) return const SizedBox.shrink();
    return _card(
      label: 'SELECT CLASS',
      child: StreamBuilder<List<ClassModel>>(
        stream: ref
            .read(firestoreServiceProvider)
            .streamSchoolClasses(user.schoolId),
        builder: (context, snap) {
          final classes = snap.data ?? [];
          if (classes.isEmpty) {
            return Text('No classes found',
                style: TextStyle(color: Colors.grey[400], fontSize: 13));
          }
          return DropdownButtonFormField<ClassModel>(
            initialValue: _selectedClass,
            decoration: _inputDeco('Choose a class'),
            items: classes
                .map((c) => DropdownMenuItem(
                      value: c,
                      child: Text(
                          c.section.isNotEmpty
                              ? '${c.name} – ${c.section}'
                              : c.name,
                          style: const TextStyle(fontSize: 14)),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _selectedClass = v),
          );
        },
      ),
    );
  }

  Widget _buildAckToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color:         const Color(0xFF059669).withValues(alpha: 0.1),
              borderRadius:  BorderRadius.circular(10),
            ),
            child: const Icon(Icons.check_circle_outline,
                color: Color(0xFF059669), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Require Acknowledgement',
                    style: TextStyle(
                        fontSize:   14,
                        fontWeight: FontWeight.w600,
                        color:      Color(0xFF0A0F1E))),
                Text("Recipients must confirm they've read this",
                    style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              ],
            ),
          ),
          Switch(
            value:       _requiresAck,
            onChanged:   (v) => setState(() => _requiresAck = v),
            activeThumbColor: const Color(0xFF059669),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:  const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline,
              color: Color(0xFFEF4444), size: 16),
          const SizedBox(width: 8),
          Text(_error!,
              style: const TextStyle(
                  color: Color(0xFFEF4444), fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    final audienceLabel = {
      AnnouncementAudience.ALL:      'Everyone',
      AnnouncementAudience.PARENTS:  'All Parents',
      AnnouncementAudience.TEACHERS: 'All Teachers',
      AnnouncementAudience.CLASS:    'Selected Class',
    }[_audience] ?? 'Everyone';

    return SizedBox(
      width:  double.infinity,
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
                offset:     const Offset(0, 6)),
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
                    Text('Post to $audienceLabel',
                        style: const TextStyle(
                            color:      Colors.white,
                            fontSize:   15,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
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
              offset:     const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize:    10,
                  fontWeight:  FontWeight.w700,
                  color:       Color(0xFF3B82F6),
                  letterSpacing: 0.8)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  InputDecoration _inputDeco(String hint) => InputDecoration(
        hintText:  hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        filled:    true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[200]!)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: _blue, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: Color(0xFFEF4444))),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
                color: Color(0xFFEF4444), width: 1.5)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      );
}
