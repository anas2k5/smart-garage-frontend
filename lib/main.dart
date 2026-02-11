import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'core/utils/role_navigator.dart';
import 'features/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔑 Only set key here (no await)
  Stripe.publishableKey =
      "pk_test_51SqA0WCFdVOc1RqKtPuGO3tGbPzkGgubwYl4xZlyA9yz6UptMJcn4RuPWuIk2T68AKGZYCylfibF5UsvpBiybvG900dD2XTe6S";

  runApp(const SmartGarageApp());
}

class SmartGarageApp extends StatelessWidget {
  const SmartGarageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StartupLoader(),
    );
  }
}

/// 🚀 Startup Loader
class StartupLoader extends StatefulWidget {
  const StartupLoader({super.key});

  @override
  State<StartupLoader> createState() => _StartupLoaderState();
}

class _StartupLoaderState extends State<StartupLoader> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // 🔥 Initialize Stripe safely AFTER UI loads
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

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => nextScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
