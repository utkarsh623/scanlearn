import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scan_learn/core/providers.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:scan_learn/core/theme/app_theme.dart';

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
      
      ref.read(currentScanProvider.notifier).state = scan;
      if (mounted) context.push('/scan_result');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
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
        body: Center(
          child: Text(
            'Camera not accessible',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
          onPressed: () => context.pop(),
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
          ).animate().fadeIn(duration: 400.ms),

          // 2. Clean Minimalist Scanning Reticle
          if (!_isAnalyzing)
            Positioned.fill(
              child: CustomPaint(
                painter: CleanScannerOverlayPainter(),
              ),
            ).animate().fade(duration: 800.ms),

          // 3. Analyzing State (Clean solid overlay)
          if (_isAnalyzing)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.7),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: 24),
                    Text(
                      'Analyzing Object...',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ).animate().slideY(begin: 0.2, end: 0).fadeIn(),
                  ],
                ),
              ),
            ),

          // 4. Bottom Controls
          if (!_isAnalyzing)
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Gallery Button
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.photo_library_rounded, color: Colors.white),
                      onPressed: _pickGallery,
                    ),
                  ),

                  // Capture Button
                  GestureDetector(
                    onTap: _capture,
                    child: Container(
                      height: 72,
                      width: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        color: Colors.transparent,
                      ),
                      child: Center(
                        child: Container(
                          height: 56,
                          width: 56,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ).animate().scale(delay: 200.ms, curve: Curves.easeOutQuart),

                  // Empty spacer for layout balance
                  const SizedBox(width: 56),
                ],
              ),
            )
        ],
      ),
    );
  }
}

// Custom painter for a clean, professional reticle
class CleanScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final length = 30.0;
    final padding = 50.0;
    
    // Top Left
    canvas.drawLine(Offset(padding, padding), Offset(padding + length, padding), paint);
    canvas.drawLine(Offset(padding, padding), Offset(padding, padding + length), paint);

    // Top Right
    canvas.drawLine(Offset(size.width - padding, padding), Offset(size.width - padding - length, padding), paint);
    canvas.drawLine(Offset(size.width - padding, padding), Offset(size.width - padding, padding + length), paint);

    // Bottom Left
    canvas.drawLine(Offset(padding, size.height - padding), Offset(padding + length, size.height - padding), paint);
    canvas.drawLine(Offset(padding, size.height - padding), Offset(padding, size.height - padding - length), paint);

    // Bottom Right
    canvas.drawLine(Offset(size.width - padding, size.height - padding), Offset(size.width - padding - length, size.height - padding), paint);
    canvas.drawLine(Offset(size.width - padding, size.height - padding), Offset(size.width - padding, size.height - padding - length), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
