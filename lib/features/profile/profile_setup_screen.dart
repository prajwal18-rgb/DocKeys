import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/occupations.dart';
import '../../core/models/user_profile_model.dart';
import 'profile_provider.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController ageController = TextEditingController();
  final TextEditingController incomeController = TextEditingController();

  String? selectedGender;
  String? selectedOccupation;
  String? selectedCategory;
  String? selectedState;

  final List<String> genders = ["Male", "Female", "Other"];
  final List<String> categories = ["General", "OBC", "SC", "ST", "Minority", "Others"];
  final List<String> states = ["Rajasthan", "Delhi", "Maharashtra", "Uttar Pradesh"];

  // DigiLocker Theme Colors
  final Color primaryPurple = const Color(0xFF613EEA);
  final Color textDark = const Color(0xFF2E2E4E);
  final Color surfaceGrey = const Color(0xFFF8F9FD);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = Provider.of<ProfileProvider>(context, listen: false).profile;
      if (profile != null) {
        setState(() {
          ageController.text = profile.age.toString();
          incomeController.text = profile.income.toString();
          selectedGender = profile.gender;
          if (occupations.contains(profile.occupation)) {
            selectedOccupation = profile.occupation;
          }
          if (categories.contains(profile.category)) {
            selectedCategory = profile.category;
          }
          if (states.contains(profile.state)) {
            selectedState = profile.state;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    ageController.dispose();
    incomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 1. Clean Header (DigiLocker Style)
          _buildHeader(),

          // 2. Form Section
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: _buildFormContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 20, left: 12, right: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (context.canPop()) context.pop();
            },
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 18),
          ),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Profile Details",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: textDark,
                ),
              ),
              const Text(
                "Find schemes tailored for you",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormContent() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Personal Information",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 24),

          _buildTextField(
            controller: ageController,
            label: "Current Age",
            icon: Icons.cake_outlined,
            keyboardType: TextInputType.number,
            validator: (val) => val == null || val.isEmpty ? "Required" : null,
          ),
          const SizedBox(height: 20),

          _buildDropdown(
            label: "Gender",
            value: selectedGender,
            items: genders,
            icon: Icons.wc_rounded,
            onChanged: (val) => setState(() => selectedGender = val),
          ),
          const SizedBox(height: 20),

          _buildTextField(
            controller: incomeController,
            label: "Annual Income (₹)",
            icon: Icons.payments_outlined,
            keyboardType: TextInputType.number,
            validator: (val) => val == null || val.isEmpty ? "Required" : null,
          ),
          const SizedBox(height: 20),

          _buildDropdown(
            label: "Occupation",
            value: selectedOccupation,
            items: occupations,
            icon: Icons.work_outline_rounded,
            onChanged: (val) => setState(() => selectedOccupation = val),
          ),
          const SizedBox(height: 20),

          _buildDropdown(
            label: "Category",
            value: selectedCategory,
            items: categories,
            icon: Icons.category_outlined,
            onChanged: (val) => setState(() => selectedCategory = val),
          ),
          const SizedBox(height: 20),

          _buildDropdown(
            label: "State of Residence",
            value: selectedState,
            items: states,
            icon: Icons.map_outlined,
            onChanged: (val) => setState(() => selectedState = val),
          ),

          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryPurple,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                "Update Profile",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(fontWeight: FontWeight.bold, color: textDark),
      decoration: _inputDecoration(label, icon),
      validator: validator,
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((item) => DropdownMenuItem(
        value: item,
        child: Text(item, style: TextStyle(fontWeight: FontWeight.bold, color: textDark)),
      )).toList(),
      onChanged: onChanged,
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
      decoration: _inputDecoration(label, icon),
      validator: (val) => val == null ? "Required" : null,
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

  // --- CORE LOGIC (Preserved) ---
  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        final age = int.parse(ageController.text);
        final income = double.parse(incomeController.text);

        final userProfile = UserProfileModel(
          age: age,
          income: income,
          occupation: selectedOccupation!,
          gender: selectedGender!,
          category: selectedCategory!,
          state: selectedState!,
        );

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => const Center(child: CircularProgressIndicator()),
        );

        await Provider.of<ProfileProvider>(context, listen: false).updateProfile(userProfile);

        if (mounted) {
          Navigator.pop(context);
          context.go('/main');
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $e"), behavior: SnackBarBehavior.floating),
          );
        }
      }
    }
  }
}