import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scan_learn/core/providers.dart';
import 'package:scan_learn/models/scan_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  String _getDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final itemDate = DateTime(date.year, date.month, date.day);

    if (itemDate == today) return 'Today';
    if (itemDate == yesterday) return 'Yesterday';
    return DateFormat('EEEE, MMM d').format(date);
  }

  Future<void> _deleteScan(WidgetRef ref, String id) async {
    try {
      await Supabase.instance.client.from('scans').delete().eq('id', id);
      await Hive.box('scans').delete(id);
      ref.invalidate(scanHistoryProvider);
    } catch (e) {
      debugPrint('Delete failed: $e');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(scanHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: historyAsync.when(
        data: (scans) {
          if (scans.isEmpty) {
            return const Center(child: Text('No scans yet!'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(scanHistoryProvider);
            },
            child: ListView.builder(
              itemCount: scans.length,
              itemBuilder: (context, index) {
                final scan = scans[index];
                return Dismissible(
                  key: Key(scan.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => _deleteScan(ref, scan.id),
                  child: ListTile(
                    leading: scan.imageUrl.isNotEmpty
                        ? SizedBox(
                            width: 50,
                            height: 50,
                            child: CachedNetworkImage(
                              imageUrl: scan.imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const CircularProgressIndicator(),
                              errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                            ),
                          )
                        : const Icon(Icons.image, size: 50),
                    title: Text(scan.objectName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${scan.category ?? 'Uncategorized'} • ${_getDateLabel(scan.createdAt)}'),
                    onTap: () {
                      ref.read(currentScanProvider.notifier).state = scan;
                      context.push('/scan_result');
                    },
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
