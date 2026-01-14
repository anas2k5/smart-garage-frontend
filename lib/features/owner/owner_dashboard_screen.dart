import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_garage_app/features/auth/login_screen.dart';
import 'owner_garages_screen.dart';
import 'add_garage_screen.dart'; // ✅ NEW

class OwnerDashboardScreen extends StatelessWidget {
  const OwnerDashboardScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Owner Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Welcome Owner 👋",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),

            ElevatedButton.icon(
              icon: const Icon(Icons.garage),
              label: const Text("My Garages"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const OwnerGaragesScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            // ✅ ADD GARAGE BUTTON
            ElevatedButton.icon(
              icon: const Icon(Icons.add_business),
              label: const Text("Add Garage"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddGarageScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
