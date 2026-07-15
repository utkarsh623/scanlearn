import 'package:flutter/material.dart';
import 'about.dart';
import 'profile.dart';
import 'signout.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final Color brandDarkBlue = Color(0xFF192B44);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: brandDarkBlue,
        elevation: 2,
      ),
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          ListTile(
            title: Text('Profile'),
            leading: Icon(Icons.person_outline),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(
                    name: 'Guest User',
                    phone: '1234567890',
                  ),
                ),
              );
            },
          ),
          ListTile(
            title: Text('Account'),
            leading: Icon(Icons.account_circle_outlined),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => Signout()),
              );
            },
          ),
          ListTile(
            title: Text('About'),
            leading: Icon(Icons.info_outline),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AboutScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
