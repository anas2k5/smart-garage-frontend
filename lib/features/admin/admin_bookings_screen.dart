import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/services/api_service.dart';

class AdminBookingsScreen extends StatefulWidget {
  const AdminBookingsScreen({super.key});

  @override
  State<AdminBookingsScreen> createState() =>
      _AdminBookingsScreenState();
}

class _AdminBookingsScreenState
    extends State<AdminBookingsScreen> {
  List<Map<String, dynamic>> bookings = [];
  List<Map<String, dynamic>> filteredBookings = [];

  bool loading = true;

  String searchQuery = "";
  String statusFilter = "ALL";

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  // ================= LOAD BOOKINGS =================
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
        const SnackBar(content: Text("Failed to load bookings")),
      );
    }
  }

  // ================= FILTER LOGIC =================
  void _applyFilters() {
    filteredBookings = bookings.where((b) {
      final id = b["id"].toString();
      final garage = (b["garageName"] ?? "").toString().toLowerCase();
      final customer =
          (b["customerEmail"] ?? "").toString().toLowerCase();
      final status =
          (b["status"] ?? "").toString().toUpperCase();

      final matchesSearch =
          id.contains(searchQuery) ||
          garage.contains(searchQuery.toLowerCase()) ||
          customer.contains(searchQuery.toLowerCase());

      final matchesStatus =
          statusFilter == "ALL" || status == statusFilter;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  // ================= STATUS CHIPS =================
  Widget _statusChips() {
    const statuses = [
      "ALL",
      "PENDING",
      "PAID",
      "COMPLETED",
      "CANCELLED"
    ];

    return Wrap(
      spacing: 8,
      children: statuses.map((status) {
        final selected = statusFilter == status;

        return ChoiceChip(
          label: Text(status),
          selected: selected,
          onSelected: (_) {
            setState(() {
              statusFilter = status;
              _applyFilters();
            });
          },
        );
      }).toList(),
    );
  }

  // ================= DATE FORMAT =================
  String _formatDate(String isoDate) {
    final dt = DateTime.parse(isoDate);
    return DateFormat("dd MMM yyyy • hh:mm a").format(dt);
  }

  // ================= STATUS BADGE =================
  Widget _statusBadge(String status) {
    Color color;

    switch (status) {
      case "PAID":
        color = Colors.green;
        break;
      case "COMPLETED":
        color = Colors.blue;
        break;
      case "CANCELLED":
        color = Colors.red;
        break;
      case "PENDING":
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
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

  // ================= BOOKING CARD =================
  Widget _bookingCard(Map<String, dynamic> b) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              Theme.of(context).colorScheme.primary.withOpacity(0.15),
          child: const Icon(Icons.book_online),
        ),
        title: Text(
          "Booking #${b["id"]}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text("Garage: ${b["garageName"]}"),
            Text("Customer: ${b["customerEmail"]}"),
            Text("Date: ${_formatDate(b["bookingTime"])}"),
          ],
        ),
        trailing: _statusBadge(b["status"]),
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Booking Monitor"),
      ),
      body: RefreshIndicator(
        onRefresh: _loadBookings,
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // 🔍 Search
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText:
                            "Search by ID, garage, or customer email...",
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) {
                        setState(() {
                          searchQuery = val;
                          _applyFilters();
                        });
                      },
                    ),
                  ),

                  // 🏷️ Status Filters
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: _statusChips(),
                  ),

                  const SizedBox(height: 8),

                  // 📋 Booking List
                  Expanded(
                    child: filteredBookings.isEmpty
                        ? const Center(
                            child: Text("No bookings found"),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: filteredBookings.length,
                            itemBuilder: (context, index) {
                              return _bookingCard(
                                  filteredBookings[index]);
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}
