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
  State<ConfirmBookingScreen> createState() => _ConfirmBookingScreenState();
}

class _ConfirmBookingScreenState extends State<ConfirmBookingScreen> {
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
        const SnackBar(content: Text("✅ Booking created successfully")),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const CustomerBookingsScreen(),
        ),
        (_) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Failed to create booking")),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Confirm Booking")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _info("Garage", widget.garage.name),
            _info("Vehicle", widget.vehicle.plateNumber),
            _info("Service", widget.service.name),
            _info("Price", "₹ ${widget.service.price}"),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _confirmBooking,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Confirm Booking"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
