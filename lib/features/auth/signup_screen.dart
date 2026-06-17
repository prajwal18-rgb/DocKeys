import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/auth_service.dart';
import '../../core/utils/role_helper.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isObscured = true;
  bool _isLoading = false;

  // DigiLocker Theme Palette
  final Color primaryPurple = const Color(0xFF613EEA);
  final Color textDark = const Color(0xFF2E2E4E);
  final Color surfaceGrey = const Color(0xFFF8F9FD);

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Minimal Branding Header
            _buildBrandingHeader(),

            // 2. Form Area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildSignupForm(),
            ),

            // 3. Login Redirect
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Already have an account?",
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: Text(
                    "Sign In",
                    style: TextStyle(
                      color: primaryPurple,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandingHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 80, bottom: 40),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryPurple.withOpacity(0.08),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.person_add_outlined,
              size: 48,
              color: primaryPurple,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Create Account",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: textDark,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Secure access to government benefits",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignupForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Registration",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: textDark,
            ),
          ),
          const SizedBox(height: 24),

          // Name Input
          TextFormField(
            controller: nameController,
            textCapitalization: TextCapitalization.words,
            decoration: _inputDecoration("Full Name", Icons.person_outline_rounded),
            validator: (value) => (value == null || value.isEmpty) ? "Name is required" : null,
          ),
          const SizedBox(height: 20),

          // Email Input
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: _inputDecoration("Email Address", Icons.alternate_email_rounded),
            validator: (value) {
              if (value == null || value.isEmpty) return "Email is required";
              if (!value.contains('@')) return "Enter a valid email";
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Password Input
          TextFormField(
            controller: passwordController,
            obscureText: _isObscured,
            decoration: _inputDecoration("Password", Icons.lock_outline_rounded).copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  _isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: Colors.grey,
                  size: 20,
                ),
                onPressed: () => setState(() => _isObscured = !_isObscured),
              ),
            ),
            validator: (value) => (value == null || value.length < 6) ? "Minimum 6 characters" : null,
          ),

          const SizedBox(height: 32),

          // Action Button
          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleSignup,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryPurple,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
              )
                  : const Text(
                "Create Account",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              "By signing up, you agree to our Terms & Privacy Policy",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500),
      prefixIcon: Icon(icon, color: primaryPurple.withOpacity(0.6), size: 22),
      filled: true,
      fillColor: surfaceGrey,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: primaryPurple, width: 1.5),
      ),
    );
  }

  // --- LOGIC (PRESERVED) ---
  Future<void> _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final authService = AuthService();
      try {
        final user = await authService.signUp(
          emailController.text.trim(),
          passwordController.text,
        );
        if (mounted) {
          final isAdmin = user?.email == RoleHelper.adminEmail;
          context.go(isAdmin ? '/main' : '/profile-setup');
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          String errorMessage = "Signup Failed";
          if (e.toString().contains('email-already-in-use')) {
            errorMessage = "This email is already registered.";
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    }
  }
}