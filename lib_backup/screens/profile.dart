import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.name,
    required this.phone,
    this.assetAvatarPath = 'assets/images/images/profile.jpg',
  });

  final String name;
  final String phone;
  final String assetAvatarPath;

  @override
  Widget build(BuildContext context) {
    const brandDarkBlue = Color(0xFF192B44);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: brandDarkBlue,
        elevation: 2,
      ),
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 8),
          Center(
            child: CircleAvatar(
              radius: 48,
              backgroundImage: AssetImage(assetAvatarPath),
              backgroundColor: Colors.transparent,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.badge_outlined),
            title: const Text('Name'),
            subtitle: Text(name),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.phone_outlined),
            title: const Text('Mobile number'),
            subtitle: Text(phone),
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }
}
