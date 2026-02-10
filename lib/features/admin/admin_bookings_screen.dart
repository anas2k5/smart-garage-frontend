import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/services/api_service.dart';

class AdminBookingsScreen extends StatefulWidget {
  const AdminBookingsScreen({super.key});

  @override
  State<AdminBookingsScreen> createState() => _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends State<AdminBookingsScreen> {
  List<Map<String, dynamic>> bookings = [];
  List<Map<String, dynamic>> filteredBookings = [];

  bool loading = true;
  String searchQuery = "";
  String statusFilter = "ALL";

  // Global Brand Palette
  static const Color brandGreen = Color(0xFF00B562);
  static const Color surfaceDark = Color(0xFF1C1C1E);
  static const Color backgroundDark = Color(0xFF121212);

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    try {
      setState(() => loading = true);
      final data = await ApiService.getAllBookingsAdmin();
      final list = List<Map<String, dynamic>>.from(data);

      if (!mounted) return;

      setState(() {
        bookings = list;
        _applyFilters();
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: Colors.redAccent, content: Text("Failed to sync bookings")),
      );
    }
  }

  void _applyFilters() {
    filteredBookings = bookings.where((b) {
      final id = b["id"].toString();
      final garage = (b["garageName"] ?? "").toString().toLowerCase();
      final customer = (b["customerEmail"] ?? "").toString().toLowerCase();
      final status = (b["status"] ?? "").toString().toUpperCase();

      final matchesSearch = id.contains(searchQuery) ||
          garage.contains(searchQuery.toLowerCase()) ||
          customer.contains(searchQuery.toLowerCase());

      final matchesStatus = statusFilter == "ALL" || status == statusFilter;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      return DateFormat("dd MMM yyyy • hh:mm a").format(dt);
    } catch (e) {
      return "Date pending";
    }
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
        appBar: AppBar(
          title: const Text("Platform Traffic", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          centerTitle: true,
        ),
        body: Column(
          children: [
            _buildSearchAndFilters(),
            Expanded(
              child: RefreshIndicator(
                color: brandGreen,
                onRefresh: _loadBookings,
                child: loading
                    ? const Center(child: CircularProgressIndicator(color: brandGreen))
                    : _buildBookingList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: backgroundDark,
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Column(
        children: [
          TextField(
            onChanged: (val) => setState(() { searchQuery = val; _applyFilters(); }),
            decoration: InputDecoration(
              hintText: "Search ID, Garage, or Customer...",
              hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
              prefixIcon: const Icon(Icons.search_rounded, color: brandGreen, size: 20),
              filled: true,
              fillColor: surfaceDark,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ["ALL", "PENDING", "PAID", "COMPLETED", "CANCELLED"]
                  .map((s) => _buildFilterChip(s)).toList(),
            ),
          ),
        ],
      ),
    );
  }

// Update the ChoiceChip shape inside _buildFilterChip method:
Widget _buildFilterChip(String label) {
  final isSelected = statusFilter == label;
  return Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
      selected: isSelected,
      onSelected: (_) => setState(() { statusFilter = label; _applyFilters(); }),
      selectedColor: brandGreen,
      backgroundColor: surfaceDark,
      showCheckmark: false,
      // FIXED PARAMETER NAME
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide.none),
    ),
  );
}

  Widget _buildBookingList() {
    if (filteredBookings.isEmpty) {
      return const Center(child: Text("No records match your filters", style: TextStyle(color: Colors.white24)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredBookings.length,
      itemBuilder: (context, index) => _buildBookingCard(filteredBookings[index]),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> b) {
    final status = (b["status"] ?? "UNKNOWN").toString().toUpperCase();
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("ORDER #${b["id"]}", 
                  style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                _statusBadge(status),
              ],
            ),
            const SizedBox(height: 16),
            _infoLine(Icons.storefront_rounded, "Garage", b["garageName"] ?? "Unknown"),
            _infoLine(Icons.person_outline_rounded, "Client", b["customerEmail"] ?? "No email"),
            _infoLine(Icons.access_time_rounded, "Scheduled", _formatDate(b["bookingTime"] ?? "")),
          ],
        ),
      ),
    );
  }

  Widget _infoLine(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 14, color: brandGreen.withOpacity(0.7)),
          const SizedBox(width: 12),
          Text("$label: ", style: const TextStyle(color: Colors.white30, fontSize: 13)),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    switch (status) {
      case "PAID": color = brandGreen; break;
      case "COMPLETED": color = Colors.blueAccent; break;
      case "CANCELLED": color = Colors.redAccent; break;
      case "PENDING": color = Colors.orangeAccent; break;
      default: color = Colors.white24;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.3))),
      child: Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}