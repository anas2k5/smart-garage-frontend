import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../notifications/notification_screen.dart';

import '../../core/services/api_service.dart';
import '../../models/booking.dart';
import '../auth/login_screen.dart';
import 'owner_all_bookings_screen.dart';
import 'owner_garages_screen.dart';
import 'add_garage_screen.dart';
import 'owner_mechanics_screen.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {

  late Future<Map<String, dynamic>> _future;
  late AnimationController _animController;
  int unreadCount = 0;

  static const Color brandGreen = Color(0xFF00B562);
  static const Color surfaceDark = Color(0xFF1C1C1E);
  static const Color backgroundDark = Color(0xFF121212);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _future = ApiService.getOwnerDashboard();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _loadUnreadCount(); 
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadUnreadCount();
    }
  }

  void _reload() => setState(() => _future = ApiService.getOwnerDashboard());

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
  }

  Future<void> _loadUnreadCount() async {
    try {
      final count = await ApiService.getUnreadNotificationCount();
      if (!mounted) return;
      setState(() => unreadCount = count);
    } catch (_) {}
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
        body: RefreshIndicator(
          color: brandGreen,
          backgroundColor: surfaceDark,
          onRefresh: () async => _reload(),
          child: FutureBuilder<Map<String, dynamic>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: brandGreen));
              }
              if (snapshot.hasError || snapshot.data == null) {
                return _buildErrorState();
              }

              final data = snapshot.data!;
              
              // 🏷️ EXTRACTING OWNER NAME FROM API DATA
              // Make sure your backend returns "ownerName" or "fullName"
              final String displayName = data["ownerName"] ?? data["fullName"] ?? "Partner";

              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                children: [
                  _buildWelcomeHeader(displayName), // 🔥 Dynamic Name Integration
                  const SizedBox(height: 20),
                  _buildImageHero(), 
                  const SizedBox(height: 24),
                  _buildSectionHeader("Workshop Overview"),
                  const SizedBox(height: 12),
                  _buildStatGrid(data),
                  const SizedBox(height: 28),
                  _buildSectionHeader("Quick Operations"),
                  const SizedBox(height: 12),
                  _buildActionRow(),
                  const SizedBox(height: 28),
                  _buildSectionHeader("Active Bookings", trailing: "View All"),
                  const SizedBox(height: 12),
                  _buildRecentBookings(data["recentBookings"]),
                  const SizedBox(height: 28),
                  _buildSectionHeader("Total Revenue"),
                  const SizedBox(height: 12),
                  _buildRecentPayments(data["recentPayments"]),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ================= UNIFIED BRANDING LOGO =================

  AppBar _buildAppBar() {
    return AppBar(
      toolbarHeight: 70,
      backgroundColor: backgroundDark,
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
        IconButton(icon: const Icon(Icons.logout_rounded, color: Colors.white38), onPressed: _logout),
        const SizedBox(width: 8),
      ],
    );
  }

  // ================= IMPROVED DYNAMIC WELCOME HEADER =================

  Widget _buildWelcomeHeader(String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text("Welcome back,", 
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
            fontSize: 28, // Slightly larger for premium impact
            fontWeight: FontWeight.w900, 
            letterSpacing: 1.2
          )
        ),
      ],
    );
  }

  // ================= STATS & ACTION COMPONENTS =================

  Widget _buildStatGrid(Map data) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _statCard(Icons.home_repair_service_rounded, "Garages", data["activeGarages"].toString(), brandGreen, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OwnerGaragesScreen()))),
        _statCard(Icons.engineering_rounded, "Total Team", data["totalMechanics"]?.toString() ?? "0", Colors.blueAccent, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OwnerMechanicsScreen()))),
        _statCard(Icons.pending_actions_rounded, "Pending Jobs", data["pendingBookings"].toString(), Colors.orangeAccent, () {}),
        _statCard(Icons.payments_rounded, "Net Revenue", "₹${data["totalRevenue"] ?? 0}", brandGreen, () {}),
      ],
    );
  }

  Widget _statCard(IconData icon, String label, String value, Color color, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: color, size: 20),
                  const Icon(Icons.arrow_outward_rounded, size: 14, color: Colors.white24),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
                  Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionRow() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _actionButton("Garages", Icons.home_repair_service_rounded, brandGreen, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OwnerGaragesScreen())))),
            const SizedBox(width: 12),
            Expanded(child: _actionButton("Team", Icons.people_outline_rounded, Colors.blueAccent, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OwnerMechanicsScreen())))),
          ],
        ),
        const SizedBox(height: 12),
        _actionButton("Add New Branch", Icons.add_business_rounded, Colors.white, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddGarageScreen()))),
      ],
    );
  }

  Widget _actionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: surfaceDark,
          foregroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.white.withOpacity(0.05))),
          elevation: 0,
        ),
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      ),
    );
  }

  // ================= RECENT ACTIVITY BUILDERS =================

  Widget _buildRecentBookings(List? bookings) {
    if (bookings == null || bookings.isEmpty) return _buildEmptyState("No active bookings");
    return Column(children: bookings.take(3).map((b) => _buildBookingItem(b)).toList());
  }

  Widget _buildBookingItem(dynamic json) {
    final bool isDone = json["status"] == "COMPLETED" || json["status"] == "PAID";
    final statusColor = isDone ? brandGreen : Colors.orangeAccent;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: surfaceDark, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.03))),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(border: Border(left: BorderSide(color: statusColor, width: 4))),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: statusColor.withOpacity(0.1),
              child: Icon(isDone ? Icons.verified_user_rounded : Icons.timer_outlined, color: statusColor, size: 20),
            ),
            title: Text("Order #${json["bookingId"]}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text(json["serviceType"] ?? "Service Entry", style: const TextStyle(color: Colors.white38, fontSize: 11)),
            trailing: _statusBadge(json["status"]),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentPayments(List? payments) {
    if (payments == null || payments.isEmpty) return _buildEmptyState("No revenue logs");
    return Column(children: payments.take(3).map((p) => _buildPaymentItem(p)).toList());
  }

  Widget _buildPaymentItem(dynamic p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: brandGreen.withOpacity(0.02), borderRadius: BorderRadius.circular(16), border: Border.all(color: brandGreen.withOpacity(0.08))),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: const BoxDecoration(border: Border(left: BorderSide(color: brandGreen, width: 4))),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: const Icon(Icons.arrow_circle_up_rounded, color: brandGreen, size: 22),
            title: Text("₹${p["amount"]}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
            subtitle: Text(p["customerEmail"] ?? "Client", style: const TextStyle(color: Colors.white38, fontSize: 10)),
            trailing: Text(p["paidAt"] != null ? DateFormat("hh:mm a").format(DateTime.parse(p["paidAt"])) : "--", style: const TextStyle(color: Colors.white24, fontSize: 11)),
          ),
        ),
      ),
    );
  }

  // ================= COMMON HELPERS =================

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
              child: Text(unreadCount.toString(), style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            ),
          ),
      ],
    );
  }

  Widget _buildImageHero() {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: const DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1486262715619-67b85e0b08d3?q=80&w=1000&auto=format&fit=crop'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: brandGreen, borderRadius: BorderRadius.circular(8)),
              child: const Text("BUSINESS INSIGHT", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            const SizedBox(height: 8),
            const Text(
              "Management & Earnings\nLive Performance Data",
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {String? trailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)),
        if (trailing != null)
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OwnerAllBookingsScreen())),
            child: Text(trailing, style: const TextStyle(color: brandGreen, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
      ],
    );
  }

  Widget _statusBadge(String status) {
    Color color = Colors.orangeAccent;
    if (status == "COMPLETED" || status == "PAID") color = brandGreen;
    if (status == "CANCELLED") color = Colors.redAccent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(status, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900)),
    );
  }

  Widget _buildEmptyState(String msg) => Center(child: Padding(padding: const EdgeInsets.symmetric(vertical: 20), child: Text(msg, style: const TextStyle(color: Colors.white12, fontSize: 12))));

  Widget _buildErrorState() {
    return Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.cloud_off_rounded, size: 48, color: Colors.white10),
        const SizedBox(height: 16),
        const Text("Dashboard Sync Failure", style: TextStyle(color: Colors.white38)),
        TextButton(onPressed: _reload, child: const Text("Reconnect", style: TextStyle(color: brandGreen, fontWeight: FontWeight.bold))),
      ],
    ));
  }
}