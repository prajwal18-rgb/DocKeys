import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/models/scheme_model.dart';
import '../../core/utils/role_helper.dart';
import '../documents/document_provider.dart';
import '../profile/profile_provider.dart';
import 'scheme_provider.dart';

// --- DigiLocker Theme Constants ---
const Color primaryPurple = Color(0xFF613EEA);
const Color textDark = Color(0xFF2E2E4E);
const Color bgGrey = Color(0xFFFBFBFB);

class SchemesScreen extends StatelessWidget {
  const SchemesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    final schemeProvider = Provider.of<SchemeProvider>(context);
    final documentProvider = Provider.of<DocumentProvider>(context);
    final profile = profileProvider.profile;
    final allSchemes = schemeProvider.schemes;

    if (!RoleHelper.isAdmin && profile == null) {
      return _buildProfileIncompleteScreen(context);
    }

    final eligibleSchemes = (RoleHelper.isAdmin && profile == null)
        ? allSchemes
        : allSchemes.where((scheme) {
      final p = profile!;
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

    return Scaffold(
      backgroundColor: bgGrey,
      body: Column(
        children: [
          // 1. Clean DigiLocker Header
          _buildHeader(),

          // 2. Schemes List
          Expanded(
            child: eligibleSchemes.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
              physics: const BouncingScrollPhysics(),
              itemCount: eligibleSchemes.length,
              itemBuilder: (context, index) {
                final scheme = eligibleSchemes[index];
                final missingDocs = scheme.requiredDocuments
                    .where((doc) => !documentProvider.isUploaded(doc))
                    .toList();
                final isBlocked = missingDocs.isNotEmpty;

                return GestureDetector(
                  onTap: () => context.push('/scheme-details', extra: scheme),
                  child: _schemeCard(context, scheme, isBlocked, missingDocs.length),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 20, left: 20, right: 20),
      color: Colors.white,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.verified_user_outlined, color: primaryPurple, size: 24),
          ),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Eligible Schemes",
                style: TextStyle(
                  color: textDark,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                "Curated opportunities for you",
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _schemeCard(BuildContext context, SchemeModel scheme, bool isBlocked, int missingCount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon Box like "Issued Documents"
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.description_outlined, color: primaryPurple, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        scheme.department.toUpperCase(),
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isBlocked)
                      const Text(
                        "Action Needed",
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: Colors.orange,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  scheme.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                if (isBlocked)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      "$missingCount document(s) missing",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.red[400],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            "No eligible schemes found",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileIncompleteScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.account_circle_outlined, size: 80, color: primaryPurple.withOpacity(0.2)),
              const SizedBox(height: 24),
              const Text(
                "Profile Incomplete",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: textDark),
              ),
              const SizedBox(height: 12),
              const Text(
                "We need your details to find schemes that you are eligible for.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, height: 1.5),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/profile-setup'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryPurple,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Complete Profile",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SchemeDetailsScreen extends StatelessWidget {
  final SchemeModel scheme;

  const SchemeDetailsScreen({super.key, required this.scheme});

  @override
  Widget build(BuildContext context) {
    final isAdmin = RoleHelper.isAdmin;
    final documentProvider = Provider.of<DocumentProvider>(context);

    final missingDocs = isAdmin
        ? const <String>[]
        : scheme.requiredDocuments
        .where((doc) => !documentProvider.isUploaded(doc))
        .toList();
    final isReadyToApply = isAdmin || missingDocs.isEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 18),
        ),
        title: const Text(
          "Scheme Details",
          style: TextStyle(color: textDark, fontWeight: FontWeight.w900, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    scheme.department.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: primaryPurple,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    scheme.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: textDark,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildSectionTitle("About Scheme"),
                  Text(
                    scheme.description,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.6),
                  ),
                  const SizedBox(height: 24),

                  _buildSectionTitle("Eligibility Criteria"),
                  _buildCriteriaGrid(scheme),
                  const SizedBox(height: 24),

                  _buildSectionTitle("Required Documents"),
                  _buildDocumentsList(scheme, documentProvider, isAdmin),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: isAdmin
          ? null
          : _buildBottomBar(context, scheme, isReadyToApply, missingDocs.length),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: textDark),
      ),
    );
  }

  Widget _buildCriteriaGrid(SchemeModel scheme) {
    final criteria = [
      {'icon': Icons.category_outlined, 'label': 'Category', 'val': scheme.eligibleCategories.join(", ")},
      {'icon': Icons.map_outlined, 'label': 'States', 'val': scheme.eligibleStates.join(", ")},
      {'icon': Icons.work_outline_rounded, 'label': 'Occupation', 'val': scheme.eligibleOccupations.join(", ")},
      {'icon': Icons.wc_outlined, 'label': 'Gender', 'val': scheme.eligibleGenders.join(", ")},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.8,
      ),
      itemCount: criteria.length,
      itemBuilder: (context, index) {
        final item = criteria[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item['icon'] as IconData, size: 18, color: primaryPurple),
              const SizedBox(height: 4),
              Text(
                item['label'] as String,
                style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
              ),
              Text(
                item['val'] as String,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textDark),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDocumentsList(SchemeModel scheme, DocumentProvider docProvider, bool isAdmin) {
    return Column(
      children: scheme.requiredDocuments.map((doc) {
        final isUploaded = isAdmin || docProvider.isUploaded(doc);
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isUploaded ? Colors.green.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
            ),
          ),
          child: Row(
            children: [
              Icon(
                isUploaded ? Icons.verified_user_outlined : Icons.info_outline_rounded,
                size: 18,
                color: isUploaded ? Colors.green : Colors.grey,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  doc,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textDark),
                ),
              ),
              if (!isAdmin)
                Text(
                  isUploaded ? "READY" : "MISSING",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: isUploaded ? Colors.green : Colors.grey,
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomBar(BuildContext context, SchemeModel scheme, bool isReady, int missingCount) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!isReady)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                "Please upload $missingCount more document(s) to apply",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ElevatedButton(
            onPressed: isReady
                ? () async {
              final Uri url = Uri.parse(scheme.applyLink);
              if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not open link")));
              }
            }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryPurple,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text(
              "Apply Now",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}