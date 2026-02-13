import 'package:flutter/material.dart';
import '../../models/booking.dart';
import '../payments/payment_screen.dart';

class BookingDetailsScreen extends StatelessWidget {
  final Booking booking;

  const BookingDetailsScreen({
    super.key,
    required this.booking,
  });

  // Theme Constants
  static const Color brandGreen = Color(0xFF00B562);
  static const Color surfaceDark = Color(0xFF1C1C1E);
  static const Color backgroundDark = Color(0xFF121212);

  static const List<String> _serviceSteps = [
    "PENDING",
    "ACCEPTED",
    "IN_PROGRESS",
    "COMPLETED",
  ];

  int _currentServiceStepIndex() => _serviceSteps.indexOf(booking.status);
  bool _isServiceCompleted(int index) => index < _currentServiceStepIndex();
  bool _isServiceCurrent(int index) => index == _currentServiceStepIndex();

  Color _statusColor(String status) {
    switch (status) {
      case 'PENDING': return Colors.orangeAccent;
      case 'ACCEPTED': return Colors.blueAccent;
      case 'IN_PROGRESS': return Colors.purpleAccent;
      case 'COMPLETED': return brandGreen;
      case 'CANCELLED': return Colors.redAccent;
      default: return Colors.white38;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        useMaterial3: true,
        scaffoldBackgroundColor: backgroundDark,
        appBarTheme: const AppBarTheme(backgroundColor: backgroundDark, elevation: 0),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Service Details", style: TextStyle(fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderSection(),
              const SizedBox(height: 24),
              _buildSectionTitle("Service Progress"),
              _buildTimelineCard(),
              const SizedBox(height: 24),
              _buildDetailCard(
                title: "Garage Information",
                icon: Icons.storefront_rounded,
                content: [
                  _infoRow("Name", booking.garageNameSafe),
                  if (booking.mechanicName != null) ...[
                    const Divider(color: Colors.white10, height: 20),
                    _infoRow("Mechanic", booking.mechanicNameSafe),
                    _infoRow("Contact", booking.mechanicPhoneSafe),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailCard(
                title: "Vehicle & Service",
                icon: Icons.directions_car_filled_rounded,
                content: [
                  _infoRow("Vehicle Plate", booking.vehiclePlateSafe),
                  _infoRow("Service Type", booking.serviceTypeSafe),
                  _infoRow("Booking Date", booking.bookingTimeFormatted),
                ],
              ),
              const SizedBox(height: 16),
              _buildCostCard(),
              if (booking.details != null) ...[
                const SizedBox(height: 24),
                _buildSectionTitle("Additional Notes"),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: surfaceDark, borderRadius: BorderRadius.circular(16)),
                  child: Text(booking.details!, style: const TextStyle(color: Colors.white70, height: 1.5)),
                ),
              ],
              const SizedBox(height: 32),
              if (_shouldShowPayButton(booking)) _buildPayNowButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("ORDER #${booking.id}", style: const TextStyle(color: Colors.white38, fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 4),
            Text(booking.serviceTypeSafe, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
        _buildStatusBadge(booking.status),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _statusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _statusColor(status).withOpacity(0.5)),
      ),
      child: Text(status, style: TextStyle(color: _statusColor(status), fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Widget _buildTimelineCard() {
    if (booking.status == "CANCELLED") {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.redAccent.withOpacity(0.2))),
        child: const Row(
          children: [
            Icon(Icons.cancel_rounded, color: Colors.redAccent),
            SizedBox(width: 12),
            Text("Service Cancelled", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: surfaceDark, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: List.generate(_serviceSteps.length, (index) {
          final bool isDone = _isServiceCompleted(index);
          final bool isCurrent = _isServiceCurrent(index);
          final Color stepColor = isDone || isCurrent ? brandGreen : Colors.white10;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCurrent ? brandGreen : (isDone ? brandGreen : Colors.transparent),
                      border: Border.all(color: isCurrent ? brandGreen : (isDone ? brandGreen : Colors.white24), width: 2),
                      boxShadow: isCurrent ? [BoxShadow(color: brandGreen.withOpacity(0.4), blurRadius: 8)] : [],
                    ),
                    child: isDone ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
                  ),
                  if (index != _serviceSteps.length - 1)
                    Container(width: 2, height: 30, color: isDone ? brandGreen : Colors.white10),
                ],
              ),
              const SizedBox(width: 16),
              Text(
                _serviceSteps[index].replaceAll("_", " "),
                style: TextStyle(
                  color: isCurrent ? Colors.white : (isDone ? Colors.white70 : Colors.white24),
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildDetailCard({required String title, required IconData icon, required List<Widget> content}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: surfaceDark, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: brandGreen, size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 16),
          ...content,
        ],
      ),
    );
  }
Widget _buildCostCard() {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [surfaceDark, surfaceDark.withOpacity(0.8)],
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: brandGreen.withOpacity(0.2),
      ),
    ),
    child: Column(
      children: [

        // 🔥 FINAL AMOUNT ONLY
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Final Amount",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              "₹${booking.finalCost ?? 'N/A'}",
              style: const TextStyle(
                color: brandGreen,
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
          ],
        ),

        // ✅ PAYMENT VERIFIED BADGE
        if (booking.paymentStatus == 'SUCCESS') ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 4,
              horizontal: 8,
            ),
            decoration: BoxDecoration(
              color: brandGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_user_rounded,
                  color: brandGreen,
                  size: 14,
                ),
                SizedBox(width: 4),
                Text(
                  "PAYMENT VERIFIED",
                  style: TextStyle(
                    color: brandGreen,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ]
      ],
    ),
  );
}

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white38, letterSpacing: 1)),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  bool _shouldShowPayButton(Booking b) => b.finalCost != null && b.status == 'COMPLETED' && b.paymentStatus != 'SUCCESS';

  Widget _buildPayNowButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: brandGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        icon: const Icon(Icons.account_balance_wallet_rounded),
        label: const Text("PROCEED TO PAYMENT", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
        onPressed: () async {
          final paid = await Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentScreen(booking: booking)));
          if (paid == true && context.mounted) Navigator.pop(context, true);
        },
      ),
    );
  }
}