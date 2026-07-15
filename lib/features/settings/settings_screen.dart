import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _learningLevel = 'School Student';
  String _language = 'English';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final box = Hive.box('user_prefs');
    setState(() {
      _learningLevel = box.get('learning_level', defaultValue: 'School Student');
      _language = box.get('language', defaultValue: 'English');
    });
  }

  Future<void> _updateSettings(String key, String value) async {
    setState(() {
      if (key == 'learning_level') _learningLevel = value;
      if (key == 'language') _language = value;
    });
    
    // Save locally
    final box = Hive.box('user_prefs');
    await box.put(key, value);

    // Save to Supabase
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      final dbKey = key == 'learning_level' ? 'learning_level' : 'preferred_language';
      await Supabase.instance.client.from('users').update({dbKey: value}).eq('id', userId);
    }
  }

  Future<void> _clearCache() async {
    await Hive.box('scans').clear();
    await Hive.box('favorites').clear();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cache cleared!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Learning Level', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          DropdownButton<String>(
            value: _learningLevel,
            isExpanded: true,
            items: ['Kids', 'School Student', 'College Student', 'Professional']
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (val) => _updateSettings('learning_level', val!),
          ),
          const SizedBox(height: 24),
          const Text('Preferred Language', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          DropdownButton<String>(
            value: _language,
            isExpanded: true,
            items: ['English', 'Hindi', 'Spanish', 'French']
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (val) => _updateSettings('language', val!),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete_outline),
            label: const Text('Clear Local Cache'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: _clearCache,
          )
        ],
      ),
    );
  }
}
