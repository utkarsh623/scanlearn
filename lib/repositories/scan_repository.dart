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
    // 1. Upload to Supabase Storage (Safe)
    String imageUrl = '';
    try {
      imageUrl = await _storageService.uploadImage(imageFile);
    } catch (e) {
      debugPrint('Upload failed: $e');
    }

    // 2. Call Gemini
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);
    final mimeType = 'image/jpeg'; // Assuming jpg from compression

    final geminiResult = await _geminiService.scanObject(
      base64Image, 
      mimeType, 
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
      imageUrl: imageUrl,
      objectName: geminiResult['object_name'] ?? 'Unknown Object',
      category: geminiResult['category'],
      description: geminiResult['description'],
      funFacts: (geminiResult['fun_facts'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      createdAt: DateTime.now(),
    );

    // 4. Save to Supabase (Safe)
    try {
      await _supabase.from('scans').insert(scan.toJson());
    } catch (e) {
      debugPrint('DB insert failed (ignoring): $e');
    }

    // 5. Save to Hive
    try {
      final box = Hive.box('scans');
      await box.put(scan.id, scan);
    } catch (e) {
      debugPrint('Hive save failed: $e');
    }

    return scan;
  }
}
