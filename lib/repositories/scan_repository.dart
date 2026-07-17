import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:scan_learn/models/scan_model.dart';
import 'package:scan_learn/services/gemini_service.dart';
import 'package:scan_learn/services/storage_service.dart';
import 'package:flutter/foundation.dart';

class ScanRepository {
  final GeminiService _geminiService;
  final StorageService _storageService;
  final _supabase = Supabase.instance.client;
  
  ScanRepository(this._geminiService, this._storageService);

  Future<ScanModel> processAndSaveScan(XFile imageFile, {String level = 'School Student', String language = 'English'}) async {
    // 1. Save Image Locally
    String imageUrl = '';
    try {
      imageUrl = await _storageService.uploadImage(imageFile);
    } catch (e) {
      debugPrint('Local storage failed: $e');
    }
    if (imageUrl.isEmpty) {
      imageUrl = imageFile.path;
    }

    // 2. Call Gemini Vision directly with image bytes!
    final imageBytes = await imageFile.readAsBytes();
    final geminiResult = await _geminiService.scanObject(
      imageBytes, 
      level: level, 
      language: language
    );

    if (geminiResult['is_safe'] == false) {
      throw Exception('Image is inappropriate or unsafe.');
    }

    // 3. Create Model
    final userId = _supabase.auth.currentUser?.id ?? 'guest_${const Uuid().v4().substring(0, 8)}';
    final scan = ScanModel(
      id: const Uuid().v4(),
      userId: userId,
      imageUrl: imageUrl, // Now a robust local file path!
      objectName: geminiResult['object_name'] ?? 'Unknown Object',
      category: geminiResult['category'] ?? 'General',
      description: geminiResult['description'] ?? 'No description provided.',
      funFacts: (geminiResult['fun_facts'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      createdAt: DateTime.now(),
    );

    // 4. Save to Supabase (Safe/Optional)
    try {
      await _supabase.from('scans').insert(scan.toJson());
    } catch (e) {
      debugPrint('DB insert failed (ignoring): $e');
    }

    // 5. Save to Hive (Local Cache)
    try {
      final box = Hive.box('scans');
      await box.put(scan.id, scan);
    } catch (e) {
      debugPrint('Hive save failed: $e');
    }

    return scan;
  }
}
