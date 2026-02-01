import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/services/api_service.dart';
import '../auth/login_screen.dart';

// Screens
import 'admin_users_screen.dart';
import 'admin_garages_screen.dart';
import 'admin_bookings_screen.dart';
import 'admin_audit_screen.dart'; // 🔥 NEW

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int users = 0;
  int garages = 0;
  int bookings = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  // ================= LOAD DASHBOARD DATA =================
  Future<void> _loadStats() async {
    try {
      final u = await ApiService.getAllUsers();
      final g = await ApiService.getAllGaragesAdmin();
      final b = await ApiService.getAllBookingsAdmin();

      if (!mounted) return;

      setState(() {
        users = u.length;
        garages = g.length;
        bookings = b.length;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load admin stats")),
      );
    }
  }

  // ================= LOGOUT =================
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  // ================= DASHBOARD CARD =================
  Widget _card(String title, int value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.toString(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        actions: [
          IconButton(
            tooltip: "Logout",
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _card("Total Users", users, Icons.people, Colors.blue),
                  _card("Total Garages", garages, Icons.store, Colors.orange),
                  _card("Total Bookings", bookings, Icons.book, Colors.green),
                  const SizedBox(height: 24),

                  const Text(
                    "Platform Control Panel",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ================= USERS =================
                  ListTile(
                    leading: const Icon(Icons.people),
                    title: const Text("View Users"),
                    trailing:
                        const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const AdminUsersScreen(),
                        ),
                      );
                    },
                  ),

                  // ================= GARAGES =================
                  ListTile(
                    leading: const Icon(Icons.store),
                    title: const Text("Manage Garages"),
                    trailing:
                        const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const AdminGaragesScreen(),
                        ),
                      );
                    },
                  ),

                  // ================= BOOKINGS =================
                  ListTile(
                    leading: const Icon(Icons.book),
                    title: const Text("View Bookings"),
                    trailing:
                        const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const AdminBookingsScreen(),
                        ),
                      );
                    },
                  ),

                  // ================= AUDIT LOGS =================
                  ListTile(
                    leading: const Icon(Icons.security),
                    title: const Text("Audit Logs"),
                    trailing:
                        const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const AdminAuditScreen(),
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
