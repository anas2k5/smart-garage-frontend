import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../models/booking.dart';
import '../../models/garage.dart';

class OwnerGarageBookingsScreen extends StatefulWidget {
  final Garage garage;

  const OwnerGarageBookingsScreen({
    super.key,
    required this.garage,
  });

  @override
  State<OwnerGarageBookingsScreen> createState() =>
      _OwnerGarageBookingsScreenState();
}

class _OwnerGarageBookingsScreenState
    extends State<OwnerGarageBookingsScreen> {
  late Future<List<Booking>> _future;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  void _loadBookings() {
    _future = ApiService.getBookingsByGarage(widget.garage.id)
        .then((list) => list.map((e) => Booking.fromJson(e)).toList());
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.orange;
      case 'ACCEPTED':
        return Colors.blue;
      case 'IN_PROGRESS':
        return Colors.purple;
      case 'COMPLETED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _updateStatus(int bookingId, String status) async {
    await ApiService.updateBookingStatus(
      bookingId: bookingId,
      status: status,
    );
    setState(_loadBookings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.garage.name),
      ),
      body: RefreshIndicator(
        onRefresh: () async => setState(_loadBookings),
        child: FutureBuilder<List<Booking>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(
                child: Text("Failed to load bookings"),
              );
            }

            final bookings = snapshot.data ?? [];

            if (bookings.isEmpty) {
              return const Center(
                child: Text("No bookings found"),
              );
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final b = bookings[index];

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                          "Booking #${b.id}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text("Vehicle: ${b.vehiclePlate}"),
                        Text("Customer: ${b.customerEmail ?? 'N/A'}"),
                        Text("Service: ${b.serviceType ?? 'Not assigned'}"),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Text("Status: "),
                            Text(
                              b.status,
                              style: TextStyle(
                                color: _statusColor(b.status),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        // 🔥 ACTIONS FOR PENDING
                        if (b.status == 'PENDING') ...[
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () =>
                                    _updateStatus(b.id, 'CANCELLED'),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                child: const Text("Reject"),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () =>
                                    _updateStatus(b.id, 'ACCEPTED'),
                                child: const Text("Accept"),
                              ),
                            ],
                          ),
                        ],
                      ],
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
