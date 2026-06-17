import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/models/scheme_model.dart';
import '../schemes/scheme_provider.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ---------------------------------------------------------
    // CORE LOGIC (Preserved)
    // ---------------------------------------------------------
    final schemeProvider = Provider.of<SchemeProvider>(context);
    final schemes = schemeProvider.schemes;
    final totalSchemes = schemes.length;
    final recentSchemes = schemes.length > 3 ? schemes.sublist(0, 3) : schemes;
    final newCount = schemes.where((s) => s.isNew).length;
    // ---------------------------------------------------------

    // Theme Colors based on DigiLocker Screenshots
    const primaryPurple = Color(0xFF613EEA);
    const bgGrey = Color(0xFFFBFBFB);
    const textDark = Color(0xFF1F1F1F);

    return Scaffold(
      backgroundColor: bgGrey,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // 1. Clean Header (DigiLocker Style)
            _buildHeader(primaryPurple, textDark),

            // 2. Dashboard Banner (The "Drive Hassle Free" section style)
            _buildPromoBanner(primaryPurple),

            // 3. Stats Grid (Matching the "Categories" grid in image 3)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Quick Overview",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatTile(
                          label: "Total Schemes",
                          value: totalSchemes.toString(),
                          icon: Icons.folder_open_rounded,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatTile(
                          label: "New Alerts",
                          value: newCount.toString(),
                          icon: Icons.notifications_active_outlined,
                          color: primaryPurple,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 4. Recent Schemes (Matching the "Issued Documents" list)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Recently Published",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text("View all",
                            style: TextStyle(color: primaryPurple)),
                      ),
                    ],
                  ),
                  if (recentSchemes.isEmpty)
                    _buildEmptyState()
                  else
                    ...recentSchemes.map((scheme) => _buildSchemeCard(scheme, primaryPurple)),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color primary, Color textDark) {
    return Container(
      padding: const EdgeInsets.only(top: 60, bottom: 20, left: 20, right: 20),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Logo placeholder like image 1
              Container(
                height: 35,
                width: 35,
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.security, color: primary, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                "DigiAdmin", // Based on your app's theme
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF2E2E4E),
                ),
              ),
            ],
          ),
          const CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage('https://via.placeholder.com/150'),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoBanner(Color primary) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: const NetworkImage('https://www.transparenttextures.com/patterns/cubes.png'),
          opacity: 0.1,
          repeat: ImageRepeat.repeat,
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Manage with ease",
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            "Update government schemes and\nnotify citizens instantly.",
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile({required String label, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildSchemeCard(SchemeModel scheme, Color primary) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          // Icon Box like image 2
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.description_outlined, color: primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scheme.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(
                  scheme.department,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Text("No schemes found", style: TextStyle(color: Colors.grey[400])),
      ),
    );
  }
}