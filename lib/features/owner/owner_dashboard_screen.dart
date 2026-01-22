import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../../core/services/api_service.dart';
import '../../models/booking.dart';
import '../auth/login_screen.dart';
import 'owner_all_bookings_screen.dart';
import 'owner_garages_screen.dart';
import 'add_garage_screen.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() =>
      _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState
    extends State<OwnerDashboardScreen>
    with SingleTickerProviderStateMixin {
  late Future<Map<String, dynamic>> _future;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _future = ApiService.getOwnerDashboard();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // ================= LOGOUT =================
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  // ================= UI HELPERS =================

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: ScaleTransition(
        scale: Tween(begin: 0.9, end: 1.0).animate(
          CurvedAnimation(
            parent: _animController,
            curve: Curves.easeOutBack,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.4)),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: color.withOpacity(0.15),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(height: 14),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case "PENDING":
        return Colors.orange;
      case "ACCEPTED":
        return Colors.blue;
      case "IN_PROGRESS":
        return Colors.purple;
      case "COMPLETED":
        return Colors.green;
      case "PAID":
      case "SUCCESS":
        return Colors.green;
      case "CANCELLED":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // ================= RECENT BOOKING TILE =================
  Widget _recentBookingTile(Map<String, dynamic> json) {
    late Booking booking;

    try {
      booking = Booking.fromJson(json);
    } catch (_) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        title: Text(
          "Booking #${booking.id}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text("Garage: ${booking.garageNameSafe}"),
            Text("Service: ${booking.serviceTypeSafe}"),
            const SizedBox(height: 6),
            _statusChip(booking.status),
          ],
        ),
      ),
    );
  }

  // ================= RECENT PAYMENT TILE =================
  Widget _recentPaymentTile(Map<String, dynamic> p) {
    final paidAt = p["paidAt"] != null
        ? DateFormat("dd MMM yyyy, hh:mm a")
            .format(DateTime.parse(p["paidAt"]))
        : "—";

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.withOpacity(0.15),
          child: const Icon(Icons.payments, color: Colors.green),
        ),
        title: Text(
          "₹ ${p["amount"] ?? "0"}",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text("Garage: ${p["garageName"] ?? "—"}"),
            Text("Customer: ${p["customerEmail"] ?? "—"}"),
            Text("Method: ${p["method"] ?? "CARD"}"),
            Text(
              "Paid: $paidAt",
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        trailing: _statusChip("PAID"),
      ),
    );
  }

  Widget _statusChip(String status) {
    final color = _statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  String _formatCurrency(double v) {
    return "₹ ${v.toStringAsFixed(0)}";
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Owner Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text("Failed to load dashboard"));
          }

          final data = snapshot.data!;
          final activeGarages = data["activeGarages"] ?? 0;
          final totalBookings = data["totalBookings"] ?? 0;
          final pendingBookings = data["pendingBookings"] ?? 0;
          final revenueValue =
              (data["totalRevenue"] ?? 0).toDouble();

          final recentBookings =
              (data["recentBookings"] as List? ?? []);
          final recentPayments =
              (data["recentPayments"] as List? ?? []);

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _future = ApiService.getOwnerDashboard();
              });
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ================= WELCOME =================
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const ListTile(
                    leading: CircleAvatar(child: Icon(Icons.person)),
                    title: Text("Welcome Owner 👋"),
                    subtitle: Text(
                        "Manage your garages and bookings efficiently"),
                  ),
                ),

                const SizedBox(height: 20),

                // ================= STATS ROW 1 =================
                Row(
                  children: [
                    _statCard(
                      icon: Icons.garage,
                      label: "Active Garages",
                      value: "$activeGarages",
                      color: Colors.indigo,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const OwnerGaragesScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    _statCard(
                      icon: Icons.receipt_long,
                      label: "Total Bookings",
                      value: "$totalBookings",
                      color: Colors.blue,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const OwnerAllBookingsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // ================= STATS ROW 2 =================
                Row(
                  children: [
                    _statCard(
                      icon: Icons.hourglass_top,
                      label: "Pending",
                      value: "$pendingBookings",
                      color: Colors.orange,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const OwnerAllBookingsScreen(
                                  filter: "PENDING",
                                ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    _statCard(
                      icon: Icons.currency_rupee,
                      label: "Revenue",
                      value: _formatCurrency(revenueValue),
                      color: Colors.green,
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // ================= QUICK ACTIONS =================
                const Text(
                  "Quick Actions",
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _quickActionCard(
                        icon: Icons.garage,
                        label: "My Garages",
                        color: Colors.indigo,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const OwnerGaragesScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _quickActionCard(
                        icon: Icons.add_business,
                        label: "Add Garage",
                        color: Colors.green,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const AddGarageScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // ================= RECENT BOOKINGS =================
                const Text(
                  "Recent Bookings",
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                if (recentBookings.isEmpty)
                  const Text(
                    "No recent bookings",
                    style: TextStyle(color: Colors.grey),
                  )
                else
                  ...recentBookings
                      .map((e) => _recentBookingTile(e))
                      .toList(),

                const SizedBox(height: 28),

                // ================= RECENT PAYMENTS =================
                const Text(
                  "Recent Payments",
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                if (recentPayments.isEmpty)
                  const Text(
                    "No recent payments",
                    style: TextStyle(color: Colors.grey),
                  )
                else
                  ...recentPayments
                      .map((p) => _recentPaymentTile(p))
                      .toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  // ================= QUICK ACTION CARD =================
  Widget _quickActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.4)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
