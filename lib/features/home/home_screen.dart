import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:scan_learn/core/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('ScanLearn'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, size: 28),
            onPressed: () => context.push('/profile'),
          ).animate().fadeIn().scale(),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                'Explore the\nWorld Around You',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 32,
                  height: 1.2,
                ),
              ).animate().slideY(begin: -0.1, end: 0, duration: 600.ms, curve: Curves.easeOut).fadeIn(),
              const SizedBox(height: 32),
              
              // Big Scan Button (Clean Style)
              GestureDetector(
                onTap: () => context.push('/camera'),
                child: Container(
                  width: double.infinity,
                  height: 160,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -30,
                        bottom: -30,
                        child: Icon(Icons.center_focus_strong, size: 160, color: Colors.white.withOpacity(0.1))
                            .animate(onPlay: (controller) => controller.repeat(reverse: true))
                            .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 2.seconds),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 36),
                            const Spacer(),
                            const Text(
                              'Scan Object',
                              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Tap to open camera',
                              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().scale(delay: 100.ms, curve: Curves.easeOutBack),
              ),
              
              const SizedBox(height: 32),
              Text(
                'Your Library',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 16),
              
              // Grid of smaller actions (Clean Style)
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildGridCard(
                      context,
                      title: 'History',
                      icon: Icons.history_rounded,
                      color: AppTheme.primaryColor,
                      onTap: () => context.push('/history'),
                      delay: 300,
                    ),
                    _buildGridCard(
                      context,
                      title: 'Favorites',
                      icon: Icons.favorite_rounded,
                      color: Colors.pink,
                      onTap: () => context.push('/favorites'),
                      delay: 400,
                    ),
                    _buildGridCard(
                      context,
                      title: 'Collections',
                      icon: Icons.collections_bookmark_rounded,
                      color: Colors.teal,
                      onTap: () => context.push('/collections'),
                      delay: 500,
                    ),
                    _buildGridCard(
                      context,
                      title: 'Daily Quiz',
                      icon: Icons.quiz_rounded,
                      color: Colors.orange,
                      onTap: () {}, // To be linked later
                      delay: 600,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridCard(BuildContext context, {required String title, required IconData icon, required Color color, required VoidCallback onTap, required int delay}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppTheme.softShadow,
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ],
          ),
        ),
      ).animate().scale(delay: delay.ms, curve: Curves.easeOutQuart).fadeIn(),
    );
  }
}
