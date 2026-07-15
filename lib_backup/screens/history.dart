import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  final List<Map<String, String>> scanHistory = [
    {'title': 'QR Code: Math Resource', 'date': '2025-08-18 14:10'},
    {'title': 'Document: English Poem', 'date': '2025-08-18 12:22'},
    {'title': 'Barcode: Science Book', 'date': '2025-08-17 17:05'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan History'),
        backgroundColor: Colors.blue[700],
      ),
      body: ListView.builder(
        itemCount: scanHistory.length,
        itemBuilder: (context, index) {
          final item = scanHistory[index];
          return ListTile(
            leading: Icon(Icons.history, color: Colors.blue),
            title: Text(item['title']!),
            subtitle: Text(item['date']!),
            onTap: () {
              // TODO: Navigate to result screen, passing scan details
            },
          );
        },
      ),
    );
  }
}
