import 'package:flutter/material.dart';
import '../../models/booking.dart';
import '../payments/payment_screen.dart';

class BookingDetailsScreen extends StatelessWidget {
  final Booking booking;

  const BookingDetailsScreen({
    super.key,
    required this.booking,
  });

  static const List<String> _steps = [
    "PENDING",
    "ACCEPTED",
    "IN_PROGRESS",
    "COMPLETED",
    "PAID",
  ];

  int _currentStepIndex() {
    return _steps.indexOf(booking.status);
  }

  bool _isCompleted(int index) {
    return index < _currentStepIndex();
  }

  bool _isCurrent(int index) {
    return index == _currentStepIndex();
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
      case 'PAID':
        return Colors.teal;
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
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  const TextStyle(color: Colors.black54)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    if (booking.status == "CANCELLED") {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius:
              BorderRadius.circular(12),
          border: Border.all(color: Colors.red),
        ),
        child: Row(
          children: const [
            Icon(Icons.cancel, color: Colors.red),
            SizedBox(width: 10),
            Text(
              "This booking has been cancelled",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children:
          List.generate(_steps.length, (index) {
        final bool completed =
            _isCompleted(index);
        final bool current =
            _isCurrent(index);

        Color dotColor = Colors.grey;
        if (completed) dotColor = Colors.green;
        if (current) dotColor = Colors.blue;

        return Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(
                      milliseconds: 300),
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dotColor,
                    boxShadow: current
                        ? [
                            BoxShadow(
                              color: dotColor
                                  .withOpacity(
                                      0.6),
                              blurRadius: 8,
                            )
                          ]
                        : [],
                  ),
                ),
                if (index !=
                    _steps.length - 1)
                  Container(
                    width: 2,
                    height: 30,
                    color: completed
                        ? Colors.green
                        : Colors.grey
                            .withOpacity(0.5),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Padding(
              padding:
                  const EdgeInsets.only(top: 2),
              child: Text(
                _steps[index]
                    .replaceAll("_", " "),
                style: TextStyle(
                  fontWeight: current
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: current
                      ? Colors.blue
                      : Colors.black87,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  bool _shouldShowPayButton() {
    return booking.finalCost != null &&
        booking.status == 'COMPLETED';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text("Booking Details")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            _sectionTitle("Booking Info"),
            _infoRow(
                "Booking ID", booking.id.toString()),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                const Text("Status",
                    style: TextStyle(
                        color: Colors.black54)),
                Chip(
                  label: Text(
                    booking.status,
                    style: const TextStyle(
                        color: Colors.white),
                  ),
                  backgroundColor:
                      _statusColor(booking.status),
                ),
              ],
            ),
            _infoRow(
                "Service Type",
                booking.serviceTypeSafe),
            _infoRow(
                "Booking Time",
                booking.bookingTimeFormatted),

            const Divider(height: 32),

            _sectionTitle("Booking Progress"),
            _buildTimeline(),

            const Divider(height: 32),

            _sectionTitle("Garage"),
            _infoRow("Garage Name",
                booking.garageNameSafe),

            const Divider(height: 32),

            _sectionTitle("Vehicle"),
            _infoRow("Vehicle Plate",
                booking.vehiclePlateSafe),

            const Divider(height: 32),

            if (booking.mechanicName != null) ...[
              _sectionTitle("Mechanic"),
              _infoRow("Name",
                  booking.mechanicNameSafe),
              _infoRow("Phone",
                  booking.mechanicPhoneSafe),
              const Divider(height: 32),
            ],

            _sectionTitle("Cost"),
            _infoRow(
              "Estimated Cost",
              booking.estimatedCost != null
                  ? "₹ ${booking.estimatedCost}"
                  : "N/A",
            ),
            _infoRow(
              "Final Cost",
              booking.finalCost != null
                  ? "₹ ${booking.finalCost}"
                  : "N/A",
            ),

            const Divider(height: 32),

            if (booking.details != null) ...[
              _sectionTitle("Details"),
              Text(
                booking.details!,
                style: const TextStyle(
                    color: Colors.black87),
              ),
              const Divider(height: 32),
            ],

            if (_shouldShowPayButton()) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon:
                      const Icon(Icons.payment),
                  label: const Text("Pay Now"),
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.green,
                    padding:
                        const EdgeInsets.symmetric(
                            vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            PaymentScreen(
                          booking: booking,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
