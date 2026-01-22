import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../models/booking.dart';
import '../../models/garage.dart';

class OwnerAllBookingsScreen extends StatefulWidget {
  final String? filter;

  const OwnerAllBookingsScreen({Key? key, this.filter}) : super(key: key);

  @override
  State<OwnerAllBookingsScreen> createState() =>
      _OwnerAllBookingsScreenState();
}

class _OwnerAllBookingsScreenState
    extends State<OwnerAllBookingsScreen> {
  late Future<List<Booking>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = _loadAllGaragesBookings();
  }

  Future<List<Booking>> _loadAllGaragesBookings() async {
    final garages = await ApiService.getOwnerGarages();
    final futures = garages.map(_fetchGarageBookings).toList();
    final results = await Future.wait(futures);

    final all = results.expand((e) => e).toList();
    all.sort((a, b) => b.bookingTime.compareTo(a.bookingTime));

    if (widget.filter == null) return all;
    return all.where((b) => b.status == widget.filter).toList();
  }

  Future<List<Booking>> _fetchGarageBookings(Garage g) async {
    final list = await ApiService.getBookingsByGarage(g.id);
    return list
        .map((e) {
          try {
            return Booking.fromJson(e);
          } catch (_) {
            return null;
          }
        })
        .whereType<Booking>()
        .toList();
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

  Widget _costRow(Booking b) {
    if (b.finalCost != null) {
      return Text(
        "Final: ₹${b.finalCost!.toStringAsFixed(2)}",
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
      );
    }

    if (b.estimatedCost != null) {
      return Text(
        "Estimated: ₹${b.estimatedCost!.toStringAsFixed(2)}",
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.orange,
        ),
      );
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.filter == null
              ? "All Bookings"
              : "${widget.filter} Bookings",
        ),
      ),
      body: FutureBuilder<List<Booking>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Failed to load bookings"));
          }

          final bookings = snapshot.data ?? [];

          if (bookings.isEmpty) {
            return const Center(
              child: Text("No bookings found"),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => setState(_load),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final b = bookings[index];

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Booking #${b.id}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            _statusChip(b.status),
                          ],
                        ),

                        const SizedBox(height: 6),

                        Text("Garage: ${b.garageNameSafe}"),
                        Text("Vehicle: ${b.vehiclePlateSafe}"),
                        Text("Customer: ${b.customerEmailSafe}"),
                        Text("Service: ${b.serviceTypeSafe}"),

                        const SizedBox(height: 8),
                        _costRow(b),

                        if (b.mechanicName != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            "Mechanic: ${b.mechanicNameSafe} (${b.mechanicPhoneSafe})",
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
