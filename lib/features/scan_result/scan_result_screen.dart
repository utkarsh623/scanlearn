import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scan_learn/core/providers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:scan_learn/core/theme/app_theme.dart';

class ScanResultScreen extends ConsumerWidget {
  const ScanResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scan = ref.watch(currentScanProvider);
    if (scan == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Result')),
        body: const Center(child: Text('No scan data found.')),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textDark, size: 20),
            onPressed: () => context.pop(),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.favorite_border_rounded, color: AppTheme.textDark, size: 22),
              onPressed: () {},
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            bottom: MediaQuery.of(context).size.height * 0.4,
            child: scan.imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: scan.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
                    errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.red),
                  )
                : Container(color: Colors.grey.shade200),
          ).animate().fadeIn(duration: 400.ms),

          // Bottom Sheet Content
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.65,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -5))
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              scan.objectName,
                              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                fontSize: 32,
                                height: 1.1,
                              ),
                            ).animate().slideX(begin: -0.1, end: 0, duration: 400.ms).fadeIn(),
                          ),
                          if (scan.category != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                scan.category!,
                                style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                              ),
                            ).animate().scale(delay: 100.ms),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Action Pills
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildActionPill(context, 'Ask AI', Icons.auto_awesome, () => context.push('/ask_ai'), AppTheme.primaryColor),
                            _buildActionPill(context, 'Quiz', Icons.quiz_rounded, () => context.push('/quiz'), Colors.green),
                            _buildActionPill(context, 'Timeline', Icons.timeline_rounded, () => context.push('/timeline'), Colors.orange),
                            _buildActionPill(context, 'Listen', Icons.volume_up_rounded, () {}, Colors.teal),
                          ],
                        ),
                      ).animate().slideX(begin: 0.1, end: 0, delay: 200.ms).fadeIn(),
                      
                      const SizedBox(height: 32),
                      Text(
                        'About this object',
                        style: Theme.of(context).textTheme.titleLarge,
                      ).animate().fadeIn(delay: 300.ms),
                      const SizedBox(height: 12),
                      Text(
                        scan.description ?? 'No description available.',
                        style: const TextStyle(fontSize: 16, height: 1.6, color: AppTheme.textLight),
                      ).animate().fadeIn(delay: 400.ms),

                      const SizedBox(height: 32),
                      if (scan.funFacts != null && scan.funFacts!.isNotEmpty) ...[
                        Text(
                          'Did you know?',
                          style: Theme.of(context).textTheme.titleLarge,
                        ).animate().fadeIn(delay: 500.ms),
                        const SizedBox(height: 16),
                        ...scan.funFacts!.asMap().entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.backgroundLight,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('💡', style: TextStyle(fontSize: 20)),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      entry.value, 
                                      style: const TextStyle(fontSize: 15, height: 1.5, color: AppTheme.textDark),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ).animate().slideY(begin: 0.1, end: 0, delay: (600 + (entry.key * 100)).ms).fadeIn();
                        }),
                      ]
                    ],
                  ),
                ),
              ),
            ),
          ).animate().slideY(begin: 1, end: 0, duration: 600.ms, curve: Curves.easeOutQuart),
        ],
      ),
    );
  }

  Widget _buildActionPill(BuildContext context, String label, IconData icon, VoidCallback onTap, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}
