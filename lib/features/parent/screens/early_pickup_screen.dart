import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/models/student.dart';
import '../../../core/models/early_pickup.dart';
import '../parent_dashboard.dart';

class EarlyPickupRequestScreen extends ConsumerStatefulWidget {
  final Student student;
  const EarlyPickupRequestScreen({super.key, required this.student});

  @override
  ConsumerState<EarlyPickupRequestScreen> createState() =>
      _EarlyPickupRequestScreenState();
}

class _EarlyPickupRequestScreenState
    extends ConsumerState<EarlyPickupRequestScreen> {
  final _collectorNameCtrl  = TextEditingController();
  final _collectorPhoneCtrl = TextEditingController();
  final _reasonCtrl         = TextEditingController();
  String _relation          = 'Mother';
  TimeOfDay _pickupTime     = TimeOfDay.now();
  bool _loading             = false;

  static const _relations = [
    'Mother', 'Father', 'Grandparent', 'Uncle/Aunt', 'Guardian', 'Other'
  ];

  @override
  void dispose() {
    _collectorNameCtrl.dispose();
    _collectorPhoneCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _pickupTime,
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: kParentPrimary),
        ),
        child: child!,
      ),
    );
    if (t != null) setState(() => _pickupTime = t);
  }

  Future<void> _submit() async {
    if (_collectorNameCtrl.text.trim().isEmpty ||
        _collectorPhoneCtrl.text.trim().isEmpty ||
        _reasonCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final user = await ref.read(currentUserProvider.future);
      final fs   = ref.read(firestoreServiceProvider);
      final now  = DateTime.now();
      final pickupDateTime = DateTime(
        now.year, now.month, now.day,
        _pickupTime.hour, _pickupTime.minute,
      );

      final pickup = EarlyPickup(
        requestId:   '',
        schoolId:    widget.student.schoolId,
        classId:     widget.student.classId,
        studentId:   widget.student.studentId,
        studentName: widget.student.name,
        parentUid:   user!.uid,
        pickupTime:  pickupDateTime,
        reason:      _reasonCtrl.text.trim(),
        collectorDetails: CollectorDetails(
          name:     _collectorNameCtrl.text.trim(),
          relation: _relation,
          phone:    _collectorPhoneCtrl.text.trim(),
        ),
      );

      await fs.createPickupRequest(pickup);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Early pickup request submitted!'),
            backgroundColor: kParentPrimary,
          ),
        );
      }
    } catch (e) {
      setState(() => _loading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kParentBg,
      appBar: AppBar(
        backgroundColor: kParentDark,
        foregroundColor: Colors.white,
        title: const Text('Early Pickup Request',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFD1FAE5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: kParentAmber.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: kParentAmber, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'The class teacher and all associated teachers will be notified of this early pickup request.',
                      style: TextStyle(
                          color: const Color(0xFF92400E),
                          fontSize: 12,
                          height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _sectionTitle('Pickup Time'),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickTime,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time_rounded,
                        color: kParentPrimary),
                    const SizedBox(width: 10),
                    Text(
                      _pickupTime.format(context),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: kParentDark,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Tap to change',
                      style: TextStyle(
                          color: Colors.grey[400], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            _sectionTitle('Reason for Early Pickup *'),
            const SizedBox(height: 10),
            _buildTextField(
              controller: _reasonCtrl,
              hint: 'Medical appointment, family event, etc.',
              maxLines: 3,
            ),
            const SizedBox(height: 20),

            _sectionTitle('Person Picking Up'),
            const SizedBox(height: 10),

            // Relation selector
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _relations.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (ctx, i) {
                  final r = _relations[i];
                  final sel = r == _relation;
                  return GestureDetector(
                    onTap: () => setState(() => _relation = r),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel
                            ? kParentPrimary
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: sel ? kParentPrimary : Colors.grey[300]!,
                        ),
                      ),
                      child: Text(
                        r,
                        style: TextStyle(
                          color: sel ? Colors.white : Colors.grey[700],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
            _buildTextField(
              controller: _collectorNameCtrl,
              hint: "Collector's full name *",
              maxLines: 1,
            ),
            const SizedBox(height: 10),
            _buildTextField(
              controller: _collectorPhoneCtrl,
              hint: "Collector's phone number *",
              maxLines: 1,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),

            // Optional photo note
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kParentPrimary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: kParentPrimary.withValues(alpha: 0.15)),
              ),
              child: Row(
                children: [
                  Icon(Icons.photo_camera_outlined,
                      color: kParentPrimary.withValues(alpha: 0.6), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Photo upload: Available after school approval',
                    style: TextStyle(
                        color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _submit,
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.send_rounded),
                label: const Text(
                  'Submit Pickup Request',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kParentPrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) => Text(
        t,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: kParentDark,
        ),
      );

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: kParentPrimary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}
