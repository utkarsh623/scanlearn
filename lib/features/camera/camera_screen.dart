import 'dart:ui';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scan_learn/core/providers.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  CameraController? _controller;
  bool _isInitializing = true;
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
      _controller = CameraController(cameras.first, ResolutionPreset.max, enableAudio: false);
      await _controller!.initialize();
    } catch (e) {
      debugPrint('Camera error: $e');
    } finally {
      if (mounted) setState(() => _isInitializing = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _processImage(XFile file) async {
    setState(() => _isAnalyzing = true);
    try {
      final repo = ref.read(scanRepositoryProvider);
      final scan = await repo.processAndSaveScan(file);
      
      ref.invalidate(scanHistoryProvider);
      ref.read(currentScanProvider.notifier).state = scan;
      if (mounted) context.push('/scan_result');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text('Error: ${e.toString()}', style: const TextStyle(color: Colors.white)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  Future<void> _capture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      final xFile = await _controller!.takePicture();
      final compressed = await ref.read(cameraServiceProvider).compressImage(xFile);
      await _processImage(compressed);
    } catch (e) {
      debugPrint('Capture error: $e');
    }
  }

  Future<void> _pickGallery() async {
    try {
      final file = await ref.read(cameraServiceProvider).pickFromGallery();
      if (file != null) {
        await _processImage(file);
      }
    } catch (e) {
      debugPrint('Gallery error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator(color: Colors.white)));
    }

    if (_controller == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(backgroundColor: Colors.black, iconTheme: const IconThemeData(color: Colors.white)),
        body: const Center(child: Text('Camera not accessible', style: TextStyle(color: Colors.white, fontSize: 18))),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.black.withOpacity(0.2),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // 1. Camera View
          Positioned.fill(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller!.value.previewSize?.height ?? 1,
                height: _controller!.value.previewSize?.width ?? 1,
                child: CameraPreview(_controller!),
              ),
            ),
          ),

          // 2. Simple Overlay
          if (!_isAnalyzing)
            Positioned.fill(
              child: CustomPaint(
                painter: SimpleScannerOverlayPainter(),
              ),
            ),

          // 3. Analyzing State
          if (_isAnalyzing)
            Positioned.fill(
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const CircularProgressIndicator(color: Colors.white),
                        ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                        const SizedBox(height: 32),
                        const Text(
                          'Identifying Object...',
                          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                        const SizedBox(height: 8),
                        Text(
                          'Powered by Google ML Kit',
                          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14, fontWeight: FontWeight.w500),
                        ).animate().fadeIn(delay: 400.ms),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // 4. Bottom Controls (Glassmorphic)
          if (!_isAnalyzing)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    padding: const EdgeInsets.only(top: 24, bottom: 48),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Gallery Button
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            iconSize: 28,
                            padding: const EdgeInsets.all(16),
                            icon: const Icon(Icons.photo_library_rounded, color: Colors.white),
                            onPressed: _pickGallery,
                          ),
                        ),

                        // Capture Button
                        GestureDetector(
                          onTap: _capture,
                          child: Container(
                            height: 80,
                            width: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withOpacity(0.5), width: 4),
                              color: Colors.transparent,
                            ),
                            child: Center(
                              child: Container(
                                height: 64,
                                width: 64,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 60), // spacer for symmetry
                      ],
                    ),
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}

class SimpleScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Dimmed background
    final bgPaint = Paint()..color = Colors.black.withOpacity(0.4);
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    
    // Clear the center area
    final scanAreaSize = size.width * 0.7;
    final rRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(size.width / 2, size.height * 0.45), width: scanAreaSize, height: scanAreaSize),
      const Radius.circular(24)
    );
    
    canvas.saveLayer(rect, Paint());
    canvas.drawRect(rect, bgPaint);
    canvas.drawRRect(rRect, Paint()..blendMode = BlendMode.clear);
    canvas.restore();

    // Draw scanning corners
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final length = 40.0;
    
    // Top Left
    canvas.drawPath(Path()..moveTo(rRect.left, rRect.top + length)..lineTo(rRect.left, rRect.top)..lineTo(rRect.left + length, rRect.top), paint);
    // Top Right
    canvas.drawPath(Path()..moveTo(rRect.right - length, rRect.top)..lineTo(rRect.right, rRect.top)..lineTo(rRect.right, rRect.top + length), paint);
    // Bottom Left
    canvas.drawPath(Path()..moveTo(rRect.left, rRect.bottom - length)..lineTo(rRect.left, rRect.bottom)..lineTo(rRect.left + length, rRect.bottom), paint);
    // Bottom Right
    canvas.drawPath(Path()..moveTo(rRect.right - length, rRect.bottom)..lineTo(rRect.right, rRect.bottom)..lineTo(rRect.right, rRect.bottom - length), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
