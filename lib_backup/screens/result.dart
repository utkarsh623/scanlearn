import 'package:flutter/material.dart';
import 'dart:io';

class ResultScreen extends StatelessWidget {
  final String title;
  final String details;
  final String? imagePath;

  ResultScreen({required this.title, required this.details, this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Result'),
        backgroundColor: Colors.blue[700],
      ),
      body: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          children: [
            if (imagePath != null) Image.file(File(imagePath!), height: 180),
            SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                color: Colors.blue[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  details,
                  style: TextStyle(fontSize: 17),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
