import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scan_learn/core/providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CollectionsScreen extends ConsumerWidget {
  const CollectionsScreen({super.key});

  Future<void> _createCollection(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Collection'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'e.g. Animals'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                try {
                  final userId = Supabase.instance.client.auth.currentUser?.id;
                  if (userId != null) {
                    await Supabase.instance.client.from('collections').insert({
                      'user_id': userId,
                      'name': name,
                    });
                    ref.invalidate(collectionsProvider);
                  }
                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                  debugPrint('Error creating collection: $e');
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionsAsync = ref.watch(collectionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Collections')),
      body: collectionsAsync.when(
        data: (collections) {
          if (collections.isEmpty) {
            return const Center(child: Text('No collections yet. Create one!'));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(collectionsProvider),
            child: ListView.builder(
              itemCount: collections.length,
              itemBuilder: (context, index) {
                final c = collections[index];
                return ListTile(
                  leading: const Icon(Icons.folder, color: Colors.blue),
                  title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () {
                    // Navigate to collection details
                  },
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createCollection(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}
