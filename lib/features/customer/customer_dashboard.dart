import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../core/utils/auth_utils.dart';
import 'customer_bookings_screen.dart';
import 'create_booking/select_vehicle_screen.dart';

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({super.key});

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  late Future<Map<String, dynamic>> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = ApiService.getCustomerDashboard();
  }

  void _reload() {
    setState(() {
      _dashboardFuture = ApiService.getCustomerDashboard();
    });
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickAction(
      String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.deepPurple.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.deepPurple),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Customer Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reload,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              AuthUtils.logout(context);
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dashboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Failed to load dashboard"));
          }

          final data = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 🔥 STATS ROW 1
                Row(
                  children: [
                    _statCard(
                      "Total",
                      data["totalBookings"].toString(),
                      Icons.list_alt,
                      Colors.blue,
                    ),
                    const SizedBox(width: 12),
                    _statCard(
                      "Pending",
                      data["pendingBookings"].toString(),
                      Icons.hourglass_empty,
                      Colors.orange,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 🔥 STATS ROW 2
                Row(
                  children: [
                    _statCard(
                      "Ongoing",
                      data["ongoingBookings"].toString(),
                      Icons.build_circle,
                      Colors.deepPurple,
                    ),
                    const SizedBox(width: 12),
                    _statCard(
                      "Completed",
                      data["completedBookings"].toString(),
                      Icons.check_circle,
                      Colors.green,
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // 🔥 TOTAL SPENT
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.payments, color: Colors.green),
                      const SizedBox(width: 12),
                      const Text(
                        "Total Spent",
                        style: TextStyle(fontSize: 16),
                      ),
                      const Spacer(),
                      Text(
                        "₹ ${data["totalSpent"] ?? 0}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 🚀 QUICK ACTIONS
                _quickAction(
                  "My Bookings",
                  Icons.list_alt,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const CustomerBookingsScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 14),
                _quickAction(
                  "Book Service",
                  Icons.car_repair,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const SelectVehicleScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // 🕒 RECENT BOOKINGS
                const Text(
                  "Recent Bookings",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                ...(data["latestBookings"] as List).map((b) {
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(
                        b["garageName"] ?? "Garage",
                        style: const TextStyle(
                            fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        "Status: ${b["status"]}",
                      ),
                      trailing: Text(
                        b["finalCost"] != null
                            ? "₹ ${b["finalCost"]}"
                            : "N/A",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }
}
