import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/login_screen.dart';
import '../../core/utils/role_navigator.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  static const Color brandGreen = Color(0xFF00B562);

  @override
  void initState() {
    super.initState();

    // 🔥 Premium Cinematic Animation Setup
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeIn)),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
    _initApp();
  }

  Future<void> _initApp() async {
    // Hold the splash for 3.5 seconds to let the animation finish smoothly
    await Future.delayed(const Duration(milliseconds: 3500));

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final role = prefs.getString('role');

    if (!mounted) return;

    if (token != null && role != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => RoleNavigator.getHomeByRole(role)),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Subtle background glow
          Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: brandGreen.withOpacity(0.05),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: _buildPremiumLogo(),
                  ),
                );
              },
            ),
          ),
          
          // Bottom Tagline
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  const Text(
                    "ELITE AUTOMOTIVE NETWORK",
                    style: TextStyle(
                      color: Colors.white24,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 40,
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.white10,
                      color: brandGreen.withOpacity(0.5),
                      minHeight: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildPremiumLogo() {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      // 🏎️ APP LOGO EMBLEM
      Stack(
        alignment: Alignment.center,
        children: [
          // Outer Ring
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: brandGreen.withOpacity(0.1),
                width: 1,
              ),
            ),
          ),

          // Inner Glow Core
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.03),
              boxShadow: [
                BoxShadow(
                  color: brandGreen.withOpacity(0.2),
                  blurRadius: 40,
                  spreadRadius: 5,
                )
              ],
            ),
          ),

          // 🔥 YOUR IMAGE LOGO (Animated automatically)
          Image.asset(
            'assets/logo/app_logo.png',
            width: 70,
            height: 70,
            fit: BoxFit.contain,
          ),
        ],
      ),

      const SizedBox(height: 32),

      // Brand Text
      const Text(
        "SMART GARAGE",
        style: TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.w900,
          letterSpacing: 8,
        ),
      ),

      const SizedBox(height: 12),

      // Tagline
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 30, height: 1, color: brandGreen),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "PRECISION HUB",
              style: TextStyle(
                color: brandGreen,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
              ),
            ),
          ),
          Container(width: 30, height: 1, color: brandGreen),
        ],
      ),
    ],
  );
}
