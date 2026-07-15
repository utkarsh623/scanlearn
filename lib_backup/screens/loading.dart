import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  final String message;

  LoadingScreen({this.message = 'Please wait...'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F9FF),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Colors.blue[700],
              strokeWidth: 5,
            ),
            SizedBox(height: 32),
            Text(
              message,
              style: TextStyle(
                fontSize: 18,
                color: Colors.blue[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
