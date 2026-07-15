import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:scan_learn/screens/result.dart';

class ImagePickerScreen extends StatefulWidget {
  @override
  _ImagePickerScreenState createState() => _ImagePickerScreenState();
}

class _ImagePickerScreenState extends State<ImagePickerScreen> {
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              title: 'Scanned Result',
              details: 'Details about scanned content here.',
              imagePath: image.path,
            ),
          ),
        );
      } else {
        // User canceled the picker
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No image selected.')),
        );
      }
    } catch (e) {
      // Handle any errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pick an Image'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _selectedImage == null
                ? Icon(Icons.image, size: 120, color: Colors.grey)
                : Image.file(File(_selectedImage!.path), height: 200),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.camera),
              icon: Icon(Icons.camera_alt),
              label: Text('Take a Photo'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[700]),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: Icon(Icons.photo_library),
              label: Text('Choose from Gallery'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[700]),
            ),
          ],
        ),
      ),
    );
  }
}
