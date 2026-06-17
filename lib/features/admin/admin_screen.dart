import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/occupations.dart';
import '../../core/models/scheme_model.dart';
import '../notifications/notification_provider.dart';
import '../schemes/scheme_provider.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // DigiLocker Signature Palette
    const primaryPurple = Color(0xFF613EEA);
    const bgGrey = Color(0xFFFBFBFB);
    const textDark = Color(0xFF2E2E4E);

    return Scaffold(
      backgroundColor: bgGrey,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: _buildHeader(context, primaryPurple, textDark),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Management Tools",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: textDark,
              ),
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              context,
              title: "Publish New Scheme",
              subtitle: "Add a new government scheme to the database.",
              icon: Icons.post_add_outlined,
              iconColor: Colors.blueAccent,
              onTap: () => _showAddSchemeDialog(context, primaryPurple),
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              context,
              title: "Broadcast Announcement",
              subtitle: "Send a notification to all registered users.",
              icon: Icons.campaign_outlined,
              iconColor: primaryPurple,
              onTap: () => _showAnnouncementDialog(context, primaryPurple),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color primary, Color textDark) {
    return Container(
      padding: const EdgeInsets.only(top: 50, bottom: 10, left: 10, right: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.go('/main'),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 18),
          ),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Admin Actions",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: textDark,
                ),
              ),
              const Text(
                "Manage content and alert users.",
                style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
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
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF0F0F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
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
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2E2E4E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600], height: 1.4, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFBDBDBD), size: 24),
          ],
        ),
      ),
    );
  }

  // --- DIALOGS ---

  void _showAnnouncementDialog(BuildContext context, Color primary) {
    final msgController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text("Broadcast Message", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "This message will be sent as a push notification to all active users.",
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: msgController,
              decoration: InputDecoration(
                hintText: "Type your announcement here...",
                hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                filled: true,
                fillColor: const Color(0xFFF5F7FA),
                contentPadding: const EdgeInsets.all(16),
              ),
              maxLines: 5,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
          ElevatedButton(
            onPressed: () {
              if (msgController.text.isNotEmpty) {
                Provider.of<NotificationProvider>(context, listen: false).addNotification("Admin Announcement", msgController.text.trim());
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Announcement Broadcasted!")));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text("Send Now", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showAddSchemeDialog(BuildContext context, Color primary) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final minAgeController = TextEditingController();
    final maxAgeController = TextEditingController();
    final incomeController = TextEditingController();
    final docsController = TextEditingController();
    final applyLinkController = TextEditingController();
    List<String> selectedCategories = ["General"];
    String selectedOccupation = "Any";
    List<String> selectedGenders = ["Male", "Female"];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              title: const Text("New Scheme", style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF2E2E4E))),
              content: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      _buildDialogField(nameController, "Scheme Name", Icons.title_outlined),
                      const SizedBox(height: 12),
                      _buildDialogField(descController, "Short Description", Icons.notes_outlined, maxLines: 3),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildDialogField(minAgeController, "Min Age", Icons.child_care_outlined, isNumber: true)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildDialogField(maxAgeController, "Max Age", Icons.elderly_outlined, isNumber: true)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildDialogField(incomeController, "Income Limit (₹)", Icons.account_balance_wallet_outlined, isNumber: true),
                      const SizedBox(height: 16),
                      _buildCategoryMultiSelect(selectedCategories, (categories) => setState(() => selectedCategories = categories), primary),
                      const SizedBox(height: 12),
                      _buildDialogDropdown("Occupation", selectedOccupation, ["Any", ...occupations], (v) => setState(() => selectedOccupation = v!)),
                      const SizedBox(height: 16),
                      _buildGenderMultiSelect(selectedGenders, (genders) => setState(() => selectedGenders = genders), primary),
                      const SizedBox(height: 12),
                      _buildDialogField(docsController, "Required Documents", Icons.fact_check_outlined),
                      const SizedBox(height: 12),
                      _buildDialogField(applyLinkController, "Official Link", Icons.open_in_new_outlined),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("Discard", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))),
                ElevatedButton(
                  onPressed: () {
                    // Logic for saving...
                    Navigator.pop(dialogContext);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text("Publish", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- REFINED HELPERS ---

  Widget _buildDialogField(TextEditingController controller, String label, IconData icon, {bool isNumber = false, int maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600),
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF613EEA).withOpacity(0.7)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        filled: true,
        fillColor: const Color(0xFFF8F9FD),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
    );
  }

  Widget _buildDialogDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        filled: true,
        fillColor: const Color(0xFFF8F9FD),
        prefixIcon: const Icon(Icons.work_outline, size: 20, color: Color(0xFF613EEA)),
      ),
    );
  }

  Widget _buildCategoryMultiSelect(List<String> selected, Function(List<String>) onChanged, Color primary) {
    final list = ["General", "OBC", "SC", "ST", "Minority"];
    return _buildSelectionGroup("Target Categories", list, selected, onChanged, primary);
  }

  Widget _buildGenderMultiSelect(List<String> selected, Function(List<String>) onChanged, Color primary) {
    final list = ["Male", "Female", "Other"];
    return _buildSelectionGroup("Eligible Genders", list, selected, onChanged, primary);
  }

  Widget _buildSelectionGroup(String title, List<String> options, List<String> selected, Function(List<String>) onChanged, Color primary) {
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
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 0.5)),
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
                  val ? updated.add(opt) : (updated.length > 1 ? updated.remove(opt) : null);
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