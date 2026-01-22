import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    _animController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 600))
          ..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  // ---------------- UI HELPERS ----------------

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
          CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ],
              border: Border.all(color: color.withOpacity(0.4)),
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
        return Colors.teal;
      case "CANCELLED":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _statusColor(booking.status).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _statusColor(booking.status),
                ),
              ),
              child: Text(
                booking.status,
                style: TextStyle(
                  color: _statusColor(booking.status),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double v) {
    return "₹ ${v.toStringAsFixed(0)}";
  }

  // ---------------- UI ----------------

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
          final revenueValue = (data["totalRevenue"] ?? 0).toDouble();
          final recentBookings = (data["recentBookings"] as List? ?? []);

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _future = ApiService.getOwnerDashboard();
              });
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Welcome Card
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const ListTile(
                    leading: CircleAvatar(child: Icon(Icons.person)),
                    title: Text("Welcome Owner 👋"),
                    subtitle:
                        Text("Manage your garages and bookings efficiently"),
                  ),
                ),

                const SizedBox(height: 20),

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
                            builder: (_) => const OwnerGaragesScreen(),
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
                                const OwnerAllBookingsScreen(filter: "PENDING"),
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

                const Text(
                  "Quick Actions",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                ListTile(
                  leading: const Icon(Icons.garage),
                  title: const Text("My Garages"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const OwnerGaragesScreen(),
                      ),
                    );
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.add_business),
                  title: const Text("Add Garage"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddGarageScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                const Text(
                  "Recent Bookings",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              ],
            ),
          );
        },
      ),
    );
  }
}
