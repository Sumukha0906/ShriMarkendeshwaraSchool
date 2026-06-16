import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/models/user_model.dart';
import '../parent_dashboard.dart';

class EditParentProfileScreen extends ConsumerStatefulWidget {
  const EditParentProfileScreen({super.key});

  @override
  ConsumerState<EditParentProfileScreen> createState() =>
      _EditParentProfileScreenState();
}

class _EditParentProfileScreenState
    extends ConsumerState<EditParentProfileScreen> {
  final _emailCtrl   = TextEditingController();
  final _addressCtrl = TextEditingController();
  bool _loading = false;
  bool _initialized = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  void _init(UserModel user) {
    if (!_initialized) {
      _emailCtrl.text   = user.email;
      _addressCtrl.text = '';  // address stored separately in Firestore
      _initialized = true;
    }
  }

  Future<void> _save() async {
    if (_emailCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email cannot be empty')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final user = await ref.read(currentUserProvider.future);
      final fs   = ref.read(firestoreServiceProvider);
      if (user != null) {
        await fs.updateParentProfile(
          user.uid,
          email:   _emailCtrl.text.trim(),
          address: _addressCtrl.text.trim(),
        );
      }
      if (mounted) {
        // Invalidate the user provider so it reloads
        ref.invalidate(currentUserProvider);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated!'),
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
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: kParentBg,
      appBar: AppBar(
        backgroundColor: kParentDark,
        foregroundColor: Colors.white,
        title: const Text('Edit Profile',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: userAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: kParentPrimary)),
        error: (e, _) =>
            Center(child: Text('Error: $e')),
        data: (user) {
          if (user == null) return const SizedBox();
          _init(user);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor:
                            kParentPrimary.withValues(alpha: 0.1),
                        backgroundImage:
                            user.profilePhotoUrl.isNotEmpty
                                ? NetworkImage(user.profilePhotoUrl)
                                : null,
                        child: user.profilePhotoUrl.isEmpty
                            ? Text(
                                user.name.isNotEmpty
                                    ? user.name[0].toUpperCase()
                                    : 'P',
                                style: const TextStyle(
                                  color: kParentPrimary,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: kParentDark,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: kParentPrimary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Parent',
                      style: TextStyle(
                        color: kParentPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Phone (read-only)
                const Text(
                  'Phone Number',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: kParentDark,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_rounded,
                          color: Colors.grey, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        user.phone,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Cannot be changed',
                        style: TextStyle(
                            color: Colors.grey[400], fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Email (editable)
                const Text(
                  'Email Address',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: kParentDark,
                  ),
                ),
                const SizedBox(height: 8),
                _buildField(
                  controller: _emailCtrl,
                  hint: 'Enter your email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),

                // Address (editable)
                const Text(
                  'Address',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: kParentDark,
                  ),
                ),
                const SizedBox(height: 8),
                _buildField(
                  controller: _addressCtrl,
                  hint: 'Enter your home address',
                  icon: Icons.home_outlined,
                  maxLines: 3,
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kParentPrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text(
                            'Save Changes',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 15),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
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
        prefixIcon: Icon(icon, color: Colors.grey[500], size: 20),
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
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}
