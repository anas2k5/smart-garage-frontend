import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../notifications/notification_screen.dart';
import '../../core/services/api_service.dart';

import 'job_list_screen.dart';
import '../auth/login_screen.dart';

class MechanicDashboard extends StatefulWidget {
  const MechanicDashboard({super.key});

  @override
  State<MechanicDashboard> createState() =>
      _MechanicDashboardState();
}

class _MechanicDashboardState
    extends State<MechanicDashboard>
    with WidgetsBindingObserver {

  // 🔔 UNREAD COUNT
  int unreadCount = 0;

  // Global Brand Palette
  static const Color brandGreen = Color(0xFF00B562);
  static const Color surfaceDark = Color(0xFF1C1C1E);
  static const Color backgroundDark = Color(0xFF121212);

  // ================= LOAD COUNT =================
  Future<void> _loadUnreadCount() async {
    try {
      final count =
          await ApiService.getUnreadNotificationCount();

      if (!mounted) return;

      setState(() {
        unreadCount = count;
      });
    } catch (_) {}
  }

  // ================= LIFECYCLE =================
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
  void didChangeAppLifecycleState(
      AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadUnreadCount();
    }
  }

  // ================= YOUR ORIGINAL METHODS =================

  Future<String> _getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("email") ?? "Technician";
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        useMaterial3: true,
        scaffoldBackgroundColor: backgroundDark,
        appBarTheme: const AppBarTheme(
          backgroundColor: backgroundDark,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "SERVICE HUB",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              letterSpacing: 2,
              color: brandGreen,
            ),
          ),
          actions: [

            // 🔔 NOTIFICATIONS WITH BADGE
            Stack(
              children: [

                // ✅ Tooltip Added
                IconButton(
                  tooltip: "Notifications",
                  icon: const Icon(
                      Icons.notifications_none_rounded),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const NotificationScreen(),
                      ),
                    );

                    _loadUnreadCount();
                  },
                ),

                // 🔴 BADGE
                if (unreadCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding:
                          const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                      constraints:
                          const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(

                        // ✅ 99+ LIMIT ADDED
                        unreadCount > 99
                            ? "99+"
                            : unreadCount.toString(),

                        style:
                            const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight:
                              FontWeight.bold,
                        ),
                        textAlign:
                            TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),

            // 🚪 LOGOUT
            IconButton(
              icon: const Icon(
                Icons.logout_rounded,
                color: Colors.white38,
              ),
              onPressed: () =>
                  _logout(context),
            ),
          ],
        ),

        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
              horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _buildStaffProfile(),
              const SizedBox(height: 32),
              _buildSectionLabel("OPERATIONS"),
              const SizedBox(height: 16),
              _buildTaskCard(
                title: "Active Job Cards",
                subtitle:
                    "Vehicles currently in service",
                icon:
                    Icons.engineering_rounded,
                color: brandGreen,
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              const JobListScreen()));
                },
              ),
              const SizedBox(height: 12),
              _buildTaskCard(
                title: "Queue / Today",
                subtitle:
                    "Scheduled for next 8 hours",
                icon:
                    Icons.calendar_today_rounded,
                color: Colors.blueAccent,
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              const JobListScreen()));
                },
              ),
              const SizedBox(height: 32),
              _buildSectionLabel(
                  "WORKSHOP STATUS"),
              const SizedBox(height: 16),
              _buildInfoSummary(),
            ],
          ),
        ),
      ),
    );
  }

  // ================= UI WIDGETS =================

  Widget _buildStaffProfile() {
    return FutureBuilder<String>(
      future: _getName(),
      builder: (context, snapshot) {
        return Container(
          padding:
              const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: surfaceDark,
            borderRadius:
                BorderRadius.circular(24),
            border: Border.all(
                color: brandGreen
                    .withOpacity(0.1)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor:
                    brandGreen.withOpacity(0.1),
                child: const Icon(
                    Icons.person_pin_rounded,
                    color: brandGreen,
                    size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "LOGGED IN AS",
                      style: TextStyle(
                          color: brandGreen,
                          fontSize: 11,
                          fontWeight:
                              FontWeight.bold,
                          letterSpacing: 1),
                    ),
                    Text(
                      snapshot.data ??
                          "Mechanic",
                      style:
                          const TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.w900,
                        color: Colors.white,
                      ),
                      overflow:
                          TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionLabel(
      String label) {
    return Text(label,
        style: const TextStyle(
            color: Colors.white24,
            fontSize: 12,
            fontWeight:
                FontWeight.bold,
            letterSpacing: 1.5));
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
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
            color: Colors.white
                .withOpacity(0.05)),
      ),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding:
              const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: color
                        .withOpacity(0.1),
                    borderRadius:
                        BorderRadius
                            .circular(14)),
                child: Icon(icon,
                    color: color,
                    size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style:
                            const TextStyle(
                                fontSize: 15,
                                fontWeight:
                                    FontWeight
                                        .bold,
                                color: Colors
                                    .white)),
                    const SizedBox(
                        height: 2),
                    Text(subtitle,
                        style:
                            const TextStyle(
                                fontSize: 12,
                                color: Colors
                                    .white38)),
                  ],
                ),
              ),
              const Icon(
                  Icons
                      .arrow_forward_ios_rounded,
                  size: 14,
                  color: Colors.white12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSummary() {
    return Container(
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: brandGreen
            .withOpacity(0.05),
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
            color: brandGreen
                .withOpacity(0.1)),
      ),
      child: const Row(
        children: [
          Icon(
              Icons
                  .tips_and_updates_rounded,
              color: brandGreen,
              size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Keep job card status updated to ensure customers receive real-time notifications.",
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
