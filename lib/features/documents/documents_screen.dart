import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/utils/role_helper.dart';
import '../schemes/scheme_provider.dart';
import '../profile/profile_provider.dart';
import 'document_provider.dart';

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final documentProvider = Provider.of<DocumentProvider>(context);
    final profileProvider = Provider.of<ProfileProvider>(context);
    final schemeProvider = Provider.of<SchemeProvider>(context);
    final profile = profileProvider.profile;

    // DigiLocker Theme Colors
    const primaryPurple = Color(0xFF613EEA);
    const textDark = Color(0xFF2E2E4E);
    const bgGrey = Color(0xFFFBFBFB);

    if (!RoleHelper.isAdmin && profile == null) {
      return _buildProfileIncompleteScreen(context, primaryPurple, textDark);
    }

    // Build required document types
    final requiredDocTypes = <String>{};
    if (!RoleHelper.isAdmin && profile != null) {
      final p = profile;
      final eligibleSchemes = schemeProvider.schemes.where((scheme) {
        return p.age >= scheme.minAge &&
            p.age <= scheme.maxAge &&
            p.income <= scheme.incomeLimit &&
            scheme.eligibleCategories.contains(p.category) &&
            (scheme.eligibleStates.contains("All") || scheme.eligibleStates.contains(p.state)) &&
            (scheme.eligibleOccupations.contains("Any") || scheme.eligibleOccupations.contains(p.occupation)) &&
            scheme.eligibleGenders.contains(p.gender);
      }).toList();

      for (final scheme in eligibleSchemes) {
        requiredDocTypes.addAll(scheme.requiredDocuments);
      }
    }

    final requiredDocs = requiredDocTypes.toList()..sort();
    final uploadedCount = requiredDocs.where((doc) => documentProvider.isUploaded(doc)).length;
    final progress = requiredDocs.isEmpty ? 0.0 : uploadedCount / requiredDocs.length;

    const personalDocs = ["Aadhar Card", "PAN Card", "Driving Licence", "RC"];

    return Scaffold(
      backgroundColor: bgGrey,
      body: Column(
        children: [
          _buildHeader(primaryPurple, textDark),
          _buildProgressSection(uploadedCount, requiredDocs.length, progress, primaryPurple, textDark),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildSectionTitle("Required for Schemes", textDark),
                if (requiredDocs.isEmpty)
                  _buildEmptyDocsCard("No scheme-specific documents required yet.")
                else
                  ...requiredDocs.map((type) => _buildDocumentCard(
                    type: type,
                    isUploaded: documentProvider.isUploaded(type),
                    onUpload: () => documentProvider.pickAndSaveDocument(type),
                    primary: primaryPurple,
                    textDark: textDark,
                  )),
                const SizedBox(height: 20),
                _buildSectionTitle("Personal Documents", textDark),
                ...personalDocs.map((type) {
                  final doc = documentProvider.getDocument(type);
                  return _buildDocumentCard(
                    type: type,
                    isUploaded: doc != null,
                    onUpload: () => documentProvider.pickAndSaveDocument(type),
                    onView: doc == null ? null : () => _showDocumentPreview(context, doc.filePath),
                    primary: primaryPurple,
                    textDark: textDark,
                  );
                }),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Color primary, Color textDark) {
    return Container(
      padding: const EdgeInsets.only(top: 60, bottom: 20, left: 20, right: 20),
      color: Colors.white,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.folder_copy_outlined, color: primary, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "My Documents",
                style: TextStyle(color: textDark, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5),
              ),
              const Text("Manage certificates & proofs", style: TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(int uploaded, int total, double progress, Color primary, Color textDark) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Const removed here to fix the error
              Text(
                "Upload Status",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textDark),
              ),
              Text(
                "$uploaded/$total",
                style: TextStyle(fontWeight: FontWeight.w900, color: primary, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey[100],
              valueColor: AlwaysStoppedAnimation<Color>(primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color textDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: textDark.withOpacity(0.7)),
      ),
    );
  }

  Widget _buildDocumentCard({
    required String type,
    required bool isUploaded,
    required VoidCallback onUpload,
    VoidCallback? onView,
    required Color primary,
    required Color textDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isUploaded ? primary.withOpacity(0.2) : Colors.grey.withOpacity(0.1)),
      ),
      child: ListTile(
        onTap: isUploaded && onView != null ? onView : onUpload,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isUploaded ? Colors.green.withOpacity(0.08) : Colors.grey[50],
            shape: BoxShape.circle,
          ),
          child: Icon(
            isUploaded ? Icons.verified_user_outlined : Icons.file_upload_outlined,
            color: isUploaded ? Colors.green : Colors.grey,
            size: 24,
          ),
        ),
        title: Text(type, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textDark)),
        subtitle: Text(
          isUploaded ? "Verified & Saved" : "Upload required",
          style: TextStyle(color: isUploaded ? Colors.green : Colors.grey, fontSize: 12),
        ),
        trailing: isUploaded
            ? Icon(Icons.chevron_right, color: Colors.grey[400])
            : TextButton(
          onPressed: onUpload,
          child: Text("UPLOAD", style: TextStyle(color: primary, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ),
    );
  }

  Widget _buildEmptyDocsCard(String text) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Text(text, style: const TextStyle(fontSize: 13, color: Colors.grey)),
    );
  }

  Widget _buildProfileIncompleteScreen(BuildContext context, Color primary, Color textDark) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.folder_off_outlined, size: 80, color: primary.withOpacity(0.2)),
              const SizedBox(height: 24),
              Text(
                "Profile Incomplete",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: textDark),
              ),
              const SizedBox(height: 12),
              const Text(
                "To see required documents, please complete your profile.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, height: 1.5),
              ),
              const SizedBox(height: 32),
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
                  child: const Text("Complete Profile", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDocumentPreview(BuildContext context, String path) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: const CloseButton(color: Colors.black),
              title: const Text("Document Preview", style: TextStyle(color: Colors.black, fontSize: 16)),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(File(path), fit: BoxFit.contain),
              ),
            ),
          ],
        ),
      ),
    );
  }
}