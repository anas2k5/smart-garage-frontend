import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../core/utils/auth_utils.dart';
import 'customer_bookings_screen.dart';
import 'create_booking/select_vehicle_screen.dart';
import 'payment_history_screen.dart';

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({super.key});

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  late Future<Map<String, dynamic>> _dashboardFuture;

  // Professional Color Palette
  static const Color brandGreen = Color(0xFF00B562);
  static const Color surfaceDark = Color(0xFF1C1C1E);
  static const Color backgroundDark = Color(0xFF121212);

  @override
  void initState() {
    super.initState();
    _dashboardFuture = ApiService.getCustomerDashboard();
  }

  void _reload() => setState(() => _dashboardFuture = ApiService.getCustomerDashboard());

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        useMaterial3: true,
        scaffoldBackgroundColor: backgroundDark,
        colorScheme: ColorScheme.fromSeed(seedColor: brandGreen, brightness: Brightness.dark),
      ),
      child: Scaffold(
        appBar: _buildAppBar(),
        body: RefreshIndicator(
          onRefresh: () async => _reload(),
          color: brandGreen,
          child: FutureBuilder<Map<String, dynamic>>(
            future: _dashboardFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: brandGreen));
              }
              if (snapshot.hasError) {
                return _buildErrorState();
              }

              final data = snapshot.data!;
              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                children: [
                  _buildVehicleHero(data),
                  const SizedBox(height: 24),
                  _buildSectionHeader("Service Overview"),
                  const SizedBox(height: 12),
                  _buildInsightGrid(data),
                  const SizedBox(height: 24),
                  _buildSectionHeader("Quick Actions"),
                  const SizedBox(height: 12),
                  _buildActionRow(),
                  const SizedBox(height: 24),
                  _buildSectionHeader("Recent Activity", trailing: "View All"),
                  const SizedBox(height: 12),
                  ...((data["latestBookings"] as List? ?? [])
                      .map((b) => _buildBookingListItem(b))),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text("Smart Garage", 
        style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5)),
      backgroundColor: backgroundDark,
      surfaceTintColor: Colors.transparent,
      actions: [
        IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
        IconButton(icon: const Icon(Icons.logout_rounded), 
          onPressed: () => AuthUtils.logout(context)),
      ],
    );
  }

  Widget _buildSectionHeader(String title, {String? trailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        if (trailing != null)
          Text(trailing, style: const TextStyle(color: brandGreen, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildVehicleHero(Map data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [brandGreen.withOpacity(0.8), brandGreen.withOpacity(0.4)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -10,
            child: Icon(Icons.directions_car_filled, size: 120, color: Colors.white.withOpacity(0.1)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("PRIMARY VEHICLE", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text("Hyundai i20", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const Text("TS 09 EQ 1234", style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(20)),
                child: const Text("Next Service: 25 Days Left", style: TextStyle(color: Colors.white, fontSize: 12)),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightGrid(Map data) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _insightTile("Ongoing", data["ongoingBookings"].toString(), Icons.engineering, Colors.orange),
        _insightTile("Completed", data["completedBookings"].toString(), Icons.verified, brandGreen),
      ],
    );
  }

  Widget _insightTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: surfaceDark, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 28),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildActionRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _actionButton("Book Now", Icons.add_task, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SelectVehicleScreen()))),
        _actionButton("History", Icons.history, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerBookingsScreen()))),
        _actionButton("Payments", Icons.account_balance_wallet, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentHistoryScreen()))),
      ],
    );
  }

  Widget _actionButton(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(radius: 28, backgroundColor: surfaceDark, child: Icon(icon, color: brandGreen)),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildBookingListItem(Map b) {
    bool isDone = b["status"] == "COMPLETED";
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: surfaceDark, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: (isDone ? brandGreen : Colors.orange).withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(isDone ? Icons.check : Icons.access_time_filled, color: isDone ? brandGreen : Colors.orange, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(b["garageName"] ?? "Garage Service", style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(b["status"], style: TextStyle(color: isDone ? brandGreen : Colors.orange, fontSize: 12)),
              ],
            ),
          ),
          Text("₹${b["finalCost"] ?? '0'}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
          const SizedBox(height: 16),
          const Text("Couldn't sync dashboard"),
          TextButton(onPressed: _reload, child: const Text("Retry", style: TextStyle(color: brandGreen))),
        ],
      ),
    );
  }
}