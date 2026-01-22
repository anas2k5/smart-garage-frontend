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

  // ================= UI HELPERS =================

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

  Widget _statusChip(String status) {
    final color = _statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

  // ================= API ACTIONS =================

  Future<void> _updateStatus(int bookingId, String status) async {
    await ApiService.updateBookingStatus(
      bookingId: bookingId,
      status: status,
    );
    setState(_loadBookings);
  }

  // ================= MECHANIC =================

  void _openAssignMechanicSheet(Booking booking) async {
    final List<Mechanic> mechanics =
        await ApiService.getMechanicsByGarage(widget.garage.id);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        if (mechanics.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Text("No mechanics available"),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(12),
          children: mechanics.map((m) {
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: const Icon(Icons.engineering),
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
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // ================= COST DIALOG =================

  void _openCostDialog({
    required Booking booking,
    required bool isFinal,
  }) {
    final ctrl = TextEditingController(
      text: isFinal
          ? booking.finalCost?.toString() ?? ""
          : booking.estimatedCost?.toString() ?? "",
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(isFinal ? "Set Final Cost" : "Set Estimated Cost"),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            prefixText: "₹ ",
            labelText: "Amount",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final value = double.tryParse(ctrl.text);
              if (value == null) return;

              if (isFinal) {
                await ApiService.updateFinalCost(
                  bookingId: booking.id,
                  finalCost: value,
                );
              } else {
                await ApiService.updateEstimatedCost(
                  bookingId: booking.id,
                  estimatedCost: value,
                );
              }

              Navigator.pop(context);
              setState(_loadBookings);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // ================= ACTIONS BAR =================

  Widget _actions(Booking b) {
    final List<Widget> buttons = [];

    if (b.status == 'PENDING') {
      buttons.addAll([
        TextButton(
          onPressed: () => _updateStatus(b.id, 'CANCELLED'),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text("Reject"),
        ),
        ElevatedButton(
          onPressed: () => _updateStatus(b.id, 'ACCEPTED'),
          child: const Text("Accept"),
        ),
      ]);
    }

    if (b.status == 'ACCEPTED' && b.mechanicName == null) {
      buttons.add(
        ElevatedButton(
          onPressed: () => _openAssignMechanicSheet(b),
          child: const Text("Assign Mechanic"),
        ),
      );
    }

    if (b.status == 'ACCEPTED' &&
        b.mechanicName != null &&
        b.estimatedCost == null) {
      buttons.add(
        ElevatedButton(
          onPressed: () => _openCostDialog(
            booking: b,
            isFinal: false,
          ),
          child: const Text("Add Estimate"),
        ),
      );
    }

    if (b.status == 'ACCEPTED' && b.estimatedCost != null) {
      buttons.add(
        ElevatedButton(
          onPressed: () => _updateStatus(b.id, 'IN_PROGRESS'),
          child: const Text("Start Work"),
        ),
      );
    }

    if (b.status == 'IN_PROGRESS' && b.finalCost == null) {
      buttons.add(
        ElevatedButton(
          onPressed: () => _openCostDialog(
            booking: b,
            isFinal: true,
          ),
          child: const Text("Add Final Cost"),
        ),
      );
    }

    if (b.status == 'IN_PROGRESS' && b.finalCost != null) {
      buttons.add(
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
          ),
          onPressed: () => _updateStatus(b.id, 'COMPLETED'),
          child: const Text("Mark Completed"),
        ),
      );
    }

    if (buttons.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Wrap(
        spacing: 8,
        children: buttons,
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
              padding: const EdgeInsets.all(12),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final b = bookings[index];

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

                        const SizedBox(height: 8),

                        Text("Vehicle: ${b.vehiclePlateSafe}"),
                        Text("Customer: ${b.customerEmailSafe}"),
                        Text("Service: ${b.serviceTypeSafe}"),

                        if (b.estimatedCost != null)
                          Text(
                            "Estimated: ₹${b.estimatedCost!.toStringAsFixed(2)}",
                            style: const TextStyle(color: Colors.orange),
                          ),

                        if (b.finalCost != null)
                          Text(
                            "Final: ₹${b.finalCost!.toStringAsFixed(2)}",
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                        if (b.mechanicName != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              "Mechanic: ${b.mechanicNameSafe} (${b.mechanicPhoneSafe})",
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                        _actions(b),
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
