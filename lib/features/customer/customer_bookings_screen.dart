import 'dart:ui';
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

  // Global Brand Palette
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
    switch (status.toUpperCase()) {
      case 'PAID': return brandGreen;
      case 'COMPLETED': return Colors.blueAccent;
      case 'WORKING':
      case 'IN_PROGRESS': return Colors.orangeAccent;
      case 'CANCELLED': return Colors.redAccent;
      case 'PENDING':
      case 'ACCEPTED': return Colors.white38;
      default: return Colors.white24;
    }
  }

  List<Booking> _applyFilter(List<Booking> bookings) {
    if (widget.statusFilter == null) return bookings;
    return bookings.where((b) => b.status == widget.statusFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.statusFilter == null ? "MY SERVICE HUB" : "${widget.statusFilter} HISTORY";

    return Theme(
      data: ThemeData.dark().copyWith(
        useMaterial3: true,
        scaffoldBackgroundColor: backgroundDark,
        appBarTheme: const AppBarTheme(backgroundColor: backgroundDark, elevation: 0),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(title, 
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2, color: brandGreen)),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Stack(
          children: [
            // Subtle Background Depth
            Positioned(
              top: -100,
              right: -50,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: brandGreen.withOpacity(0.03),
                ),
              ),
            ),
            RefreshIndicator(
              color: brandGreen,
              backgroundColor: surfaceDark,
              onRefresh: () async => _reload(),
              child: FutureBuilder<List<Booking>>(
                future: _bookingsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: brandGreen));
                  }

                  if (snapshot.hasError) return _buildErrorState();

                  final bookings = _applyFilter(snapshot.data ?? []);
                  if (bookings.isEmpty) return _buildEmptyState();

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    itemCount: bookings.length,
                    itemBuilder: (context, index) => _buildBookingCard(bookings[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(Booking booking) {
    final bool isCompleted = booking.status == 'COMPLETED';
    final bool isPaid = booking.paymentStatus == 'SUCCESS';
    final bool canCancel = booking.status == 'PENDING' || booking.status == 'ACCEPTED';
    final Color statusColor = _statusColor(booking.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => BookingDetailsScreen(booking: booking)),
          ),
          child: Stack(
            children: [
              // Left Accent Status Bar
              Positioned(
                left: 0, top: 0, bottom: 0,
                child: Container(width: 5, color: statusColor),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("ORDER #${booking.id}", 
                          style: const TextStyle(color: Colors.white24, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1)),
                        _buildStatusChip(booking.status),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(booking.garageNameSafe, 
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.settings_outlined, size: 14, color: brandGreen.withOpacity(0.7)),
                        const SizedBox(width: 8),
                        Text(booking.serviceTypeSafe, style: const TextStyle(color: Colors.white54, fontSize: 13)),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(height: 1, color: Colors.white10),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("ESTIMATED TOTAL", style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text("₹${booking.finalCost ?? '0.00'}", 
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: brandGreen)),
                          ],
                        ),
                        if (isPaid) _buildPaidBadge() 
                        else if (isCompleted && booking.finalCost != null) 
                          _buildMiniPayButton(booking)
                        else if (canCancel)
                          _buildCancelButton(booking.id),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(status.toUpperCase(), 
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
    );
  }

  Widget _buildPaidBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: brandGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.verified_rounded, color: brandGreen, size: 16),
          SizedBox(width: 6),
          Text("PAID", style: TextStyle(color: brandGreen, fontWeight: FontWeight.w900, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildMiniPayButton(Booking booking) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: brandGreen,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
      child: const Text("PAY NOW", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
    );
  }

  Widget _buildCancelButton(int id) {
    return TextButton.icon(
      icon: const Icon(Icons.close_rounded, size: 16, color: Colors.redAccent),
      label: const Text("CANCEL", style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold)),
      onPressed: () => _confirmCancel(context, id),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_late_outlined, size: 80, color: Colors.white.withOpacity(0.05)),
          const SizedBox(height: 24),
          Text(widget.statusFilter == null ? "NO ACTIVE BOOKINGS" : "NO ${widget.statusFilter} RECORDS",
              style: const TextStyle(color: Colors.white24, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off_rounded, color: Colors.redAccent, size: 48),
          const SizedBox(height: 16),
          const Text("SYNC ERROR", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
          TextButton(onPressed: _reload, child: const Text("RETRY CONNECTION", style: TextStyle(color: brandGreen))),
        ],
      ),
    );
  }

  Future<void> _confirmCancel(BuildContext context, int bookingId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: surfaceDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text("ABORT SERVICE?", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          content: const Text("Are you sure you want to remove this booking from the garage schedule?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("KEEP IT", style: TextStyle(color: Colors.white38))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () => Navigator.pop(context, true), 
              child: const Text("CONFIRM CANCEL")
            ),
          ],
        ),
      ),
    );
    if (confirmed == true) {
      await ApiService.cancelBooking(bookingId);
      _reload();
    }
  }
}