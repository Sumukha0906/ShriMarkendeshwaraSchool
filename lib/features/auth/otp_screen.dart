import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'phone_login_screen.dart' show SmesSchoolHeader;

// Brand colours (duplicated here to avoid cross-file private access)
const _kPrimary  = Color(0xFF065F46);
const _kDark     = Color(0xFF022C22);
const _kSaffron  = Color(0xFFD97706);
const _kGold     = Color(0xFFF59E0B);
const _kBg       = Color(0xFFF9FBF7);

class OtpScreen extends ConsumerStatefulWidget {
  final String verificationId;
  final String phone;
  final int? resendToken;

  const OtpScreen({
    super.key,
    required this.verificationId,
    required this.phone,
    this.resendToken,
  });

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen>
    with TickerProviderStateMixin {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  bool _isResending = false;
  String? _errorMessage;
  int _resendSeconds = 30;
  bool _canResend = false;

  late AnimationController _slideController;
  late AnimationController _shakeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    _fadeAnimation = CurvedAnimation(parent: _slideController, curve: Curves.easeOut);
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
    _slideController.forward();
    _startResendTimer();
  }

  void _startResendTimer() {
    setState(() {
      _resendSeconds = 30;
      _canResend = false;
    });
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        _resendSeconds--;
        if (_resendSeconds <= 0) _canResend = true;
      });
      return _resendSeconds > 0;
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    _slideController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  Future<void> _verifyOtp() async {
    if (_otpCode.length < 6) {
      setState(() => _errorMessage = 'Please enter the complete 6-digit OTP');
      _shakeController.forward(from: 0);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: _otpCode,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      if (!mounted) return;

      final uid = userCredential.user!.uid;
      final db  = FirebaseFirestore.instance;

      final uidDoc = await db.collection('users').doc(uid).get();
      if (!mounted) return;
      if (uidDoc.exists) {
        context.go('/home');
        return;
      }

      final phoneSnap = await db
          .collection('users')
          .where('phone', isEqualTo: widget.phone)
          .where('isActive', isEqualTo: true)
          .get();
      if (!mounted) return;

      if (phoneSnap.docs.isEmpty) {
        context.go('/complete-profile', extra: {
          'phone': widget.phone,
          'uid': uid,
        });
        return;
      }

      if (phoneSnap.docs.length == 1) {
        await _reconcileUid(phoneSnap.docs.first, uid);
        if (!mounted) return;
        context.go('/home');
        return;
      }

      final chosen = await showDialog<QueryDocumentSnapshot>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _AccountPickerDialog(accounts: phoneSnap.docs),
      );
      if (!mounted) return;
      if (chosen == null) {
        setState(() => _isLoading = false);
        return;
      }
      await _reconcileUid(chosen, uid);
      if (!mounted) return;
      context.go('/home');

    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.code == 'invalid-verification-code'
            ? 'Incorrect OTP. Please check and try again.'
            : 'Verification failed. Please try again.';
      });
      _shakeController.forward(from: 0);
      for (final c in _controllers) c.clear();
      _focusNodes[0].requestFocus();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Something went wrong. Please try again.';
      });
    }
  }

  Future<void> _reconcileUid(QueryDocumentSnapshot doc, String newUid) async {
    if (doc.id == newUid) return;
    final db    = FirebaseFirestore.instance;
    final data  = doc.data() as Map<String, dynamic>;
    final batch = db.batch();
    batch.set(db.collection('users').doc(newUid), {...data, 'uid': newUid});
    batch.delete(db.collection('users').doc(doc.id));
    await batch.commit();
  }

  Future<void> _resendOtp() async {
    if (!_canResend || _isResending) return;
    setState(() => _isResending = true);

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: widget.phone,
      forceResendingToken: widget.resendToken,
      verificationCompleted: (_) {},
      verificationFailed: (e) {
        setState(() {
          _isResending  = false;
          _errorMessage = 'Could not resend OTP. Please try again.';
        });
      },
      codeSent: (String newVerificationId, int? resendToken) {
        setState(() => _isResending = false);
        if (mounted) {
          context.go('/otp', extra: {
            'verificationId': newVerificationId,
            'phone': widget.phone,
            'resendToken': resendToken,
          });
        }
      },
      codeAutoRetrievalTimeout: (_) {},
    );

    _startResendTimer();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _kBg,
        body: Column(
          children: [
            // ── Green header with back button ──────────────────────
            SizedBox(
              height: size.height * 0.36,
              child: Stack(
                children: [
                  SmesSchoolHeader(height: size.height * 0.36),
                  // Back button
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16, top: 8),
                      child: GestureDetector(
                        onTap: () => context.go('/login'),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Slide-up OTP card ──────────────────────────────────
            Expanded(
              child: SafeArea(
                top: false,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                    child: Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: _kPrimary.withValues(alpha: 0.10),
                            blurRadius: 32,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Saffron accent bar
                          Container(
                            height: 4,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              gradient: const LinearGradient(
                                colors: [_kSaffron, _kGold],
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),

                          const Text(
                            'Enter OTP',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: _kDark,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade500,
                                height: 1.5,
                              ),
                              children: [
                                const TextSpan(text: 'A 6-digit code was sent to '),
                                TextSpan(
                                  text: widget.phone,
                                  style: const TextStyle(
                                    color: _kPrimary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // ── OTP boxes ──────────────────────────
                          AnimatedBuilder(
                            animation: _shakeAnimation,
                            builder: (_, child) => Transform.translate(
                              offset: Offset(
                                _shakeController.isAnimating
                                    ? 8 * (0.5 - (_shakeAnimation.value % 0.5) * 2).abs()
                                    : 0,
                                0,
                              ),
                              child: child,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(6, (i) => _buildOtpBox(i)),
                            ),
                          ),

                          // ── Error ─────────────────────────────
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFFCA5A5),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline_rounded,
                                    color: Color(0xFFEF4444),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: const TextStyle(
                                        color: Color(0xFFB91C1C),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 32),

                          // ── Verify button ─────────────────────
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: Material(
                              color: Colors.transparent,
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: (_isLoading || _otpCode.length < 6)
                                      ? null
                                      : const LinearGradient(
                                          colors: [_kPrimary, Color(0xFF047857)],
                                        ),
                                  color: (_isLoading || _otpCode.length < 6)
                                      ? const Color(0xFFE5E7EB)
                                      : null,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: (_isLoading || _otpCode.length < 6)
                                      ? []
                                      : [
                                          BoxShadow(
                                            color: _kPrimary.withValues(alpha: 0.4),
                                            blurRadius: 16,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                ),
                                child: InkWell(
                                  onTap: (_isLoading || _otpCode.length < 6)
                                      ? null
                                      : _verifyOtp,
                                  borderRadius: BorderRadius.circular(16),
                                  child: Center(
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
                                            'Verify & Continue',
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w800,
                                              color: _otpCode.length == 6
                                                  ? Colors.white
                                                  : Colors.grey.shade400,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ── Resend row ────────────────────────
                          Center(
                            child: _canResend
                                ? TextButton.icon(
                                    onPressed: _isResending ? null : _resendOtp,
                                    icon: _isResending
                                        ? const SizedBox(
                                            width: 14,
                                            height: 14,
                                            child: CircularProgressIndicator(
                                              color: _kSaffron,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.refresh_rounded,
                                            color: _kSaffron,
                                            size: 16,
                                          ),
                                    label: const Text(
                                      'Resend OTP',
                                      style: TextStyle(
                                        color: _kSaffron,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  )
                                : RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade400,
                                      ),
                                      children: [
                                        const TextSpan(text: 'Resend OTP in '),
                                        TextSpan(
                                          text: '${_resendSeconds}s',
                                          style: const TextStyle(
                                            color: _kSaffron,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    final filled = _controllers[index].text.isNotEmpty;
    return SizedBox(
      width: 46,
      height: 58,
      child: TextFormField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: _kDark,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: filled
              ? const Color(0xFFD1FAE5)
              : const Color(0xFFF9FBF7),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: _kPrimary.withValues(alpha: 0.3),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: filled
                  ? _kPrimary.withValues(alpha: 0.6)
                  : Colors.grey.shade200,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: _kSaffron,
              width: 2.5,
            ),
          ),
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (value) {
          setState(() {});
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          }
          if (value.isNotEmpty && index == 5) {
            _focusNodes[index].unfocus();
            _verifyOtp();
          }
        },
        onEditingComplete: () {
          if (index < 5) _focusNodes[index + 1].requestFocus();
        },
      ),
    );
  }
}

// ── Account picker dialog ────────────────────────────────────────────────────
class _AccountPickerDialog extends StatefulWidget {
  final List<QueryDocumentSnapshot> accounts;
  const _AccountPickerDialog({required this.accounts});

  @override
  State<_AccountPickerDialog> createState() => _AccountPickerDialogState();
}

class _AccountPickerDialogState extends State<_AccountPickerDialog> {
  final Map<String, String> _schoolNames = {};
  bool _loading = true;

  static const _roleLabels = {
    'TEACHER':       'Teacher',
    'PARENT':        'Parent',
    'ADMIN':         'Admin',
    'ADMINISTRATOR': 'Administrator',
    'PRINCIPAL':     'Principal',
    'MANAGEMENT':    'Management',
    'SUPER_ADMIN':   'Super Admin',
  };

  static const _roleIcons = {
    'TEACHER':       Icons.school_rounded,
    'PARENT':        Icons.child_care_rounded,
    'ADMIN':         Icons.admin_panel_settings_rounded,
    'ADMINISTRATOR': Icons.manage_accounts_rounded,
    'PRINCIPAL':     Icons.account_balance_rounded,
    'MANAGEMENT':    Icons.business_center_rounded,
    'SUPER_ADMIN':   Icons.supervisor_account_rounded,
  };

  static const _roleColors = {
    'TEACHER':       Color(0xFF065F46),
    'PARENT':        Color(0xFFD97706),
    'ADMIN':         Color(0xFF047857),
    'ADMINISTRATOR': Color(0xFF6366F1),
    'PRINCIPAL':     Color(0xFF0284C7),
    'MANAGEMENT':    Color(0xFF7C3AED),
    'SUPER_ADMIN':   Color(0xFFEF4444),
  };

  @override
  void initState() {
    super.initState();
    _fetchSchoolNames();
  }

  Future<void> _fetchSchoolNames() async {
    final ids = widget.accounts
        .map((d) => (d.data() as Map<String, dynamic>)['schoolId'] as String? ?? '')
        .toSet()
        .where((id) => id.isNotEmpty);

    for (final id in ids) {
      try {
        final doc = await FirebaseFirestore.instance.collection('schools').doc(id).get();
        if (doc.exists) {
          _schoolNames[id] = doc.data()?['name'] as String? ?? id;
        }
      } catch (_) {
        _schoolNames[id] = id;
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _kPrimary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.switch_account_rounded,
                  color: _kPrimary, size: 28),
            ),
            const SizedBox(height: 12),
            const Text(
              'Choose Account',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _kDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Multiple accounts found for this number.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 24),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: CircularProgressIndicator(
                  color: _kPrimary,
                  strokeWidth: 2,
                ),
              )
            else
              ...widget.accounts.map((doc) {
                final data     = doc.data() as Map<String, dynamic>;
                final role     = data['role'] as String? ?? '';
                final schoolId = data['schoolId'] as String? ?? '';
                final name     = data['name'] as String? ?? '';
                final color    = _roleColors[role] ?? _kPrimary;
                final icon     = _roleIcons[role] ?? Icons.person_rounded;
                final label    = _roleLabels[role] ?? role;
                final school   = _schoolNames[schoolId] ?? schoolId;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context, doc),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: color.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(icon, color: color, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  label,
                                  style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                                if (name.isNotEmpty)
                                  Text(
                                    name,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                if (school.isNotEmpty)
                                  Text(
                                    school,
                                    style: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 11,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: color.withValues(alpha: 0.5),
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
