import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanningScreen extends StatefulWidget {
  @override
  _ScanningScreenState createState() => _ScanningScreenState();
}

class _ScanningScreenState extends State<ScanningScreen> {
  final MobileScannerController controller = MobileScannerController();
  String? scannedData;
  bool isTorchOn = false;

  void _onDetect(BarcodeCapture capture) {
    final Barcode? barcode = capture.barcodes.isNotEmpty ? capture.barcodes.first : null;
    final String? code = barcode?.rawValue;

    if (code != null && code.isNotEmpty && code != scannedData) {
      setState(() {
        scannedData = code;
      });

      controller.stop();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Scanned Result'),
          content: Text(code),
          actions: [
            TextButton(
              onPressed: () {
                controller.start();
                Navigator.of(context).pop();
                setState(() {
                  scannedData = null;
                });
              },
              child: Text('Scan Again'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(code);
              },
              child: Text('Use Result'),
            ),
          ],
        ),
      );
    }
  }

  void toggleTorch() {
    controller.toggleTorch();
    setState(() {
      isTorchOn = !isTorchOn;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan Barcode/QR Code'),
        backgroundColor: Colors.blue[700],
        actions: [
          IconButton(
            icon: Icon(isTorchOn ? Icons.flash_on : Icons.flash_off,
                color: isTorchOn ? Colors.yellow : Colors.white),
            onPressed: toggleTorch,
          ),
          IconButton(
            icon: Icon(Icons.cameraswitch),
            onPressed: () => controller.switchCamera(),
          ),
        ],
      ),
      body: MobileScanner(
        controller: controller,
        onDetect: _onDetect,
      ),
    );
  }
}
