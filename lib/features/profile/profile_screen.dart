import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/services/auth_service.dart';
import '../../core/utils/role_helper.dart';
import 'profile_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isAdmin = RoleHelper.isAdmin;
    final profileProvider = Provider.of<ProfileProvider>(context);
    final profile = profileProvider.profile;

    // DigiLocker Theme Colors
    const primaryPurple = Color(0xFF613EEA);
    const textDark = Color(0xFF2E2E4E);
    const bgGrey = Color(0xFFFBFBFB);

    return Scaffold(
      backgroundColor: bgGrey,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // 1. Clean Header (DigiLocker Style)
            _buildProfileHeader(user?.email ?? "User", isAdmin, primaryPurple, textDark),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  if (isAdmin)
                    _buildAdminView(context, primaryPurple, textDark)
                  else if (profile == null)
                    _buildEmptyProfileView(context, primaryPurple, textDark)
                  else
                    _buildUserProfileView(context, profile, primaryPurple, textDark),

                  const SizedBox(height: 24),

                  // 3. Logout Button
                  _buildLogoutButton(context),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(String email, bool isAdmin, Color primary, Color textDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 30, left: 20, right: 20),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.person_outline_rounded, color: primary, size: 24),
              ),
              const SizedBox(width: 16),
              Text(
                "My Profile",
                style: TextStyle(
                  color: textDark,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          CircleAvatar(
            radius: 45,
            backgroundColor: primary.withOpacity(0.1),
            child: Text(
              email.isNotEmpty ? email[0].toUpperCase() : "U",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: primary),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            email,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark),
          ),
          if (isAdmin)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: textDark,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                "ADMINISTRATOR",
                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAdminView(BuildContext context, Color primary, Color textDark) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(Icons.admin_panel_settings_outlined, size: 48, color: primary),
          const SizedBox(height: 16),
          Text(
            "Admin Controls",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: textDark),
          ),
          const SizedBox(height: 8),
          const Text(
            "Full access to manage all schemes, notifications, and user documents.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyProfileView(BuildContext context, Color primary, Color textDark) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          const Icon(Icons.account_circle_outlined, size: 48, color: Colors.orange),
          const SizedBox(height: 16),
          Text(
            "Profile Incomplete",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: textDark),
          ),
          const SizedBox(height: 8),
          const Text(
            "Please complete your profile details to discover eligible government schemes.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, height: 1.4),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.go('/profile-setup'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text("Complete Setup", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfileView(BuildContext context, dynamic profile, Color primary, Color textDark) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Personal Details",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: textDark),
                ),
                const SizedBox(height: 20),
                _buildInfoRow(Icons.cake_outlined, "Age", "${profile.age} years", primary),
                _buildDivider(),
                _buildInfoRow(Icons.wc_outlined, "Gender", profile.gender, primary),
                _buildDivider(),
                _buildInfoRow(Icons.category_outlined, "Category", profile.category, primary),
                _buildDivider(),
                _buildInfoRow(Icons.work_outline_rounded, "Occupation", profile.occupation, primary),
                _buildDivider(),
                _buildInfoRow(Icons.payments_outlined, "Annual Income", "₹${profile.income}", primary),
                _buildDivider(),
                _buildInfoRow(Icons.map_outlined, "State", profile.state, primary),
              ],
            ),
          ),
          InkWell(
            onTap: () => context.go('/profile-setup'),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit_note_rounded, size: 20, color: primary),
                  const SizedBox(width: 8),
                  Text(
                    "Edit Profile Details",
                    style: TextStyle(color: primary, fontWeight: FontWeight.w900, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color primary) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: primary.withOpacity(0.5)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2E2E4E))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: Colors.grey.withOpacity(0.1));
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: () async {
          await AuthService().logout();
          if (context.mounted) context.go('/login');
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.redAccent, width: 1),
          ),
        ),
        icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
        label: const Text(
          "Log Out",
          style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900, fontSize: 15),
        ),
      ),
    );
  }
}