import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../notifications/notification_screen.dart';
import '../../core/services/api_service.dart';

import 'job_list_screen.dart';
import '../auth/login_screen.dart';

class MechanicDashboard extends StatefulWidget {
  const MechanicDashboard({super.key});

  @override
  State<MechanicDashboard> createState() => _MechanicDashboardState();
}

class _MechanicDashboardState extends State<MechanicDashboard> with WidgetsBindingObserver {
  int unreadCount = 0;

  static const Color brandGreen = Color(0xFF00B562);
  static const Color surfaceDark = Color(0xFF1C1C1E);
  static const Color backgroundDark = Color(0xFF121212);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUnreadCount();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadUnreadCount();
    }
  }

  Future<void> _loadUnreadCount() async {
    try {
      final count = await ApiService.getUnreadNotificationCount();
      if (!mounted) return;
      setState(() => unreadCount = count);
    } catch (_) {}
  }

  Future<String> _getName() async {
    final prefs = await SharedPreferences.getInstance();
    // Assuming you store the name, otherwise defaulting to Technician
    return prefs.getString("name") ?? "Technician"; 
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
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
        appBarTheme: const AppBarTheme(backgroundColor: backgroundDark, elevation: 0),
      ),
      child: Scaffold(
        appBar: _buildAppBar(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStaffWelcome(), // 🔥 Unified Dynamic Welcome
              const SizedBox(height: 32),
              _buildSectionLabel("OPERATIONS"),
              const SizedBox(height: 16),
              _buildTaskCard(
                title: "Active Job Cards",
                subtitle: "Vehicles currently in service",
                icon: Icons.engineering_rounded,
                color: brandGreen,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const JobListScreen())),
              ),
              const SizedBox(height: 12),
              _buildTaskCard(
                title: "Queue / Today",
                subtitle: "Scheduled for next 8 hours",
                icon: Icons.calendar_today_rounded,
                color: Colors.blueAccent,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const JobListScreen())),
              ),
              const SizedBox(height: 32),
              _buildSectionLabel("WORKSHOP STATUS"),
              const SizedBox(height: 16),
              _buildInfoSummary(),
            ],
          ),
        ),
      ),
    );
  }

  // ================= UNIFIED BRAND LOGO =================

  AppBar _buildAppBar() {
    return AppBar(
      toolbarHeight: 70,
      backgroundColor: backgroundDark,
      centerTitle: false,
      title: Row(
        children: [
  Stack(
  alignment: Alignment.center,
  children: [
    Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: brandGreen.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: brandGreen.withOpacity(0.1),
            blurRadius: 10,
          )
        ],
      ),
    ),

    // 🔥 App Logo Image
    Image.asset(
      'assets/logo/app_logo.png',
      width: 24,
      height: 24,
      fit: BoxFit.contain,
    ),
  ],
),

          const SizedBox(width: 12),
          const Text(
            "SMART GARAGE", 
            style: TextStyle(
              fontWeight: FontWeight.w900, 
              fontSize: 18, 
              letterSpacing: 2.0, 
              color: Colors.white
            )
          ),
        ],
      ),
      actions: [
        _buildNotificationBadge(),
        IconButton(
          icon: const Icon(Icons.logout_rounded, color: Colors.white38),
          onPressed: () => _logout(context),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // ================= DYNAMIC STAFF WELCOME =================

  Widget _buildStaffWelcome() {
    return FutureBuilder<String>(
      future: _getName(),
      builder: (context, snapshot) {
        final String name = snapshot.data ?? "TECHNICIAN";
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text("Shift started,", 
                  style: TextStyle(color: Colors.white38, fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(width: 6),
                Container(height: 1, width: 20, color: brandGreen.withOpacity(0.4)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              name.toUpperCase(), 
              style: const TextStyle(
                color: Colors.white, 
                fontSize: 28, 
                fontWeight: FontWeight.w900, 
                letterSpacing: 1.2
              )
            ),
          ],
        );
      },
    );
  }

  // ================= UI HELPERS =================

  Widget _buildNotificationBadge() {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded),
          onPressed: () async {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen()));
            _loadUnreadCount();
          },
        ),
        if (unreadCount > 0)
          Positioned(
            right: 8, top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
              constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
              child: Text(
                unreadCount > 99 ? "99+" : unreadCount.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(label,
        style: const TextStyle(
            color: Colors.white24,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0));
  }

  Widget _buildTaskCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          child: Stack(
            children: [
              Positioned(
                left: 0, top: 0, bottom: 0,
                child: Container(width: 5, color: color),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14)),
                      child: Icon(icon, color: color, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          const SizedBox(height: 2),
                          Text(subtitle,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white38)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: brandGreen.withOpacity(0.02),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: brandGreen.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.tips_and_updates_rounded, color: brandGreen, size: 22),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              "Ensure all status transitions are logged for customer transparency.",
              style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}