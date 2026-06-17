import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/models/scheme_model.dart';
import '../documents/document_provider.dart';
import '../notifications/notification_provider.dart';
import '../profile/profile_provider.dart';
import '../schemes/scheme_provider.dart';
import 'tab_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ---------------------------------------------------------
    // CORE LOGIC (UNCHANGED)
    // ---------------------------------------------------------
    final profileProvider = Provider.of<ProfileProvider>(context);
    final schemeProvider = Provider.of<SchemeProvider>(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final documentProvider = Provider.of<DocumentProvider>(context);
    final profile = profileProvider.profile;

    final eligibleSchemes = profile == null
        ? <SchemeModel>[]
        : schemeProvider.schemes.where((scheme) {
      final p = profile;
      return p.age >= scheme.minAge &&
          p.age <= scheme.maxAge &&
          p.income <= scheme.incomeLimit &&
          scheme.eligibleCategories.contains(p.category) &&
          (scheme.eligibleStates.contains("All") ||
              scheme.eligibleStates.contains(p.state)) &&
          (scheme.eligibleOccupations.contains("Any") ||
              scheme.eligibleOccupations.contains(p.occupation)) &&
          scheme.eligibleGenders.contains(p.gender);
    }).toList();

    final eligibleCount = eligibleSchemes.length;

    final requiredDocTypes = <String>{};
    for (final scheme in eligibleSchemes) {
      requiredDocTypes.addAll(scheme.requiredDocuments);
    }
    final missingCount = requiredDocTypes
        .where((doc) => !documentProvider.isUploaded(doc))
        .length;

    final latestScheme = schemeProvider.schemes.isNotEmpty
        ? (List<SchemeModel>.from(schemeProvider.schemes)
      ..sort((a, b) => b.uploadDate.compareTo(a.uploadDate)))
        .first
        : null;

    const userName = "User";
    final hasUnreadNotifications = notificationProvider.unreadCount > 0;
    // ---------------------------------------------------------

    const primaryPurple = Color(0xFF613EEA);
    const textDark = Color(0xFF2E2E4E);

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // 1. Clean Header (DigiLocker Style)
            _buildModernHeader(context, userName, hasUnreadNotifications, primaryPurple, textDark),

            // 2. DigiLocker Banner Section
            _buildPromoBanner(primaryPurple),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "Quick Overview",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: textDark),
                  ),
                  const SizedBox(height: 16),

                  // 3. Category Style Stats
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatTile(
                          context,
                          label: "Eligible Schemes",
                          value: "$eligibleCount",
                          icon: Icons.assignment_turned_in_outlined,
                          color: Colors.orange,
                          tabIndex: 1,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatTile(
                          context,
                          label: "Missing Docs",
                          value: "$missingCount",
                          icon: Icons.folder_open_outlined,
                          color: primaryPurple,
                          tabIndex: 3,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Latest Opportunity",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: textDark),
                      ),
                      TextButton(
                        onPressed: () => Provider.of<TabProvider>(context, listen: false).setIndex(1),
                        child: const Text("View all", style: TextStyle(color: primaryPurple, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),

                  // 4. Hero Card (Issued Documents Style)
                  if (latestScheme != null)
                    GestureDetector(
                      onTap: () => GoRouter.of(context).push('/scheme-details', extra: latestScheme),
                      child: _buildHeroSchemeCard(latestScheme, primaryPurple, textDark),
                    )
                  else
                    _buildEmptyState(),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernHeader(BuildContext context, String name, bool hasUnread, Color primary, Color textDark) {
    return Container(
      padding: const EdgeInsets.only(top: 60, bottom: 20, left: 20, right: 20),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Hi $name", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: textDark)),
              const Text("Welcome to DocKeys", style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
                child: IconButton(
                  icon: const Icon(Icons.notifications_none_rounded, color: Colors.black),
                  onPressed: () => Provider.of<TabProvider>(context, listen: false).setIndex(4),
                ),
              ),
              if (hasUnread)
                Positioned(
                    right: 12,
                    top: 12,
                    child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5))
                    )
                ),
            ],
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
        gradient: LinearGradient(
          colors: [primary, primary.withBlue(255)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Access schemes hassle-free", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("Your digital keys to all government benefits and state-wise opportunities.",
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildStatTile(BuildContext context, {required String label, required String value, required IconData icon, required Color color, required int tabIndex}) {
    return GestureDetector(
      onTap: () => Provider.of<TabProvider>(context, listen: false).setIndex(tabIndex),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSchemeCard(SchemeModel scheme, Color primary, Color textDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.description_outlined, color: primary, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(scheme.name, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: textDark)),
                const SizedBox(height: 4),
                Text(scheme.department, style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
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
        child: Text("No schemes found", style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold)),
      ),
    );
  }
}