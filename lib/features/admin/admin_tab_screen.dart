import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/occupations.dart';
import '../../core/models/scheme_model.dart';
import '../notifications/notification_provider.dart';
import '../schemes/scheme_provider.dart';

class AdminTabScreen extends StatelessWidget {
  const AdminTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryPurple = Color(0xFF613EEA);
    const textDark = Color(0xFF2E2E4E);
    const bgGrey = Color(0xFFFBFBFB);

    return Scaffold(
      backgroundColor: bgGrey,
      body: Column(
        children: [
          // 1. DigiLocker Style Header
          _buildHeader(primaryPurple),

          // 2. Action Cards & Scheme List
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildActionCard(
                    context,
                    title: "Create New Scheme",
                    subtitle: "Launch a new government scheme for eligible users.",
                    icon: Icons.add_moderator_outlined,
                    iconColor: primaryPurple,
                    onTap: () => _showAddSchemeDialog(context, primaryPurple),
                  ),
                  const SizedBox(height: 12),
                  _buildActionCard(
                    context,
                    title: "Public Announcement",
                    subtitle: "Send a system-wide notification to all users.",
                    icon: Icons.campaign_outlined,
                    iconColor: Colors.orange[700]!,
                    onTap: () => _showAnnouncementDialog(context, primaryPurple),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.list_alt_rounded, size: 18, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        "All Published Schemes",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSchemeList(context, primaryPurple, textDark),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Color primary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 20, left: 20, right: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.shield_outlined, color: primary, size: 24),
          ),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Scheme Manager",
                style: TextStyle(
                  color: Color(0xFF2E2E4E),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                "Manage opportunities & alerts",
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required Color iconColor,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2E2E4E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600], height: 1.3),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSchemeList(BuildContext context, Color primary, Color textDark) {
    final schemeProvider = Provider.of<SchemeProvider>(context);
    final schemes = schemeProvider.schemes;

    if (schemes.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Icon(Icons.folder_open_outlined, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              "No Published Schemes",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: schemes.length,
      itemBuilder: (context, index) {
        final scheme = schemes[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.15)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.description_outlined, color: primary, size: 24),
            ),
            title: Text(
              scheme.name,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textDark),
            ),
            subtitle: Text(
              scheme.department,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22),
              onPressed: () => _confirmDelete(context, scheme, schemeProvider),
            ),
          ),
        );
      },
    );
  }

  // --- REFINED DIALOGS ---

  void _showAnnouncementDialog(BuildContext context, Color primary) {
    final msgController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Broadcast Message", style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF2E2E4E))),
        content: TextField(
          controller: msgController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: "Enter announcement text...",
            filled: true,
            fillColor: const Color(0xFFF8F9FD),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              if (msgController.text.isNotEmpty) {
                Provider.of<NotificationProvider>(context, listen: false).addNotification("Admin Announcement", msgController.text.trim());
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Broadcast", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, SchemeModel scheme, SchemeProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Delete Scheme?"),
        content: Text('This will remove "${scheme.name}" for all users.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              provider.deleteScheme(scheme);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, elevation: 0),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddSchemeDialog(BuildContext context, Color primary) {
    // Controllers
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final minAgeController = TextEditingController();
    final maxAgeController = TextEditingController();
    final incomeController = TextEditingController();
    final docsController = TextEditingController();
    final applyLinkController = TextEditingController();

    // State
    List<String> selectedCategories = ["General"];
    List<String> selectedStates = ["All"];
    String selectedOccupation = "Any";
    List<String> selectedGenders = ["Male", "Female"];

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: const Text(
            "Create New Scheme",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: Color(0xFF2E2E4E),
            ),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildDialogInput(nameController, "Scheme Name", Icons.title_outlined, primary),
                  const SizedBox(height: 12),
                  _buildDialogInput(descController, "Short Description", Icons.notes_outlined, primary, maxLines: 3),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDialogInput(minAgeController, "Min Age", Icons.child_care_outlined, primary, isNumber: true),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDialogInput(maxAgeController, "Max Age", Icons.elderly_outlined, primary, isNumber: true),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildDialogInput(incomeController, "Income Limit (₹)", Icons.account_balance_wallet_outlined, primary, isNumber: true),
                  const SizedBox(height: 16),
                  _buildCategoryMultiSelect(selectedCategories, (categories) {
                    setState(() => selectedCategories = categories);
                  }, primary),
                  const SizedBox(height: 12),
                  _buildDialogDropdown(
                    "Occupation",
                    selectedOccupation,
                    ["Any", ...occupations],
                    (v) => setState(() => selectedOccupation = v!),
                    primary,
                  ),
                  const SizedBox(height: 16),
                  _buildGenderMultiSelect(selectedGenders, (genders) {
                    setState(() => selectedGenders = genders);
                  }, primary),
                  const SizedBox(height: 16),
                  _buildStateMultiSelect(selectedStates, (states) {
                    setState(() => selectedStates = states);
                  }, primary),
                  const SizedBox(height: 16),
                  _buildDialogInput(docsController, "Required Documents (comma separated)", Icons.fact_check_outlined, primary),
                  const SizedBox(height: 12),
                  _buildDialogInput(applyLinkController, "Official Apply Link", Icons.open_in_new_outlined, primary),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final desc = descController.text.trim();
                final minAge = int.tryParse(minAgeController.text);
                final maxAge = int.tryParse(maxAgeController.text);
                final income = double.tryParse(incomeController.text);
                final applyLink = applyLinkController.text.trim();

                if (name.isEmpty ||
                    desc.isEmpty ||
                    minAge == null ||
                    maxAge == null ||
                    income == null ||
                    applyLink.isEmpty ||
                    selectedCategories.isEmpty ||
                    selectedGenders.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please fill all required fields and select at least one category and gender."),
                    ),
                  );
                  return;
                }

                final states = selectedStates.isEmpty ? ["All"] : selectedStates;

                final docsStr = docsController.text.trim();
                final docs = docsStr.isEmpty
                    ? ["Aadhar Card"]
                    : docsStr.split(",").map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

                final newScheme = SchemeModel(
                  name: name,
                  department: "Admin Department",
                  description: desc,
                  minAge: minAge,
                  maxAge: maxAge,
                  incomeLimit: income,
                  eligibleCategories: selectedCategories,
                  eligibleStates: states,
                  eligibleOccupations: selectedOccupation == "Any" ? ["Any"] : [selectedOccupation],
                  eligibleGenders: selectedGenders,
                  requiredDocuments: docs,
                  uploadDate: DateTime.now(),
                  isNew: true,
                  applyLink: applyLink,
                );

                Provider.of<SchemeProvider>(context, listen: false).addScheme(newScheme);
                Provider.of<NotificationProvider>(context, listen: false).addNotification(
                  "New Scheme",
                  "$name is now live.",
                );

                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Scheme Published!")),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text(
                "Publish",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogInput(
    TextEditingController controller,
    String label,
    IconData icon,
    Color primary, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600),
        prefixIcon: Icon(icon, size: 20, color: primary.withOpacity(0.7)),
        filled: true,
        fillColor: const Color(0xFFF8F9FD),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildDialogDropdown(
    String label,
    String value,
    List<String> items,
    Function(String?) onChanged,
    Color primary,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ),
          )
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        filled: true,
        fillColor: const Color(0xFFF8F9FD),
        prefixIcon: Icon(Icons.work_outline, size: 20, color: primary),
      ),
    );
  }

  Widget _buildCategoryMultiSelect(
    List<String> selected,
    Function(List<String>) onChanged,
    Color primary,
  ) {
    final options = ["General", "OBC", "SC", "ST", "Minority"];
    return _buildSelectionGroup("Target Categories", options, selected, onChanged, primary);
  }

  Widget _buildGenderMultiSelect(
    List<String> selected,
    Function(List<String>) onChanged,
    Color primary,
  ) {
    final options = ["Male", "Female", "Other"];
    return _buildSelectionGroup("Eligible Genders", options, selected, onChanged, primary);
  }

  Widget _buildStateMultiSelect(
    List<String> selected,
    Function(List<String>) onChanged,
    Color primary,
  ) {
    final options = ["All", "Maharashtra", "Delhi", "Uttar Pradesh", "Rajasthan"];
    return _buildSelectionGroup("Eligible States", options, selected, onChanged, primary);
  }

  Widget _buildSelectionGroup(
    String title,
    List<String> options,
    List<String> selected,
    Function(List<String>) onChanged,
    Color primary,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FD),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Colors.grey,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: options.map((opt) {
              final isSelected = selected.contains(opt);
              return ChoiceChip(
                label: Text(opt),
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
                selected: isSelected,
                onSelected: (val) {
                  final updated = List<String>.from(selected);
                  if (val) {
                    if (!updated.contains(opt)) updated.add(opt);
                  } else {
                    updated.remove(opt);
                  }
                  onChanged(updated);
                },
                selectedColor: primary,
                backgroundColor: Colors.white,
                elevation: isSelected ? 4 : 0,
                pressElevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: isSelected ? primary : const Color(0xFFE0E0E0)),
                ),
                showCheckmark: false,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}