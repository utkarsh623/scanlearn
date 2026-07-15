import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scan_learn/core/providers.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:scan_learn/core/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String _error = '';

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final supabase = Supabase.instance.client;
      await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (mounted) context.go('/home');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGuestLogin() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final supabase = Supabase.instance.client;
      await supabase.auth.signInAnonymously();
      if (mounted) context.go('/home');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppTheme.softShadow,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Logo & Title
                  Image.asset(
                    'assets/images/images/img4.png',
                    height: 80,
                  ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                  const SizedBox(height: 24),
                  Text(
                    'Welcome to ScanLearn',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontSize: 28,
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to access your educational tools.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 32),
                  
                  // Form Fields
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0),
                  
                  if (_error.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      _error,
                      style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 14),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(),
                  ],
                  
                  const SizedBox(height: 32),
                  
                  // Buttons
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ElevatedButton(
                              onPressed: _handleLogin,
                              child: const Text('Sign In'),
                            ).animate().fadeIn(delay: 600.ms),
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: _handleGuestLogin,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                side: BorderSide(color: Colors.grey.shade300),
                                foregroundColor: AppTheme.textDark,
                              ),
                              child: const Text('Continue as Guest'),
                            ).animate().fadeIn(delay: 700.ms),
                          ],
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
