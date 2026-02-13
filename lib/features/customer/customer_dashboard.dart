import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../notifications/notification_screen.dart';

import '../../core/services/api_service.dart';
import '../../core/utils/auth_utils.dart';
import 'customer_bookings_screen.dart';
import 'create_booking/select_vehicle_screen.dart';
import 'payment_history_screen.dart';
import 'presentation/free_map_screen.dart';

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({super.key});

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> with WidgetsBindingObserver {
  late Future<Map<String, dynamic>> _dashboardFuture;
  int unreadCount = 0;
  String locationText = "Fetching location...";

  static const Color brandGreen = Color(0xFF00B562);
  static const Color surfaceDark = Color(0xFF1C1C1E);
  static const Color backgroundDark = Color(0xFF121212);

  @override
  void initState() {
    super.initState();
    _dashboardFuture = ApiService.getCustomerDashboard();
    WidgetsBinding.instance.addObserver(this);
    _fetchLiveLocation();
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

  void _reload() => setState(() => _dashboardFuture = ApiService.getCustomerDashboard());

  // ==============================
  // 📍 DATA & LOCATION LOGIC
  // ==============================

  Future<void> _loadUnreadCount() async {
    try {
      final count = await ApiService.getUnreadNotificationCount();
      if (!mounted) return;
      setState(() => unreadCount = count);
    } catch (_) {}
  }

  Future<void> _fetchLiveLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => locationText = "Location disabled");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        setState(() => locationText = "Permission denied");
        return;
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() => locationText = "${place.locality}, ${place.administrativeArea}");
      }
    } catch (e) {
      setState(() => locationText = "Unable to fetch location");
    }
  }

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
          color: brandGreen,
          backgroundColor: surfaceDark,
          onRefresh: () async => _reload(),
          child: FutureBuilder<Map<String, dynamic>>(
            future: _dashboardFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: brandGreen));
              }
              if (snapshot.hasError) return _buildErrorState();

              final data = snapshot.data!;
              final String customerName = data["customerName"] ?? "Customer";

              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                children: [
                  _buildWelcomeHeader(customerName), // 🔥 Dynamic Welcome Added
                  const SizedBox(height: 20),
                  _buildLocationHeader(),
                  const SizedBox(height: 20),
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
                  ...((data["latestBookings"] as List? ?? []).map((b) => _buildBookingListItem(b))),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ==============================
  // 🔝 UNIFIED PREMIUM APP BAR
  // ==============================

  AppBar _buildAppBar() {
    return AppBar(
      toolbarHeight: 70,
      backgroundColor: backgroundDark,
      surfaceTintColor: Colors.transparent,
      title: Row(
        children: [
          // 🏎️ UNIFIED STACKED LOGO
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: brandGreen.withOpacity(0.2)),
                  boxShadow: [BoxShadow(color: brandGreen.withOpacity(0.1), blurRadius: 10)],
                ),
              ),
              const Icon(Icons.build_rounded, size: 16, color: brandGreen),
              const Positioned(
                bottom: 8,
                child: Icon(Icons.directions_car_filled_rounded, size: 10, color: Colors.white70),
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
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none_rounded, color: Colors.white70),
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
        ),
        IconButton(icon: const Icon(Icons.logout_rounded, color: Colors.white38, size: 22), onPressed: () => AuthUtils.logout(context)),
        const SizedBox(width: 8),
      ],
    );
  }

  // ==============================
  // 👋 DYNAMIC WELCOME HEADER
  // ==============================

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
            fontSize: 28, 
            fontWeight: FontWeight.w900, 
            letterSpacing: 1.2
          )
        ),
      ],
    );
  }

  // ==============================
  // 🏗️ RESTORED UI COMPONENTS
  // ==============================

  Widget _buildLocationHeader() {
    return InkWell(
      onTap: () async {
        final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const FreeMapScreen()));
        if (result != null) setState(() => locationText = result);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: surfaceDark, 
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on, color: brandGreen),
            const SizedBox(width: 10),
            Expanded(child: Text(locationText, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
            const Icon(Icons.keyboard_arrow_down, color: Colors.white54)
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleHero(Map data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(colors: [brandGreen.withOpacity(0.8), brandGreen.withOpacity(0.4)]),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("PRIMARY VEHICLE", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text("Hyundai i20", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          Text("TS 09 EQ 1234", style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildInsightGrid(Map data) {
    return GridView.count(
      crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.5,
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
          Icon(isDone ? Icons.check_circle : Icons.access_time_filled, color: isDone ? brandGreen : Colors.orange, size: 24),
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

  Widget _buildSectionHeader(String title, {String? trailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        if (trailing != null) Text(trailing, style: const TextStyle(color: brandGreen, fontWeight: FontWeight.w600)),
      ],
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