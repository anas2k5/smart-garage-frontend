import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/utils/role_navigator.dart';
import 'features/auth/login_screen.dart';
import 'package:flutter_stripe/flutter_stripe.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Stripe.publishableKey = "pk_test_51SqA0WCFdVOc1RqKtPuGO3tGbPzkGgubwYl4xZlyA9yz6UptMJcn4RuPWuIk2T68AKGZYCylfibF5UsvpBiybvG900dD2XTe6S";
  runApp(const SmartGarageApp());
}

class SmartGarageApp extends StatelessWidget {
  const SmartGarageApp({super.key});

  Future<Widget> _getStartScreen() async {
  final prefs = await SharedPreferences.getInstance();

  final token = prefs.getString('token');
  final role = prefs.getString('role');
  final userId = prefs.getInt('userId');

  // ✅ STRICT validation
  if (token == null || role == null || userId == null) {
    await prefs.clear(); // 🔥 prevent stuck state
    return const LoginScreen();
  }

  return RoleNavigator.getHomeByRole(role);
}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<Widget>(
        future: _getStartScreen(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return snapshot.data!;
        },
      ),
    );
  }
}
