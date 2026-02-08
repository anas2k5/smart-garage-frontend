import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../models/booking.dart';
import 'booking_details_screen.dart';
import '../payments/payment_screen.dart';

class CustomerBookingsScreen extends StatefulWidget {
  final String? statusFilter;

  const CustomerBookingsScreen({
    super.key,
    this.statusFilter,
  });

  @override
  State<CustomerBookingsScreen> createState() => _CustomerBookingsScreenState();
}

class _CustomerBookingsScreenState extends State<CustomerBookingsScreen> {
  late Future<List<Booking>> _bookingsFuture;

  // Professional Color Palette
  static const Color brandGreen = Color(0xFF00B562);
  static const Color surfaceDark = Color(0xFF1C1C1E);
  static const Color backgroundDark = Color(0xFF121212);

  @override
  void initState() {
    super.initState();
    _bookingsFuture = ApiService.getCustomerBookings();
  }

  void _reload() => setState(() => _bookingsFuture = ApiService.getCustomerBookings());

  Color _statusColor(String status) {
    switch (status) {
      case 'PAID': return brandGreen;
      case 'COMPLETED': return Colors.blueAccent;
      case 'IN_PROGRESS': return Colors.orangeAccent;
      case 'CANCELLED': return Colors.redAccent;
      case 'PENDING': return Colors.white38;
      default: return Colors.white24;
    }
  }

  List<Booking> _applyFilter(List<Booking> bookings) {
    if (widget.statusFilter == null) return bookings;
    return bookings.where((b) => b.status == widget.statusFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.statusFilter == null ? "My Bookings" : "${widget.statusFilter} History";

    return Theme(
      data: ThemeData.dark().copyWith(
        useMaterial3: true,
        scaffoldBackgroundColor: backgroundDark,
        appBarTheme: const AppBarTheme(backgroundColor: backgroundDark, elevation: 0),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: RefreshIndicator(
          color: brandGreen,
          onRefresh: () async => _reload(),
          child: FutureBuilder<List<Booking>>(
            future: _bookingsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: brandGreen));
              }

              if (snapshot.hasError) {
                return _buildErrorState();
              }

              final bookings = _applyFilter(snapshot.data ?? []);

              if (bookings.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                itemCount: bookings.length,
                itemBuilder: (context, index) => _buildBookingCard(bookings[index]),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBookingCard(Booking booking) {
    final bool isCompleted = booking.status == 'COMPLETED';
    final bool isPaid = booking.paymentStatus == 'SUCCESS';
    final bool canCancel = booking.status == 'PENDING' || booking.status == 'ACCEPTED';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => BookingDetailsScreen(booking: booking)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Order #${booking.id}", 
                      style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
                    _buildStatusChip(booking.status),
                  ],
                ),
                const SizedBox(height: 12),
                Text(booking.garageNameSafe, 
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                Text(booking.serviceTypeSafe, style: const TextStyle(color: Colors.white70)),
                const Divider(height: 24, color: Colors.white10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Total Amount", style: TextStyle(color: Colors.white38, fontSize: 12)),
                        Text("₹${booking.finalCost ?? 'N/A'}", 
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: brandGreen)),
                      ],
                    ),
                    if (isPaid) _buildPaidBadge(),
                  ],
                ),
                if (isCompleted && !isPaid && booking.finalCost != null) ...[
                  const SizedBox(height: 16),
                  _buildPayButton(booking),
                ],
                if (canCancel && !isPaid) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => _confirmCancel(context, booking.id),
                      child: const Text("Cancel Booking", style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _statusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _statusColor(status).withOpacity(0.5)),
      ),
      child: Text(status, 
        style: TextStyle(color: _statusColor(status), fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildPaidBadge() {
    return Row(
      children: const [
        Icon(Icons.check_circle, color: brandGreen, size: 16),
        SizedBox(width: 4),
        Text("PAID", style: TextStyle(color: brandGreen, fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }

  Widget _buildPayButton(Booking booking) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: brandGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        onPressed: () async {
          final paid = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PaymentScreen(booking: booking)),
          );
          if (paid == true) _reload();
        },
        child: const Text("PAY NOW", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_late_outlined, size: 64, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 16),
          Text(widget.statusFilter == null ? "No bookings yet" : "No ${widget.statusFilter} bookings",
              style: const TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
          const SizedBox(height: 16),
          const Text("Couldn't load your bookings"),
          TextButton(onPressed: _reload, child: const Text("Retry", style: TextStyle(color: brandGreen))),
        ],
      ),
    );
  }

  Future<void> _confirmCancel(BuildContext context, int bookingId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: surfaceDark,
        title: const Text("Cancel Booking?"),
        content: const Text("This service will be removed from the garage schedule."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Go Back", style: TextStyle(color: Colors.white54))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Confirm Cancel", style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
    if (confirmed == true) {
      await ApiService.cancelBooking(bookingId);
      _reload();
    }
  }
}