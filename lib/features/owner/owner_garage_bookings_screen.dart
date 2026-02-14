import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

import '../../core/services/api_service.dart';
import '../../models/booking.dart';
import '../../models/garage.dart';
import '../../models/mechanic.dart';
import 'add_mechanic_screen.dart';
import 'owner_jobcard_view_screen.dart';

class OwnerGarageBookingsScreen extends StatefulWidget {
  final Garage garage;

  const OwnerGarageBookingsScreen({
    super.key,
    required this.garage,
  });

  @override
  State<OwnerGarageBookingsScreen> createState() => _OwnerGarageBookingsScreenState();
}

class _OwnerGarageBookingsScreenState extends State<OwnerGarageBookingsScreen> {
  late Future<List<Booking>> _future;

  static const Color brandGreen = Color(0xFF00B562);
  static const Color surfaceDark = Color(0xFF1C1C1E);
  static const Color backgroundDark = Color(0xFF121212);

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
    switch (status.toUpperCase()) {
      case 'PENDING': return Colors.orangeAccent;
      case 'ACCEPTED': return Colors.blueAccent;
      case 'IN_PROGRESS': return Colors.purpleAccent;
      case 'COMPLETED': return brandGreen;
      case 'PAID': return Colors.tealAccent;
      case 'CANCELLED': return Colors.redAccent;
      default: return Colors.white38;
    }
  }

  Color _paymentColor(String status) {
    return (status.toUpperCase() == 'SUCCESS' || status.toUpperCase() == 'PAID') 
        ? brandGreen : Colors.orangeAccent;
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
          title: Text(widget.garage.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.person_add_alt_1_rounded, color: brandGreen),
              onPressed: () async {
                final added = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddMechanicScreen(garage: widget.garage)),
                );
                if (added == true) setState(_loadBookings);
              },
            ),
          ],
        ),
        body: FutureBuilder<List<Booking>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: brandGreen));
            }
            if (!snap.hasData || snap.data!.isEmpty) return _buildEmptyState();

            final list = snap.data!;
            return RefreshIndicator(
              color: brandGreen,
              onRefresh: () async => setState(_loadBookings),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: list.length,
                itemBuilder: (_, i) => _buildBookingCard(list[i]),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBookingCard(Booking b) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Booking ID + Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("BOOKING #${b.id}", 
                      style: const TextStyle(color: Colors.white24, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    const SizedBox(height: 4),
                    Text(b.serviceTypeSafe, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildChip(b.status, _statusColor(b.status)),
                    const SizedBox(height: 6),
                    _buildChip("PAY: ${b.paymentStatus}", _paymentColor(b.paymentStatus), isSmall: true),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Info Block
            _infoRow(Icons.directions_car_rounded, b.vehiclePlateSafe),
            _infoRow(Icons.person_rounded, b.customerEmailSafe),
            _infoRow(Icons.access_time_filled_rounded, b.bookingTimeFormatted),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1, color: Colors.white10),
            ),

            // Bottom Section: Buttons aligned with Amount
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Action Buttons on the Left
                Expanded(
                  child: Column(
                    children: _buildActionList(b),
                  ),
                ),
                const SizedBox(width: 16),
                // Final Total on the Right
                _costInfo(b),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActionList(Booking b) {
    List<Widget> buttons = [];
    
    // Status Logic
    if (b.status == 'PENDING') {
      buttons.add(_btn("Accept Order", brandGreen, () => _updateStatus(b.id, 'ACCEPTED')));
    } else if (b.status == 'ACCEPTED' && b.mechanicName == null) {
      buttons.add(_btn("Assign Mechanic", brandGreen, () => _openAssignMechanicSheet(b)));
    }

    // Job Card (Always show if relevant status)
    if (['IN_PROGRESS', 'COMPLETED', 'PAID'].contains(b.status)) {
      buttons.add(_btn("Job Card", Colors.white, () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => OwnerJobCardViewScreen(bookingId: b.id, garageId: widget.garage.id)));
      }, isOutlined: true));
    }

    // Invoice
    if (b.paymentStatus == 'SUCCESS' || b.paymentStatus == 'PAID') {
      if (buttons.isNotEmpty) buttons.add(const SizedBox(height: 8));
      buttons.add(_btn("View Invoice", Colors.tealAccent, () => _viewInvoice(b.id), isOutlined: true));
    }

    return buttons;
  }

  Widget _costInfo(Booking b) {
    if (b.finalCost == null && b.estimatedCost == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(b.finalCost != null ? "Final Total" : "Estimated", 
          style: const TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold)),
        Text("₹${(b.finalCost ?? b.estimatedCost)!.toStringAsFixed(0)}", 
          style: TextStyle(color: b.finalCost != null ? brandGreen : Colors.white70, 
          fontWeight: FontWeight.w900, fontSize: 22)),
      ],
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 14, color: brandGreen.withOpacity(0.6)),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white60, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _btn(String label, Color color, VoidCallback onTap, {bool isOutlined = false}) {
    return SizedBox(
      width: double.infinity,
      height: 42,
      child: isOutlined
          ? OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                side: BorderSide(color: color.withOpacity(0.5)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: onTap,
              child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            )
          : ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: onTap,
              child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
    );
  }

  Widget _buildChip(String text, Color color, {bool isSmall = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: isSmall ? 2 : 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(text.replaceAll("_", " "),
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: isSmall ? 9 : 10)),
    );
  }

  // API Logic (Unchanged but modular)
  Future<void> _updateStatus(int bookingId, String status) async {
    await ApiService.updateBookingStatus(bookingId: bookingId, status: status);
    _loadBookings();
    setState(() {});
  }

  void _openAssignMechanicSheet(Booking booking) async {
    final mechanics = await ApiService.getMechanicsByGarage(widget.garage.id);
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceDark,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: mechanics.map((m) => ListTile(
            leading: CircleAvatar(backgroundColor: brandGreen.withOpacity(0.1), child: const Icon(Icons.engineering, color: brandGreen)),
            title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            onTap: () async {
              await ApiService.assignMechanic(bookingId: booking.id, mechanicId: m.id);
              Navigator.pop(context);
              _loadBookings();
              setState(() {});
            },
          )).toList(),
        ),
      ),
    );
  }

  Future<void> _viewInvoice(int bookingId) async {
    try {
      final bytes = await ApiService.downloadInvoice(bookingId);
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/invoice-$bookingId.pdf');
      await file.writeAsBytes(bytes, flush: true);
      await OpenFilex.open(file.path);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error loading invoice")));
    }
  }

  Widget _buildEmptyState() => const Center(child: Text("No active bookings", style: TextStyle(color: Colors.white24)));
}