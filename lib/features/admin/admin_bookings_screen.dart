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
  List bookings = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    try {
      final data = await ApiService.getAllBookingsAdmin();

      if (!mounted) return;

      setState(() {
        bookings = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to load bookings"),
        ),
      );
    }
  }

  String _formatDate(String isoDate) {
    final dt = DateTime.parse(isoDate);
    return DateFormat("dd MMM yyyy, hh:mm a").format(dt);
  }

  Color _statusColor(String status) {
    switch (status) {
      case "PAID":
        return Colors.green;
      case "COMPLETED":
        return Colors.blue;
      case "CANCELLED":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("All Bookings")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final b = bookings[index];

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.book),
                    title: Text(
                      "Booking #${b["id"]}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text("Garage: ${b["garageName"]}"),
                        Text(
                            "Customer: ${b["customerEmail"]}"),
                        Text(
                          "Date: ${_formatDate(b["bookingTime"])}",
                        ),
                      ],
                    ),
                    trailing: Chip(
                      label: Text(
                        b["status"],
                        style:
                            const TextStyle(color: Colors.white),
                      ),
                      backgroundColor:
                          _statusColor(b["status"]),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
