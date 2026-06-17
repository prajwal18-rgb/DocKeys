import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isObscured = true;
  bool _isLoading = false;

  // Theme Colors based on DigiLocker Screenshots
  final Color primaryPurple = const Color(0xFF613EEA);
  final Color textDark = const Color(0xFF2E2E4E);

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // DigiLocker uses a very clean white/light grey
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Branding Header (Inspired by Image 3 Splash)
            _buildBrandingHeader(),

            // 2. Login Form (Clean, Modern Card)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildLoginForm(),
            ),

            // 3. Footer Link (Centered and minimal)
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "New to DocKeys?",
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                TextButton(
                  onPressed: () => context.go('/signup'),
                  child: Text(
                    "Create Account",
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
      padding: const EdgeInsets.only(top: 100, bottom: 60),
      child: Column(
        children: [
          // DocKeys Logo Style (Matching DigiLocker logo layout)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryPurple.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.fingerprint_rounded, // Secure, digital identity feel
              size: 54,
              color: primaryPurple,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "DocKeys",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: textDark,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Your digital vault for schemes",
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

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Sign In",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF2E2E4E),
            ),
          ),
          const SizedBox(height: 24),

          // Email Input
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: _inputDecoration("Email Address", Icons.alternate_email_rounded),
            validator: (value) {
              if (value == null || value.isEmpty) return "Email is required";
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
            validator: (value) {
              if (value == null || value.length < 6) return "Password must be at least 6 characters";
              return null;
            },
          ),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: Text(
                "Forgot Password?",
                style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Action Button (Primary DigiLocker Purple)
          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
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
                "Sign In",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
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
      fillColor: const Color(0xFFF8F9FD),
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

  // CORE LOGIC (Preserved)
  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final authService = AuthService();
      try {
        await authService.login(emailController.text.trim(), passwordController.text);
        if (mounted) context.go('/main');
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Login Failed: ${e.toString()}"),
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