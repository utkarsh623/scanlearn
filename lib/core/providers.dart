import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scan_learn/repositories/scan_repository.dart';
import 'package:scan_learn/services/camera_service.dart';
import 'package:scan_learn/services/gemini_service.dart';
import 'package:scan_learn/services/storage_service.dart';
import 'package:scan_learn/models/scan_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_tts/flutter_tts.dart';

final geminiServiceProvider = Provider((ref) => GeminiService());
final storageServiceProvider = Provider((ref) => StorageService());
final cameraServiceProvider = Provider((ref) => CameraService());
final ttsProvider = Provider((ref) => FlutterTts());

final scanRepositoryProvider = Provider((ref) {
  return ScanRepository(
    ref.watch(geminiServiceProvider),
    ref.watch(storageServiceProvider),
  );
});

final currentScanProvider = StateProvider<ScanModel?>((ref) => null);

final scanHistoryProvider = FutureProvider<List<ScanModel>>((ref) async {
  final box = Hive.box('scans');
  final localScans = box.values.cast<ScanModel>().toList();
  localScans.sort((a, b) => b.createdAt.compareTo(a.createdAt));

  try {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return localScans;

    final res = await supabase
        .from('scans')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    final remoteScans = res.map((json) => ScanModel.fromJson(json)).toList();
    
    // Update local cache
    for (final scan in remoteScans) {
      await box.put(scan.id, scan);
    }
    return remoteScans;
  } catch (e) {
    return localScans; // Return offline cache on network error
  }
});

// Favorites and Collections providers removed.

// Timeline provider removed.

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(_loadTheme());

  static ThemeMode _loadTheme() {
    // Safely check if box is open, otherwise default to system
    if (!Hive.isBoxOpen('user_prefs')) return ThemeMode.system;
    final box = Hive.box('user_prefs');
    final isDark = box.get('isDarkMode');
    if (isDark == null) return ThemeMode.system;
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }

  void toggleTheme(bool isDark) {
    state = isDark ? ThemeMode.dark : ThemeMode.light;
    if (Hive.isBoxOpen('user_prefs')) {
      Hive.box('user_prefs').put('isDarkMode', isDark);
    }
  }
  
  void setSystem() {
    state = ThemeMode.system;
    if (Hive.isBoxOpen('user_prefs')) {
      Hive.box('user_prefs').delete('isDarkMode');
    }
  }
}
