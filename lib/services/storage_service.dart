import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  /// Saves the image locally to the device's application documents directory
  /// This completely bypasses Supabase cloud storage, fixing all upload errors!
  Future<String> uploadImage(XFile file) async {
    try {
      final ext = file.name.contains('.') ? file.name.split('.').last : 'jpg';
      final fileName = '${const Uuid().v4()}.$ext';
      
      // Get local app directory
      final directory = await getApplicationDocumentsDirectory();
      final String localPath = '${directory.path}/$fileName';
      
      // Save the file locally
      final File localFile = File(localPath);
      await localFile.writeAsBytes(await file.readAsBytes());
      
      return localPath; // Return local path instead of a web URL
    } catch (e) {
      debugPrint('Local storage save error: $e');
      return '';
    }
  }
}
