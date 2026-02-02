import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'job_list_screen.dart';
import '../auth/login_screen.dart'; // 🔥 IMPORT LOGIN SCREEN

class MechanicDashboard extends StatelessWidget {
  const MechanicDashboard({super.key});

  Future<String> _getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("email") ?? "Mechanic";
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // 🔥 Clear full navigation stack and go to Login
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mechanic Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context), // 🔥 FIXED
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            FutureBuilder<String>(
              future: _getName(),
              builder: (context, snapshot) {
                return Text(
                  "Welcome, ${snapshot.data ?? "Mechanic"} 👨‍🔧",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            _card(
              title: "My Job Cards",
              subtitle: "View assigned repair jobs",
              icon: Icons.assignment,
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const JobListScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _card(
              title: "Today's Work",
              subtitle: "Scheduled jobs for today",
              icon: Icons.today,
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const JobListScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _card({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color),
          ),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.arrow_forward_ios),
        ),
      ),
    );
  }
}
