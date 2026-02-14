import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'core/utils/role_navigator.dart';
import 'features/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔑 Stripe Configuration
  Stripe.publishableKey = "pk_test_51SqA0WCFdVOc1RqKtPuGO3tGbPzkGgubwYl4xZlyA9yz6UptMJcn4RuPWuIk2T68AKGZYCylfibF5UsvpBiybvG900dD2XTe6S";

  runApp(const SmartGarageApp());
}

class SmartGarageApp extends StatelessWidget {
  const SmartGarageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Garage',
      theme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFF00B562),
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const StartupLoader(),
    );
  }
}

class StartupLoader extends StatefulWidget {
  const StartupLoader({super.key});

  @override
  State<StartupLoader> createState() => _StartupLoaderState();
}

class _StartupLoaderState extends State<StartupLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  static const Color brandGreen = Color(0xFF00B562);

  @override
  void initState() {
    super.initState();

    // 🎬 Cinematic Animation Controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.8, curve: Curves.easeIn)),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // 🔥 Background Stripe Settings Init
    await Stripe.instance.applySettings();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final role = prefs.getString('role');
    final userId = prefs.getInt('userId');

    Widget nextScreen;

    if (token == null || role == null || userId == null) {
      await prefs.clear();
      nextScreen = const LoginScreen();
    } else {
      nextScreen = RoleNavigator.getHomeByRole(role);
    }

    // ⏳ Ensure the premium animation has time to shine
    await Future.delayed(const Duration(milliseconds: 3000));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
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
        alignment: Alignment.center,
        children: [
          // 1. Subtle Radial Background Glow
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.8,
                colors: [
                  brandGreen.withOpacity(0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          
          // 2. Main Animated Content
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildPremiumStackedLogo(),
                      const SizedBox(height: 40),
                      const SizedBox(
                        width: 40,
                        height: 2,
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.white10,
                          color: brandGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
Widget _buildPremiumStackedLogo() {
  return Column(
    children: [
      Stack(
        alignment: Alignment.center,
        children: [
          // Outer Glowing Ring
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: brandGreen.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: brandGreen.withOpacity(0.15),
                  blurRadius: 40,
                  spreadRadius: 5,
                )
              ],
            ),
          ),

          // Mechanical Core
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.03),
              border: Border.all(color: Colors.white10, width: 0.5),
            ),
          ),

          // 🔥 YOUR IMAGE LOGO
          Image.asset(
            'assets/logo/app_logo.png',
            width: 70,
            height: 70,
            fit: BoxFit.contain,
          ),
        ],
      ),

      const SizedBox(height: 32),

      const Text(
        "SMART GARAGE",
        style: TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.w900,
          letterSpacing: 8,
        ),
      ),

      const SizedBox(height: 12),

      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 24, height: 1, color: brandGreen.withOpacity(0.5)),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "PRECISION HUB",
              style: TextStyle(
                color: brandGreen,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
              ),
            ),
          ),
          Container(width: 24, height: 1, color: brandGreen.withOpacity(0.5)),
        ],
      ),
    ],
  );
}
}