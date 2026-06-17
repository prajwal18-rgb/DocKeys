import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/models/document_model.dart';

class DocumentProvider extends ChangeNotifier {
  final Map<String, DocumentModel> _documents = {};

  bool isUploaded(String type) => _documents.containsKey(type);

  DocumentModel? getDocument(String type) => _documents[type];

  Future<void> loadDocuments() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final prefs = await SharedPreferences.getInstance();
    final key = 'documents_$uid';
    final jsonStr = prefs.getString(key);
    // Always reset in-memory documents when loading for a (possibly new) user
    _documents.clear();
    if (jsonStr == null) {
      // No stored docs for this user yet
      notifyListeners();
      return;
    }

    try {
      final decoded = jsonDecode(jsonStr);
      if (decoded is Map<String, dynamic>) {
        for (final e in decoded.entries) {
          _documents[e.key] = DocumentModel.fromJson(
            e.value as Map<String, dynamic>,
          );
        }
      } else if (decoded is List<dynamic>) {
        for (final item in decoded) {
          final m = item as Map<String, dynamic>;
          final type = m['type'] as String? ?? m['name'] as String? ?? '';
          if (type.isNotEmpty) {
            _documents[type] = DocumentModel(
              type: type,
              filePath: m['filePath'] as String,
              uploadedAt: DateTime.parse(m['uploadedAt'] as String),
            );
          }
        }
        await _saveToPrefs();
      }
      notifyListeners();
    } catch (_) {
      // On any parsing error, keep documents cleared for safety
      _documents.clear();
      notifyListeners();
    }
  }

  Future<void> _saveToPrefs() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final prefs = await SharedPreferences.getInstance();
    final key = 'documents_$uid';
    final map = <String, dynamic>{};
    for (final e in _documents.entries) {
      map[e.key] = e.value.toJson();
    }
    await prefs.setString(key, jsonEncode(map));
  }

  Future<void> pickAndSaveDocument(String type) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.single;

    if (file.bytes == null) {
      debugPrint("No file bytes found");
      return;
    }

    // Remove old file if replacing
    final existing = _documents[type];
    if (existing != null) {
      try {
        final oldFile = File(existing.filePath);
        if (await oldFile.exists()) {
          await oldFile.delete();
        }
      } catch (_) {}
    }

    final directory = await getApplicationDocumentsDirectory();

    final fileName = "${DateTime.now().millisecondsSinceEpoch}_${file.name}";
    final newPath = "${directory.path}/$fileName";

    final newFile = File(newPath);

    await newFile.writeAsBytes(file.bytes!);

    final document = DocumentModel(
      type: type,
      filePath: newPath,
      uploadedAt: DateTime.now(),
    );

    _documents[type] = document;
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> deleteDocument(String type) async {
    final doc = _documents[type];
    if (doc == null) return;

    try {
      final file = File(doc.filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}

    _documents.remove(type);
    await _saveToPrefs();
    notifyListeners();
  }
}
