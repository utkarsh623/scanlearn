import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scan_learn/core/providers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:scan_learn/core/theme/app_theme.dart';

class ScanResultScreen extends ConsumerStatefulWidget {
  const ScanResultScreen({super.key});

  @override
  ConsumerState<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends ConsumerState<ScanResultScreen> {
  @override
  void dispose() {
    ref.read(ttsProvider).stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scan = ref.watch(currentScanProvider);
    if (scan == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Result')),
        body: const Center(child: Text('No scan data found.')),
      );
    }

    return PopScope(
      onPopInvoked: (didPop) {
        ref.read(ttsProvider).stop();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _buildGlassIconButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: () {
            ref.read(ttsProvider).stop();
            context.pop();
          },
        ),
        actions: [
          _buildGlassIconButton(
            icon: Icons.favorite_border_rounded,
            onTap: () {},
          ).padding(const EdgeInsets.only(right: 8)),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Stack(
            children: [
              // Premium Background Image with Parallax and Gradient Fade
              Positioned.fill(
                bottom: MediaQuery.of(context).size.height * 0.45,
                child: scan.imageUrl.isNotEmpty
                    ? (scan.imageUrl.startsWith('http')
                        ? CachedNetworkImage(
                            imageUrl: scan.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(color: Colors.white),
                            ),
                            errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white),
                          )
                        : Image.file(
                            File(scan.imageUrl),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, color: Colors.white),
                          ))
                    : Container(
                        color: AppTheme.primaryColor,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image_not_supported_rounded, size: 80, color: Colors.white.withOpacity(0.5)),
                              const SizedBox(height: 16),
                              Text(
                                'No Image Captured',
                                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
              ).animate().fadeIn(duration: 800.ms).scale(begin: const Offset(1.1, 1.1), end: const Offset(1, 1), duration: 1000.ms, curve: Curves.easeOutCubic),

              // Gradient Overlay to blend image into the sheet seamlessly
              Positioned.fill(
                bottom: MediaQuery.of(context).size.height * 0.45,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.transparent,
                        Theme.of(context).scaffoldBackgroundColor.withOpacity(0.0),
                        Theme.of(context).scaffoldBackgroundColor,
                      ],
                      stops: const [0.0, 0.3, 0.7, 1.0],
                    ),
                  ),
                ),
              ),

              // Sliding Bottom Content Sheet
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.55,
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and Category
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Text(
                                scan.objectName,
                                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w800,
                                  height: 1.1,
                                  letterSpacing: -0.5,
                                  color: Theme.of(context).textTheme.displayLarge?.color,
                                ),
                              ).animate().slideX(begin: -0.1, end: 0, duration: 500.ms, curve: Curves.easeOutQuart).fadeIn(),
                            ),
                            if (scan.category != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [AppTheme.primaryColor, Color(0xFF536DFE)],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryColor.withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    )
                                  ]
                                ),
                                child: Text(
                                  scan.category!.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white, 
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ).animate().scale(delay: 200.ms, curve: Curves.easeOutBack),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // Beautiful Action Pills
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          clipBehavior: Clip.none,
                          child: Row(
                            children: [
                              _buildPremiumActionPill(context, 'Listen', Icons.volume_up_rounded, () async {
                                final tts = ref.read(ttsProvider);
                                await tts.speak(scan.description ?? 'No description to read.');
                              }, AppTheme.primaryColor, 0),
                              _buildPremiumActionPill(context, 'Ask AI', Icons.auto_awesome, () => context.push('/ask_ai'), AppTheme.primaryColor, 100),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 36),
                        
                        // Description Section
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardTheme.color,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Theme.of(context).dividerColor, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              )
                            ]
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'About',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.3,
                                      color: Theme.of(context).textTheme.titleLarge?.color,
                                      fontSize: 22,
                                    ),
                                  ),
                                ],
                              ).animate().fadeIn(delay: 300.ms),
                              const SizedBox(height: 16),
                              Text(
                                scan.description ?? 'No description available.',
                                style: TextStyle(
                                  fontSize: 16, 
                                  height: 1.7, 
                                  color: Theme.of(context).textTheme.bodyMedium?.color,
                                  fontWeight: FontWeight.w400,
                                ),
                              ).animate().fadeIn(delay: 400.ms),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),
                        
                        // Fun Facts Section
                        if (scan.funFacts != null && scan.funFacts!.isNotEmpty) ...[
                          Row(
                            children: [
                              Container(
                                width: 4,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF9A3C),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Did you know?',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                  color: Theme.of(context).textTheme.titleLarge?.color,
                                  fontSize: 22,
                                ),
                              ),
                            ],
                          ).animate().fadeIn(delay: 500.ms),
                          const SizedBox(height: 20),
                          ...scan.funFacts!.asMap().entries.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardTheme.color,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: Theme.of(context).dividerColor, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    )
                                  ]
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.surface,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFFF9A3C).withOpacity(0.2),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          )
                                        ]
                                      ),
                                      child: const Text('💡', style: TextStyle(fontSize: 18)),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 6.0),
                                        child: Text(
                                          entry.value, 
                                          style: TextStyle(
                                            fontSize: 15, 
                                            height: 1.6, 
                                            color: Theme.of(context).textTheme.bodyMedium?.color,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ).animate()
                             .slideY(begin: 0.2, end: 0, delay: (600 + (entry.key * 100)).ms, curve: Curves.easeOutQuart)
                             .fadeIn();
                          }),
                        ]
                      ],
                    ),
                  ),
                ),
              ).animate().slideY(begin: 1, end: 0, duration: 800.ms, curve: Curves.easeOutQuart),
            ],
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildGlassIconButton({required IconData icon, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.all(8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color: Colors.black.withOpacity(0.2),
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumActionPill(BuildContext context, String label, IconData icon, VoidCallback onTap, Color color, int delayMs) {
    return Padding(
      padding: const EdgeInsets.only(right: 14.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          splashColor: color.withOpacity(0.1),
          highlightColor: color.withOpacity(0.05),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: color.withOpacity(0.1), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  label, 
                  style: TextStyle(
                    fontWeight: FontWeight.w700, 
                    fontSize: 15,
                    color: color.withOpacity(0.9),
                    letterSpacing: -0.2,
                  )
                ),
              ],
            ),
          ),
        ),
      ).animate().slideX(begin: 0.1, end: 0, delay: delayMs.ms, curve: Curves.easeOutQuart).fadeIn(),
    );
  }
}

extension PaddingExtension on Widget {
  Widget padding(EdgeInsets padding) => Padding(padding: padding, child: this);
}

