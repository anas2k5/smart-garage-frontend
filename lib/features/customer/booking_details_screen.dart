import 'package:flutter/material.dart';
import '../../models/booking.dart';

class BookingDetailsScreen extends StatelessWidget {
  final Booking booking;

  const BookingDetailsScreen({
    super.key,
    required this.booking,
  });

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

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Booking Details")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------- BOOKING INFO ----------------
            _sectionTitle("Booking Info"),
            _infoRow("Booking ID", booking.id.toString()),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Status",
                    style: TextStyle(color: Colors.black54)),
                Chip(
                  label: Text(
                    booking.status,
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: _statusColor(booking.status),
                ),
              ],
            ),
            _infoRow("Service Type", booking.serviceType),
            _infoRow("Booking Time", booking.bookingTime),

            const Divider(height: 32),

            // ---------------- GARAGE ----------------
            _sectionTitle("Garage"),
            _infoRow("Garage Name", booking.garageName),

            const Divider(height: 32),

            // ---------------- VEHICLE ----------------
            _sectionTitle("Vehicle"),
            _infoRow("Vehicle Plate", booking.vehiclePlate),

            const Divider(height: 32),

            // ---------------- MECHANIC ----------------
            if (booking.mechanicName != null) ...[
              _sectionTitle("Mechanic"),
              _infoRow("Name", booking.mechanicName!),
              if (booking.mechanicPhone != null)
                _infoRow("Phone", booking.mechanicPhone!),
              const Divider(height: 32),
            ],

            // ---------------- COST ----------------
            _sectionTitle("Cost"),
            _infoRow(
              "Estimated Cost",
              booking.estimatedCost != null
                  ? booking.estimatedCost.toString()
                  : "N/A",
            ),
            _infoRow(
              "Final Cost",
              booking.finalCost != null
                  ? booking.finalCost.toString()
                  : "N/A",
            ),

            const Divider(height: 32),

            // ---------------- DETAILS ----------------
            if (booking.details != null) ...[
              _sectionTitle("Details"),
              Text(
                booking.details!,
                style: const TextStyle(color: Colors.black87),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
