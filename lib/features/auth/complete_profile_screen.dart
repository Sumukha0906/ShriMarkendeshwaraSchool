import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_constants.dart';

class CompleteProfileScreen extends ConsumerStatefulWidget {
  final String phone;
  final String uid;

  const CompleteProfileScreen({
    super.key,
    required this.phone,
    required this.uid,
  });

  @override
  ConsumerState<CompleteProfileScreen> createState() =>
      _CompleteProfileScreenState();
}

class _CompleteProfileScreenState
    extends ConsumerState<CompleteProfileScreen>
    with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  bool _isLoading       = false;
  String? _errorMessage;
  bool _inviteFound     = true;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
    _checkInvitation();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

Future<void> _checkInvitation() async {
  try {
    final snap = await FirebaseFirestore.instance
        .collection(FSC.invitations)
        .where('phone', isEqualTo: widget.phone)
        .where('status', isEqualTo: 'PENDING')
        .limit(1)
        .get();
    if (snap.docs.isNotEmpty) {
      final name = snap.docs.first.data()['inviteeName'] as String? ?? '';
      if (name.isNotEmpty && mounted) {
        _nameController.text = name;
      }
      if (mounted) setState(() => _inviteFound = true);
    } else {
      if (mounted) setState(() => _inviteFound = false);
    }
  } catch (_) {
    if (mounted) setState(() => _inviteFound = false);
  }
}

 Future<void> _completeProfile() async {
  if (_nameController.text.trim().isEmpty) {
    setState(() => _errorMessage = 'Please enter your name');
    return;
  }

  setState(() {
    _isLoading    = true;
    _errorMessage = null;
  });

  try {
    final snap = await FirebaseFirestore.instance
        .collection(FSC.invitations)
        .where('phone', isEqualTo: widget.phone)
        .where('status', isEqualTo: 'PENDING')
        .limit(1)
        .get();

    if (snap.docs.isEmpty) {
      setState(() {
        _isLoading    = false;
        _inviteFound  = false;
      });
      return;
    }

    final inviteData      = snap.docs.first.data();
    final String inviteId       = snap.docs.first.id;
    final String schoolId       = inviteData['schoolId'] as String;
    final String role           = inviteData['role'] as String;
    final String email          = inviteData['email'] as String? ?? '';
    final String linkedEntityId = inviteData['linkedEntityId'] as String? ?? '';

    final db    = FirebaseFirestore.instance;
    final batch = db.batch();

    batch.set(
      db.collection(FSC.users).doc(widget.uid),
      {
        'uid':             widget.uid,
        'schoolId':        schoolId,
        'role':            role,
        'name':            _nameController.text.trim(),
        'email':           email,
        'phone':           widget.phone,
        'profilePhotoUrl': '',
        'fcmTokens':       [],
        'isActive':        true,
        'createdAt':       Timestamp.fromDate(DateTime.now()),
      },
    );

    if (inviteId.isNotEmpty) {
      batch.update(
        db.collection(FSC.invitations).doc(inviteId),
        {'status': 'ACCEPTED'},
      );
    }

    // For PARENT role: link this parent uid to the student document
    if (role == 'PARENT' && linkedEntityId.isNotEmpty) {
      batch.update(
        db.collection(FSC.students).doc(linkedEntityId),
        {'parentUid': widget.uid},
      );
    }

    await batch.commit();

    if (mounted) context.go('/home');
  } catch (e) {
    setState(() {
      _isLoading    = false;
      _errorMessage = 'Could not complete setup. Please try again.';
    });
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080D1A),
      body: Stack(
        children: [
          // Ambient glows
          Positioned(
            top: -80,
            left: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF059669).withValues(alpha:0.15),
                    const Color(0x00059669),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            right: -60,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFF59E0B).withValues(alpha:0.1),
                    const Color(0x00F59E0B),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: !_inviteFound
                    ? _buildNoInviteView()
                    : _buildProfileForm(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 60),

        // Progress indicator
        Row(
          children: List.generate(3, (i) => Expanded(
            child: Container(
              margin: const EdgeInsets.only(right: 6),
              height: 3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: i == 2
                    ? const Color(0xFF059669)
                    : const Color(0xFF059669).withValues(alpha:0.3),
              ),
            ),
          )),
        ),
        const SizedBox(height: 8),
        Text(
          'Step 3 of 3',
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha:0.3),
            letterSpacing: 0.5,
          ),
        ),

        const SizedBox(height: 40),

        // Icon
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF59E0B).withValues(alpha:0.4),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(Icons.person_outline_rounded,
              color: Colors.white, size: 26),
        ),

        const SizedBox(height: 20),

        const Text(
          'Almost there!',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tell us your name to complete\nyour account setup.',
          style: TextStyle(
            fontSize: 15,
            color: Colors.white.withValues(alpha:0.4),
            height: 1.5,
          ),
        ),

        const SizedBox(height: 48),

        // Name field section with left-accent border
        Container(
          decoration: const BoxDecoration(
            border: Border(
              left: BorderSide(color: Color(0xFFD97706), width: 3),
            ),
          ),
          padding: const EdgeInsets.only(left: 12),
          child: Text(
            'YOUR FULL NAME',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha:0.4),
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _nameController,
          textCapitalization: TextCapitalization.words,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: 'e.g. Rajesh Kumar',
            hintStyle: TextStyle(
              color: Colors.white.withValues(alpha:0.2),
              fontSize: 15,
            ),
            prefixIcon: Icon(
              Icons.badge_outlined,
              color: Colors.white.withValues(alpha:0.3),
              size: 20,
            ),
            filled: true,
            fillColor: const Color(0xFF065F46).withValues(alpha:0.10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: const Color(0xFF065F46).withValues(alpha:0.3), width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: const Color(0xFF065F46).withValues(alpha:0.3), width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFF59E0B),
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          onChanged: (_) => setState(() {}),
        ),

        if (_errorMessage != null) ...[
          const SizedBox(height: 14),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFD97706).withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFD97706).withValues(alpha:0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: Color(0xFFD97706), size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                        color: Color(0xFFD97706), fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],

        const Spacer(),

        // CTA Button — pill/stadium shape
        SizedBox(
          width: double.infinity,
          height: 54,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                colors: _nameController.text.trim().isNotEmpty
                    ? const [Color(0xFFF59E0B), Color(0xFFD97706)]
                    : [
                        Colors.white.withValues(alpha:0.08),
                        Colors.white.withValues(alpha:0.08),
                      ],
              ),
              boxShadow: _nameController.text.trim().isNotEmpty
                  ? [
                      BoxShadow(
                        color: const Color(0xFFF59E0B).withValues(alpha:0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : [],
            ),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _completeProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: const StadiumBorder(),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      'Complete Setup',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _nameController.text.trim().isNotEmpty
                            ? Colors.white
                            : Colors.white.withValues(alpha:0.3),
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildNoInviteView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: const Color(0xFFD97706).withValues(alpha:0.15),
              border: Border.all(
                color: const Color(0xFFD97706).withValues(alpha:0.3),
              ),
            ),
            child: const Icon(
              Icons.block_rounded,
              color: Color(0xFFD97706),
              size: 32,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Invitation Found',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your number ${widget.phone} does not\nhave a pending invitation.\n\nContact your school administrator.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha:0.4),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () => context.go('/login'),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha:0.15),
                ),
              ),
              child: Text(
                'Back to Login',
                style: TextStyle(
                  color: Colors.white.withValues(alpha:0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}