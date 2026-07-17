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
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        title: const Text('Your Library', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: historyAsync.when(
        data: (scans) {
          if (scans.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_edu, size: 100, color: Colors.grey.shade300),
                  const SizedBox(height: 24),
                  const Text('No scans yet!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black54)),
                  const SizedBox(height: 8),
                  const Text('Start exploring to build your library.', style: TextStyle(color: Colors.black38)),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(scanHistoryProvider);
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: scans.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final scan = scans[index];
                return Dismissible(
                  key: Key(scan.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    decoration: BoxDecoration(
                      color: Colors.red.shade400,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
                  ),
                  onDismissed: (_) => _deleteScan(ref, scan.id),
                  child: GestureDetector(
                    onTap: () {
                      ref.read(currentScanProvider.notifier).state = scan;
                      context.push('/scan_result');
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          // Thumbnail
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                            ),
                            child: SizedBox(
                              width: 100,
                              height: 100,
                              child: scan.imageUrl.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: scan.imageUrl,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(color: Colors.grey.shade200, child: const Center(child: CircularProgressIndicator())),
                                      errorWidget: (context, url, error) => Container(color: Colors.grey.shade100, child: const Icon(Icons.broken_image, color: Colors.grey)),
                                    )
                                  : Container(color: Colors.grey.shade100, child: const Icon(Icons.image, color: Colors.grey, size: 40)),
                            ),
                          ),
                          // Content
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    scan.objectName,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    scan.category ?? 'Uncategorized',
                                    style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 13, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _getDateLabel(scan.createdAt),
                                    style: const TextStyle(color: Colors.black45, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Arrow
                          const Padding(
                            padding: EdgeInsets.only(right: 16.0),
                            child: Icon(Icons.chevron_right, color: Colors.black26),
                          )
                        ],
                      ),
                    ),
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
