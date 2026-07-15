import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scan_learn/core/providers.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timelineAsync = ref.watch(timelineProvider);
    final scan = ref.watch(currentScanProvider);

    return Scaffold(
      appBar: AppBar(title: Text(scan != null ? '${scan.objectName} Timeline' : 'Timeline')),
      body: timelineAsync.when(
        data: (timeline) {
          if (timeline.isEmpty) {
            return const Center(child: Text('No timeline available.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: timeline.length,
            itemBuilder: (context, index) {
              final item = timeline[index];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      if (index != timeline.length - 1)
                        Container(
                          width: 2,
                          height: 60,
                          color: Colors.grey.shade300,
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['year'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(item['event'], style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Generating chronological timeline...'),
            ],
          ),
        ),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
