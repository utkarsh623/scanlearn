import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scan_learn/core/providers.dart';

class CompareScreen extends ConsumerStatefulWidget {
  const CompareScreen({super.key});

  @override
  ConsumerState<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends ConsumerState<CompareScreen> {
  final _controller = TextEditingController();
  Map<String, dynamic>? _result;
  bool _isLoading = false;

  Future<void> _compare() async {
    final scan = ref.read(currentScanProvider);
    final target = _controller.text.trim();
    if (scan == null || target.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final res = await ref.read(geminiServiceProvider).compareObjects(scan.objectName, target);
      setState(() => _result = res);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scan = ref.watch(currentScanProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Compare Objects')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    scan?.objectName ?? 'Object A',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Text(' VS ', style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type Object B...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _compare,
              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Compare'),
            ),
            const SizedBox(height: 24),
            if (_result != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            height: 100,
                            width: 100,
                            child: CircularProgressIndicator(
                              value: (_result!['similarity_percent'] as num) / 100,
                              strokeWidth: 10,
                              backgroundColor: Colors.grey.shade300,
                            ),
                          ),
                          Text('${_result!['similarity_percent']}%', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text('Similarity', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 24),
                      const Text('Similarities', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ...(_result!['similarities'] as List).map((s) => ListTile(
                        leading: const Icon(Icons.check, color: Colors.green),
                        title: Text(s.toString()),
                      )),
                      const SizedBox(height: 24),
                      const Text('Differences', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ...(_result!['differences'] as List).map((d) {
                        final diff = d as Map<String, dynamic>;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(diff['aspect'], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(child: Text('${scan?.objectName}: ${diff['object_a']}')),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text('${_controller.text}: ${diff['object_b']}')),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 24),
                      const Text('Summary', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(_result!['summary']),
                    ],
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
