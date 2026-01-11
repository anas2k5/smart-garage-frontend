import 'package:flutter/material.dart';
import '../../models/booking.dart';

class BookingDetailsScreen extends StatelessWidget {
  final Booking booking;

  const BookingDetailsScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _sectionTitle('Booking Info'),
            _row('Booking ID', booking.id.toString()),
            _row('Status', booking.status),
            _row('Service Type', booking.serviceType),
            _row('Booking Time', booking.bookingTime.toString()),

            const SizedBox(height: 16),

            _sectionTitle('Garage'),
            _row('Garage Name', booking.garageName),

            const SizedBox(height: 16),

            _sectionTitle('Vehicle'),
            _row('Vehicle Plate', booking.vehiclePlate),

            const SizedBox(height: 16),

            _sectionTitle('Mechanic'),
            _row('Name', booking.mechanicName ?? 'Not Assigned'),
            _row('Phone', booking.mechanicPhone ?? 'N/A'),

            const SizedBox(height: 16),

            _sectionTitle('Cost'),
            _row(
              'Estimated Cost',
              booking.estimatedCost?.toString() ?? 'Not Updated',
            ),
            _row(
              'Final Cost',
              booking.finalCost?.toString() ?? 'Not Updated',
            ),

            const SizedBox(height: 16),

            _sectionTitle('Details'),
            Text(
              booking.details.isEmpty ? 'No details provided' : booking.details,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Flexible(child: Text(value)),
        ],
      ),
    );
  }
}
