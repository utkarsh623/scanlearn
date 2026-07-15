import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class CameraService {
  final _picker = ImagePicker();

  Future<XFile?> pickFromGallery() async {
    final xFile = await _picker.pickImage(source: ImageSource.gallery);
    if (xFile == null) return null;
    return compressImage(xFile);
  }

  Future<XFile> compressImage(XFile file) async {
    if (kIsWeb) return file; // Compression not supported on Web
    
    final dir = await getTemporaryDirectory();
    final targetPath = '${dir.absolute.path}/${DateTime.now().millisecondsSinceEpoch}_compressed.jpg';
    
    var result = await FlutterImageCompress.compressAndGetFile(
      file.path,
      targetPath,
      quality: 70,
    );
    
    if (result == null) return file;
    return result;
  }
}
