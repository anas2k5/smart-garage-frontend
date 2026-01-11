import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../models/booking.dart';
import 'booking_details_screen.dart';

class CustomerBookingsScreen extends StatefulWidget {
  const CustomerBookingsScreen({super.key});

  @override
  State<CustomerBookingsScreen> createState() =>
      _CustomerBookingsScreenState();
}

class _CustomerBookingsScreenState extends State<CustomerBookingsScreen> {
  late Future<List<Booking>> _bookingsFuture;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  void _loadBookings() {
    _bookingsFuture = ApiService.getCustomerBookings()
        .then((list) => list.map((e) => Booking.fromJson(e)).toList());
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.orange;
      case 'ACCEPTED':
        return Colors.grey;
      case 'IN_PROGRESS':
        return Colors.blue;
      case 'COMPLETED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.black54;
    }
  }

  // ✅ CONFIRMATION DIALOG
  Future<void> _confirmCancel(
      BuildContext context, int bookingId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Cancel Booking"),
        content: const Text(
          "Are you sure you want to cancel this booking?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Yes, Cancel",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ApiService.cancelBooking(bookingId);
      setState(() {
        _loadBookings(); // 🔄 refresh list
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Bookings")),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(_loadBookings);
        },
        child: FutureBuilder<List<Booking>>(
          future: _bookingsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text("Failed to load bookings"));
            }

            final bookings = snapshot.data ?? [];

            if (bookings.isEmpty) {
              return const Center(child: Text("No bookings found"));
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];

                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            BookingDetailsScreen(booking: booking),
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Booking #${booking.id}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),

                          Row(
                            children: [
                              const Text("Status: "),
                              Text(
                                booking.status,
                                style: TextStyle(
                                  color: _statusColor(booking.status),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 4),
                          Text(
                            "Cost: ${booking.finalCost ?? 'N/A'}",
                            style:
                                const TextStyle(color: Colors.black54),
                          ),

                          // 🔥 CANCEL BUTTON (ONLY FOR PENDING)
                          if (booking.status == 'PENDING') ...[
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                onPressed: () => _confirmCancel(
                                  context,
                                  booking.id!,
                                ),
                                child:
                                    const Text("Cancel Booking"),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
