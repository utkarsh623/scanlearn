import 'package:flutter/material.dart';
import 'login.dart';

class Signout extends StatefulWidget {
  @override
  State<Signout> createState() => _SignoutState();
}

class _SignoutState extends State<Signout> {
  final Color brandDarkBlue = const Color(0xFF192B44);

  Future<void> _confirmAndSignOut(BuildContext context) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Sign out'),
        content: Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Sign out'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _signOut(context);
    }
  }

  Future<void> _signOut(BuildContext context) async {
    Navigator.of(context).pushNamedAndRemoveUntil('/signup', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Account',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: brandDarkBlue,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      backgroundColor: Colors.white,
      body: ListTile(
        leading: Icon(Icons.logout),
        title: Text('Sign Out'),
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        },
      ),
    );
  }
}
