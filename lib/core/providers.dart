import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scan_learn/repositories/scan_repository.dart';
import 'package:scan_learn/services/camera_service.dart';
import 'package:scan_learn/services/gemini_service.dart';
import 'package:scan_learn/services/storage_service.dart';
import 'package:scan_learn/models/scan_model.dart';
import 'package:scan_learn/models/collection_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final geminiServiceProvider = Provider((ref) => GeminiService());
final storageServiceProvider = Provider((ref) => StorageService());
final cameraServiceProvider = Provider((ref) => CameraService());

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

final favoritesProvider = FutureProvider<List<ScanModel>>((ref) async {
  final box = Hive.box('favorites');
  final scanBox = Hive.box('scans');
  final localFavoriteIds = box.keys.cast<String>().toList();
  final localFavorites = localFavoriteIds
      .map((id) => scanBox.get(id))
      .whereType<ScanModel>()
      .toList();

  try {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return localFavorites;

    final res = await supabase
        .from('favorites')
        .select('*, scans(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    final remoteFavorites = res.map((json) => ScanModel.fromJson(json['scans'] as Map<String, dynamic>)).toList();
    
    // Update local cache
    await box.clear();
    for (final scan in remoteFavorites) {
      await box.put(scan.id, true);
      await scanBox.put(scan.id, scan);
    }
    return remoteFavorites;
  } catch (e) {
    return localFavorites;
  }
});

final collectionsProvider = FutureProvider<List<CollectionModel>>((ref) async {
  try {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final res = await supabase
        .from('collections')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return res.map((json) => CollectionModel.fromJson(json)).toList();
  } catch (e) {
    return [];
  }
});

final timelineProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final scan = ref.watch(currentScanProvider);
  if (scan == null) throw Exception('No scan data');

  final supabase = Supabase.instance.client;
  
  // Try to fetch existing timeline from Supabase
  final res = await supabase.from('scans').select('timeline').eq('id', scan.id).maybeSingle();
  if (res != null && res['timeline'] != null) {
    return (res['timeline'] as List).cast<dynamic>();
  }

  // Generate new timeline via Gemini
  final gemini = ref.watch(geminiServiceProvider);
  final timeline = await gemini.generateTimeline(scan.objectName);
  
  // Save to Supabase
  await supabase.from('scans').update({'timeline': timeline}).eq('id', scan.id);
  
  return timeline;
});
