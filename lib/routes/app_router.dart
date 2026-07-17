import 'package:go_router/go_router.dart';
import 'package:scan_learn/features/auth/splash_screen.dart';
import 'package:scan_learn/features/auth/login_screen.dart';
import 'package:scan_learn/features/home/home_screen.dart';
import 'package:scan_learn/features/camera/camera_screen.dart';
import 'package:scan_learn/features/scan_result/scan_result_screen.dart';
import 'package:scan_learn/features/history/history_screen.dart';
import 'package:scan_learn/features/tutorial/tutorial_screen.dart';
import 'package:scan_learn/features/ask_ai/ask_ai_screen.dart';
import 'package:scan_learn/features/ask_ai/ask_ai_screen.dart';
import 'package:scan_learn/features/profile/profile_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/camera',
      builder: (context, state) => const CameraScreen(),
    ),
    GoRoute(
      path: '/scan_result',
      builder: (context, state) => const ScanResultScreen(),
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const HistoryScreen(),
    ),
    GoRoute(
      path: '/tutorial',
      builder: (context, state) => const TutorialScreen(),
    ),

    GoRoute(
      path: '/ask_ai',
      builder: (context, state) => const AskAiScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
);
