import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const brandDarkBlue = Color(0xFF192B44);

    return Scaffold(
      appBar: AppBar(
        title: const Text('About',style:(TextStyle(color:Colors.white))),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: brandDarkBlue,
        foregroundColor: brandDarkBlue,
        elevation: 2,
      ),
      backgroundColor: Colors.white,
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Scan & Learn',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              'Version v1.2.4 • Build 7',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 16),
            Text(
              'Scan & Learn lets you scan anything(objects/images/qrcodes/..etc) and instantly access learning content. '
                  'Fast, simple, and easy to use.',
              style: TextStyle(fontSize: 16, height: 1.4),
            ),
            SizedBox(height: 24),
            Text('Developer:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Utkarsh Chaudhary'),
            SizedBox(height: 16),
            Text('Contact:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('chaudharyutkarsh.4127@gmail.com'),
          ],
        ),
      ),
    );
  }
}
