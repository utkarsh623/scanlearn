import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  final _supabase = Supabase.instance.client;

  Future<String> uploadImage(XFile file) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return '';

      final ext = file.name.contains('.') ? file.name.split('.').last : 'jpg';
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
      final path = '$userId/$fileName';

      final bytes = await file.readAsBytes();
      await _supabase.storage.from('scans').uploadBinary(path, bytes);
      
      final signedUrl = await _supabase.storage.from('scans').createSignedUrl(path, 60 * 60 * 24 * 365); // 1 year
      return signedUrl;
    } catch (e) {
      debugPrint('Storage upload error (ignoring): $e');
      return '';
    }
  }
}
