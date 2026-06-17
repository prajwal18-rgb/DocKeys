import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/models/user_profile_model.dart';

class ProfileProvider extends ChangeNotifier {
  UserProfileModel? profile;

  ProfileProvider() {
    loadProfile();
  }

  Future<void> updateProfile(UserProfileModel newProfile) async {
    profile = newProfile;

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      "profile_$uid",
      jsonEncode({
        "age": profile!.age,
        "income": profile!.income,
        "occupation": profile!.occupation,
        "gender": profile!.gender,
        "category": profile!.category,
        "state": profile!.state,
      }),
    );

    notifyListeners();
  }

  Future<void> loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final uid = user.uid;
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString("profile_$uid");

    if (data != null) {
      final decoded = jsonDecode(data) as Map<String, dynamic>;

      profile = UserProfileModel(
        age: decoded["age"] as int,
        income: (decoded["income"] as num).toDouble(),
        occupation: decoded["occupation"] as String,
        gender: decoded["gender"] as String,
        category: decoded["category"] as String,
        state: decoded["state"] as String,
      );

      notifyListeners();
    }
  }

  Future<void> clearProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final uid = user.uid;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("profile_$uid");

    profile = null;
    notifyListeners();
  }
}
