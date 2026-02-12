import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/services/api_service.dart';
import '../auth/login_screen.dart';
import '../notifications/notification_screen.dart';

// Screens
import 'admin_users_screen.dart';
import 'admin_garages_screen.dart';
import 'admin_bookings_screen.dart';
import 'admin_audit_screen.dart';

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

  // Global Brand Palette
  static const Color brandGreen = Color(0xFF00B562);
  static const Color surfaceDark = Color(0xFF1C1C1E);
  static const Color backgroundDark = Color(0xFF121212);

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

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
        const SnackBar(backgroundColor: Colors.redAccent, content: Text("Platform sync failed")),
      );
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: surfaceDark,
        title: const Text("Terminate Session?"),
        content: const Text("You will need to re-authenticate to access the Control Panel."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Logout"),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        useMaterial3: true,
        scaffoldBackgroundColor: backgroundDark,
        appBarTheme: const AppBarTheme(backgroundColor: backgroundDark, elevation: 0, centerTitle: true),
      ),
      child: Scaffold(
       appBar: AppBar(
  title: const Text(
    "SYSTEM CONTROL",
    style: TextStyle(
      fontWeight: FontWeight.w900,
      fontSize: 16,
      letterSpacing: 2,
      color: brandGreen,
    ),
  ),
  actions: [

    // 🔔 NOTIFICATIONS
    IconButton(
      icon: const Icon(Icons.notifications_none_rounded),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const NotificationScreen(),
          ),
        );
      },
    ),

    // 🚪 LOGOUT
    IconButton(
      icon: const Icon(
        Icons.power_settings_new_rounded,
        color: Colors.white38,
      ),
      onPressed: _logout,
    ),
  ],
),

        body: RefreshIndicator(
          color: brandGreen,
          onRefresh: _loadStats,
          child: loading
              ? const Center(child: CircularProgressIndicator(color: brandGreen))
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildGlobalHeader(),
                    const SizedBox(height: 24),
                    _buildSectionLabel("LIVE METRICS"),
                    const SizedBox(height: 16),
                    _statCard(
                      title: "Total Registered Users",
                      value: users,
                      icon: Icons.badge_rounded,
                      color: Colors.blueAccent,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminUsersScreen())),
                    ),
                    const SizedBox(height: 12),
                    _statCard(
                      title: "Active Garage Branches",
                      value: garages,
                      icon: Icons.garage_rounded,
                      color: Colors.orangeAccent,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminGaragesScreen())),
                    ),
                    const SizedBox(height: 12),
                    _statCard(
                      title: "Processed Bookings",
                      value: bookings,
                      icon: Icons.analytics_rounded,
                      color: brandGreen,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminBookingsScreen())),
                    ),
                    const SizedBox(height: 32),
                    _buildSectionLabel("PLATFORM MANAGEMENT"),
                    const SizedBox(height: 16),
                    _menuTile(
                      icon: Icons.manage_accounts_rounded,
                      title: "User Management",
                      subtitle: "Access control and role distribution",
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminUsersScreen())),
                    ),
                    _menuTile(
                      icon: Icons.storefront_rounded,
                      title: "Garage Oversight",
                      subtitle: "Audit workshop status and approvals",
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminGaragesScreen())),
                    ),
                    _menuTile(
                      icon: Icons.monitor_heart_rounded,
                      title: "Traffic Monitor",
                      subtitle: "Global booking flow analytics",
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminBookingsScreen())),
                    ),
                    _menuTile(
                      icon: Icons.security_update_good_rounded,
                      title: "Audit & Security",
                      subtitle: "System logs and administrative actions",
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminAuditScreen())),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildGlobalHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: brandGreen.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: brandGreen.withOpacity(0.1),
            child: const Icon(Icons.shield_rounded, color: brandGreen, size: 30),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("SUPER USER ACCESS", 
                  style: TextStyle(color: brandGreen, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                Text("Platform Overview", 
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(label, 
      style: const TextStyle(color: Colors.white24, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5));
  }

  Widget _statCard({
    required String title,
    required int value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 13, color: Colors.white38, fontWeight: FontWeight.w500)),
                    Text(value.toString(), 
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: brandGreen.withOpacity(0.05), shape: BoxShape.circle),
          child: Icon(icon, color: brandGreen, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white30, fontSize: 12)),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white10),
        onTap: onTap,
      ),
    );
  }
}