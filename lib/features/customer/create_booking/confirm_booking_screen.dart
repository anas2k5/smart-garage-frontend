import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../models/garage.dart';
import '../../../models/vehicle.dart';
import '../../../models/garage_service.dart';
import '../../customer/customer_bookings_screen.dart';

class ConfirmBookingScreen extends StatefulWidget {
  final Garage garage;
  final Vehicle vehicle;
  final GarageService service;

  const ConfirmBookingScreen({
    super.key,
    required this.garage,
    required this.vehicle,
    required this.service,
  });

  @override
  State<ConfirmBookingScreen> createState() =>
      _ConfirmBookingScreenState();
}

class _ConfirmBookingScreenState
    extends State<ConfirmBookingScreen> {
  bool _loading = false;

  Future<void> _confirmBooking() async {
    setState(() => _loading = true);

    try {
      await ApiService.createBooking(
        garageId: widget.garage.id,
        vehicleId: widget.vehicle.id,
        serviceId: widget.service.id,
        bookingTime: DateTime.now().add(const Duration(hours: 2)),
        details: "Booked via mobile app",
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Booking created successfully"),
        ),
      );

      // ✅ FIXED NAVIGATION — preserves back stack
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const CustomerBookingsScreen(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Failed to create booking"),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  // ================= SAFE STEP HEADER =================
  Widget _stepHeader() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: const [
            _StepChip(title: "Vehicle", done: true),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, size: 14),
            SizedBox(width: 8),
            _StepChip(title: "Garage", done: true),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, size: 14),
            SizedBox(width: 8),
            _StepChip(title: "Service", done: true),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, size: 14),
            SizedBox(width: 8),
            _StepChip(title: "Confirm", active: true),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(
      IconData icon, String label, String value) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.deepPurple,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(label),
        subtitle: Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Confirm Booking"),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.check_circle),
              label: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text("Confirm Booking"),
              onPressed: _loading ? null : _confirmBooking,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _stepHeader(),
              const SizedBox(height: 20),

              _infoTile(
                Icons.store,
                "Garage",
                widget.garage.name,
              ),
              _infoTile(
                Icons.directions_car,
                "Vehicle",
                widget.vehicle.plateNumber,
              ),
              _infoTile(
                Icons.build,
                "Service",
                widget.service.name,
              ),
              _infoTile(
                Icons.payments,
                "Price",
                "₹ ${widget.service.price}",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= STEP CHIP =================
class _StepChip extends StatelessWidget {
  final String title;
  final bool active;
  final bool done;

  const _StepChip({
    required this.title,
    this.active = false,
    this.done = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor = active
        ? Colors.deepPurple
        : done
            ? Colors.green
            : Colors.grey.shade300;

    Color textColor =
        active || done ? Colors.white : Colors.black54;

    return Chip(
      backgroundColor: bgColor,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (done) ...[
            const Icon(Icons.check,
                size: 14, color: Colors.white),
            const SizedBox(width: 4),
          ],
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
