import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _loadingController;
  late Animation<double> _progressAnimation;

  // DigiLocker Theme Colors
  final Color primaryPurple = const Color(0xFF613EEA);
  final Color textDark = const Color(0xFF2E2E4E);

  @override
  void initState() {
    super.initState();

    // 1. Initialize Controller for the Loading Bar
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500), // Time for bar to fill
    );

    // 2. Define the Progress Animation (from 0 to 1.0 width)
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.easeInOut),
    );

    // 3. Start the progress bar
    _loadingController.forward();

    _navigate();
  }

  void _navigate() {
    // Navigate once the bar is full (matching the controller duration)
    Timer(const Duration(milliseconds: 3000), () {
      if (mounted) {
        context.go('/login');
      }
    });
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. Centered Brand Identity (Logo + Name + Tagline)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Icon
                Icon(
                  Icons.description_rounded, // Document-style icon
                  size: 50,
                  color: primaryPurple,
                ),
                const SizedBox(width: 12),
                // App Name
                Text(
                  "DocKeys",
                  style: TextStyle(
                    fontSize: 34,
                    color: textDark,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Tagline underneath (matching Image 1 & 4)
            Text(
              "Your documents anytime, anywhere",
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 24),

            // 2. Animated Loading Bar (Matching Image 1 & 4)
            Container(
              width: 180, // Fixed width for the bar
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 180 * _progressAnimation.value,
                      height: 4,
                      decoration: BoxDecoration(
                        color: primaryPurple,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}