import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../models/booking.dart';
import '../../models/garage.dart';
import '../../models/mechanic.dart';
import 'add_mechanic_screen.dart';

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

  // ================= ASSIGN MECHANIC =================
  void _openAssignMechanicSheet(Booking booking) async {
    final List<Mechanic> mechanics =
        await ApiService.getMechanicsByGarage(widget.garage.id);

    showModalBottomSheet(
      context: context,
      builder: (_) {
        if (mechanics.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text("No mechanics available"),
          );
        }

        return ListView(
          children: mechanics.map((m) {
            return ListTile(
              title: Text(m.name),
              subtitle: Text(m.phone),
              trailing: const Icon(Icons.chevron_right),
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

  // ================= ESTIMATED COST =================
  void _openEstimatedCostDialog(Booking booking) {
    final ctrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Set Estimated Cost"),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Estimated Cost"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await ApiService.updateEstimatedCost(
                bookingId: booking.id,
                estimatedCost: double.parse(ctrl.text),
              );
              Navigator.pop(context);
              setState(_loadBookings);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // ================= FINAL COST =================
  void _openFinalCostDialog(Booking booking) {
    final ctrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Set Final Cost"),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Final Cost"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await ApiService.updateFinalCost(
                bookingId: booking.id,
                finalCost: double.parse(ctrl.text),
              );
              Navigator.pop(context);
              setState(_loadBookings);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.garage.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: "Add Mechanic",
            onPressed: () async {
              final added = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddMechanicScreen(
                    garage: widget.garage,
                  ),
                ),
              );

              if (added == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Mechanic added")),
                );
              }
            },
          ),
        ],
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

                        if (b.estimatedCost != null)
                          Text("Estimated Cost: ₹${b.estimatedCost}"),

                        if (b.finalCost != null)
                          Text(
                            "Final Cost: ₹${b.finalCost}",
                            style:
                                const TextStyle(fontWeight: FontWeight.bold),
                          ),

                        // 🔥 PENDING
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

                        // 🔧 ASSIGN MECHANIC
                        if (b.status == 'ACCEPTED' &&
                            b.mechanicName == null) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: () =>
                                  _openAssignMechanicSheet(b),
                              child: const Text("Assign Mechanic"),
                            ),
                          ),
                        ],

                        // 💰 ADD ESTIMATED COST
                        if (b.status == 'ACCEPTED' &&
                            b.mechanicName != null &&
                            b.estimatedCost == null) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: () =>
                                  _openEstimatedCostDialog(b),
                              child: const Text("Add Estimated Cost"),
                            ),
                          ),
                        ],

                        // ▶ START WORK
                        if (b.status == 'ACCEPTED' &&
                            b.estimatedCost != null) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: () =>
                                  _updateStatus(b.id, 'IN_PROGRESS'),
                              child: const Text("Start Work"),
                            ),
                          ),
                        ],

                        // 🧾 ADD FINAL COST
                        if (b.status == 'IN_PROGRESS' &&
                            b.finalCost == null) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: () =>
                                  _openFinalCostDialog(b),
                              child: const Text("Add Final Cost"),
                            ),
                          ),
                        ],

                        // ✅ COMPLETE
                        if (b.status == 'IN_PROGRESS' &&
                            b.finalCost != null) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              onPressed: () =>
                                  _updateStatus(b.id, 'COMPLETED'),
                              child: const Text("Mark Completed"),
                            ),
                          ),
                        ],

                        // 👨‍🔧 MECHANIC INFO
                        if (b.mechanicName != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            "Mechanic: ${b.mechanicName} (${b.mechanicPhone})",
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
            );
          },
        ),
      ),
    );
  }
}
