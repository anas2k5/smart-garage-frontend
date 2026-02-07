import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../models/booking.dart';
import '../../models/garage.dart';
import '../../models/mechanic.dart';
import 'add_mechanic_screen.dart';
import 'owner_jobcard_view_screen.dart';

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
    _future = ApiService
        .getBookingsByGarage(widget.garage.id)
        .then((list) =>
            list.map((e) => Booking.fromJson(e)).toList());
  }

  // ================= STATUS COLORS =================

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
      case 'PAID':
        return Colors.teal;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _paymentColor(String status) {
    switch (status) {
      case 'SUCCESS':
      case 'PAID':
        return Colors.green;
      case 'FAILED':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  // ================= STATUS CHIP =================

  Widget _statusChip(String status) {
    final color = _statusColor(status);

    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        status.replaceAll("_", " "),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  // ================= PAYMENT CHIP =================

  Widget _paymentChip(String status) {
    final color = _paymentColor(status);

    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        "Payment: ${status.toUpperCase()}",
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  // ================= UPDATE STATUS =================

  Future<void> _updateStatus(
      int bookingId,
      String status,
  ) async {
    await ApiService.updateBookingStatus(
      bookingId: bookingId,
      status: status,
    );

    setState(_loadBookings);
  }

  // ================= ACTIONS =================

  Widget _actions(Booking b) {
    final buttons = <Widget>[];

    if (b.status == 'PENDING') {
      buttons.addAll([
        TextButton(
          onPressed: () =>
              _updateStatus(b.id, 'CANCELLED'),
          child: const Text("Reject"),
        ),
        ElevatedButton(
          onPressed: () =>
              _updateStatus(b.id, 'ACCEPTED'),
          child: const Text("Accept"),
        ),
      ]);
    }

    if (b.status == 'ACCEPTED' &&
        b.mechanicName == null) {
      buttons.add(
        ElevatedButton(
          onPressed: () =>
              _openAssignMechanicSheet(b),
          child: const Text("Assign Mechanic"),
        ),
      );
    }

    if (b.status == 'IN_PROGRESS' &&
        b.finalCost != null) {
      buttons.add(
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
          ),
          onPressed: () =>
              _updateStatus(b.id, 'COMPLETED'),
          child: const Text("Finalize Booking"),
        ),
      );
    }

    if (b.status == 'IN_PROGRESS' ||
        b.status == 'COMPLETED' ||
        b.status == 'PAID') {
      buttons.add(
        OutlinedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    OwnerJobCardViewScreen(
                  bookingId: b.id,
                  garageId: widget.garage.id,
                ),
              ),
            );
          },
          child: const Text("View Job Card"),
        ),
      );
    }

    if (buttons.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: buttons,
    );
  }

  // ================= ASSIGN =================

  void _openAssignMechanicSheet(
      Booking booking) async {

    final mechanics =
        await ApiService.getMechanicsByGarage(
            widget.garage.id);

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return ListView(
          children: mechanics.map((m) {
            return ListTile(
              title: Text(m.name),
              subtitle: Text(m.phone),
              onTap: () async {
                await ApiService.assignMechanic(
                  bookingId: booking.id,
                  mechanicId: m.id,
                );
                Navigator.pop(context);
                setState(_loadBookings);
              },
            );
          }).toList(),
        );
      },
    );
  }

  // ================= BOOKING CARD =================

  Widget _bookingCard(Booking b) {
    return Card(
      margin: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            // HEADER
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
                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.end,
                  children: [
                    _statusChip(b.status),
                    const SizedBox(height: 4),
                    _paymentChip(
                        b.paymentStatus),
                  ],
                )
              ],
            ),

            const SizedBox(height: 8),

            Text("Vehicle: ${b.vehiclePlateSafe}"),
            Text("Service: ${b.serviceTypeSafe}"),
            Text("Customer: ${b.customerEmailSafe}"),

            Text(
              "Time: ${b.bookingTimeFormatted}",
              style: const TextStyle(fontSize: 12),
            ),

            if (b.estimatedCost != null)
              Text(
                "Estimated: ₹${b.estimatedCost}",
                style:
                    const TextStyle(color: Colors.blue),
              ),

            if (b.finalCost != null)
              Text(
                "Final: ₹${b.finalCost}",
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),

            const SizedBox(height: 10),

            _actions(b),
          ],
        ),
      ),
    );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.garage.name),
        actions: [
          IconButton(
            icon:
                const Icon(Icons.person_add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      AddMechanicScreen(
                    garage: widget.garage,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Booking>>(
        future: _future,
        builder: (context, snap) {

          if (!snap.hasData) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          final list = snap.data!;

          if (list.isEmpty) {
            return const Center(
              child:
                  Text("No bookings yet"),
            );
          }

          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (_, i) =>
                _bookingCard(list[i]),
          );
        },
      ),
    );
  }
}
