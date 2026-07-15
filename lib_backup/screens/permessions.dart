import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scan_learn/screens/tutorial.dart';

class PermissionsScreen extends StatefulWidget {
  PermissionsScreen({Key? key}) : super(key: key);

  @override
  _PermissionsScreenState createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  final List<Permission> _permissions = [
    Permission.camera,
    Permission.microphone,
    Permission.storage, // Android < 13
    Permission.photos, // iOS / Android 13+
    Permission.sms,
  ];

  int _currentIndex = 0;
  Map<Permission, PermissionStatus> _permissionsStatus = {};

  @override
  void initState() {
    super.initState();
    _initializeStatuses();
  }

  Future<void> _initializeStatuses() async {
    for (final permission in _permissions) {
      _permissionsStatus[permission] = await permission.status;
    }
    setState(() {});
  }

  Future<void> _requestPermission(Permission permission) async {
    final status = await permission.request();
    setState(() {
      _permissionsStatus[permission] = status;
    });
  }

  String _getPermissionName(Permission permission) {
    switch (permission) {
      case Permission.camera:
        return 'Camera';
      case Permission.microphone:
        return 'Microphone';
      case Permission.storage:
        return 'Storage';
      case Permission.photos:
        return 'Gallery / Photos';
      case Permission.sms:
        return 'SMS';
      default:
        return permission.toString();
    }
  }

  String _getPermissionExplanation(Permission permission) {
    switch (permission) {
      case Permission.camera:
        return 'We need access to your camera to scan objects and QR codes.';
      case Permission.microphone:
        return 'Microphone access is required for voice and audio features.';
      case Permission.storage:
        return 'Allow storage access to save and load files on your device.';
      case Permission.photos:
        return 'Gallery access is needed to upload and select photos.';
      case Permission.sms:
        return 'SMS access is used for security and messaging features.';
      default:
        return '';
    }
  }

  /// Handle when user taps "Allow"
  void _handleAllow() async {
    final permission = _permissions[_currentIndex];
    await _requestPermission(permission);
    _goNext();
  }

  /// Handle when user taps "Deny"
  void _handleDeny() {
    _goNext();
  }

  /// Always move forward, even if denied
  void _goNext() {
    if (_currentIndex < _permissions.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TutorialScreen()),
      );
    }
  }

  bool get allGranted =>
      _permissions.every((p) => _permissionsStatus[p]?.isGranted == true);

  @override
  Widget build(BuildContext context) {
    final permission = _permissions[_currentIndex];
    final status = _permissionsStatus[permission] ?? PermissionStatus.denied;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: _currentIndex > 0,
        leading: _currentIndex > 0
            ? IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.blue[700]),
          onPressed: () {
            setState(() {
              _currentIndex--;
            });
          },
        )
            : null,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Permissions Required',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
              SizedBox(height: 16),
              Text(
                'To provide the best experience, please allow the following permissions:',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              SizedBox(height: 24),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(18.0),
                  child: Column(
                    children: [
                      Icon(
                        status.isGranted
                            ? Icons.check_circle
                            : Icons.lock_outline,
                        size: 40,
                        color: status.isGranted ? Colors.green : Colors.blue,
                      ),
                      SizedBox(height: 16),
                      Text(
                        _getPermissionName(permission),
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 8),
                      Text(
                        status.isGranted ? 'Granted' : 'Not Granted',
                        style: TextStyle(
                          color: status.isGranted ? Colors.green : Colors.red,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        _getPermissionExplanation(permission),
                        textAlign: TextAlign.center,
                        style:
                        TextStyle(fontSize: 15, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ),
              Spacer(),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _handleAllow,
                      icon: Icon(Icons.check),
                      label: Text('Allow'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _handleDeny,
                      icon: Icon(Icons.close),
                      label: Text('Deny'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32),
              if (_currentIndex == _permissions.length - 1)
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TutorialScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    padding:
                    EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    allGranted ? 'Continue' : 'Continue Anyway',
                    style:
                    TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
