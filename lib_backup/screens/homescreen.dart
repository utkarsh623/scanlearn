import 'package:flutter/material.dart';
import 'package:scan_learn/screens/history.dart';
import 'package:scan_learn/screens/settings.dart';
import 'scanning.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatelessWidget {
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    // Use non-nullable Color shades for primary and secondary blues
    final primaryBlue = Colors.blue.shade700;
    final secondaryBlue = Colors.blue.shade300;

    Future<void> _showScanOptions() async {
      showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 20,
              runSpacing: 20,
              children: [
                ListTile(
                  leading: Icon(Icons.photo_library, color: primaryBlue),
                  title: Text('Upload from Gallery'),
                  onTap: () async {
                    Navigator.pop(context);
                    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      // Handle the uploaded image file path here
                      // e.g. navigate to image processing screen with pickedFile.path
                      print('Image selected: ${pickedFile.path}');
                    }
                  },
                ),
                ListTile(
                  leading: Icon(Icons.qr_code_scanner, color: primaryBlue),
                  title: Text('Continue Scanning'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ScanningScreen()),
                    );
                  },
                ),
              ],
            ),
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Scan & Learn'),
        backgroundColor: primaryBlue,
        elevation: 3,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 8),
            Text(
              'Welcome!',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: primaryBlue,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Start scanning codes, pages, or images to unlock instant learning!',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[700],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 48),
            // Large centered Scan button with shadow and subtle gradient
            Center(
              child: ElevatedButton(
                onPressed: _showScanOptions,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(220, 220),
                  backgroundColor: primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 12,
                  shadowColor: secondaryBlue.withOpacity(0.6),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code_scanner, size: 88, color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Scan Now',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Spacer(),
            // Bottom Row of History and Settings small buttons with icon + text
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _BottomNavButton(
                  label: "History",
                  icon: Icons.history,
                  color: primaryBlue,
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => HistoryScreen()));
                  },
                ),
                _BottomNavButton(
                  label: "Settings",
                  icon: Icons.settings,
                  color: primaryBlue,
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Settings()));
                  },
                ),
              ],
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _BottomNavButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _BottomNavButton({
    Key? key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 18),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.25),
              offset: Offset(0, 4),
              blurRadius: 8,
            )
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: color),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 16,
                letterSpacing: 0.7,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
