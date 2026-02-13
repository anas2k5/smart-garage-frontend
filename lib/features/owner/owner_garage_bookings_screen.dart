import 'package:flutter/material.dart';
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

  // Global Brand Palette
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
    switch (status) {
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
    return (status == 'SUCCESS' || status == 'PAID') ? brandGreen : Colors.orangeAccent;
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
              tooltip: "Add Mechanic",
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
            if (!snap.hasData || snap.data!.isEmpty) {
              return _buildEmptyState();
            }

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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("BOOKING #${b.id}", 
                      style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    const SizedBox(height: 4),
                    Text(b.serviceTypeSafe, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
            const SizedBox(height: 16),
            _infoRow(Icons.directions_car_rounded, b.vehiclePlateSafe),
            _infoRow(Icons.person_rounded, b.customerEmailSafe),
            _infoRow(Icons.access_time_filled_rounded, b.bookingTimeFormatted),
            
            if (b.estimatedCost != null || b.finalCost != null) ...[
              const Divider(height: 24, color: Colors.white10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _costInfo("Estimated", b.estimatedCost, Colors.white38),
                  if (b.finalCost != null) _costInfo("Final Total", b.finalCost, brandGreen),
                ],
              ),
            ],
            
            const SizedBox(height: 16),
            _buildActionButtons(b),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: brandGreen.withOpacity(0.7)),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white60, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
  Future<void> _viewInvoice(int bookingId) async {
  try {
    final bytes =
        await ApiService.downloadInvoice(bookingId);

    // Simple viewer → open PDF preview dialog
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: surfaceDark,
        title: const Text("Invoice Downloaded"),
        content: const Text(
          "Invoice PDF downloaded successfully.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Failed to load invoice"),
      ),
    );
  }
}


  Widget _buildChip(String text, Color color, {bool isSmall = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: isSmall ? 2 : 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text.replaceAll("_", " "),
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: isSmall ? 9 : 11),
      ),
    );
  }

  Widget _costInfo(String label, double? amount, Color color) {
    if (amount == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold)),
        Text("₹${amount.toStringAsFixed(0)}", style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 16)),
      ],
    );
  }

  Widget _buildActionButtons(Booking b) {
    final List<Widget> actions = [];

    if (b.status == 'PENDING') {
      actions.add(_btn("Reject", Colors.redAccent, () => _updateStatus(b.id, 'CANCELLED'), isOutlined: true));
      actions.add(_btn("Accept", brandGreen, () => _updateStatus(b.id, 'ACCEPTED')));
    } else if (b.status == 'ACCEPTED' && b.mechanicName == null) {
      actions.add(_btn("Assign Mechanic", brandGreen, () => _openAssignMechanicSheet(b)));
    } else if (b.status == 'IN_PROGRESS' && b.finalCost != null) {
      actions.add(_btn("Finalize Service", brandGreen, () => _updateStatus(b.id, 'COMPLETED')));
    }

    if (['IN_PROGRESS', 'COMPLETED', 'PAID'].contains(b.status)) {
      actions.add(_btn("Job Card", Colors.white, () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => OwnerJobCardViewScreen(bookingId: b.id, garageId: widget.garage.id)));
      }, isOutlined: true));
    }
// 📄 VIEW INVOICE
if (b.status == 'PAID') {
  actions.add(
    _btn(
      "View Invoice",
      Colors.tealAccent,
      () => _viewInvoice(b.id),
      isOutlined: true,
    ),
  );
}

    if (actions.isEmpty) return const SizedBox.shrink();

    return Wrap(spacing: 8, runSpacing: 8, children: actions.map((w) => SizedBox(width: (MediaQuery.of(context).size.width - 64) / 2, child: w)).toList());
  }

  Widget _btn(String label, Color color, VoidCallback onTap, {bool isOutlined = false}) {
    return SizedBox(
      height: 40,
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
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            const Text("Select Mechanic", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...mechanics.map((m) => ListTile(
              leading: CircleAvatar(
                backgroundColor: brandGreen.withOpacity(0.1), 
                child: const Icon(Icons.engineering_rounded, color: brandGreen)
              ),
              // Updated to show name in title
              title: Text(
                m.name, 
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)
              ),
              // Updated to show phone in subtitle
              subtitle: Text(
                m.phone, 
                style: const TextStyle(color: Colors.white38)
              ),
              onTap: () async {
                await ApiService.assignMechanic(bookingId: booking.id, mechanicId: m.id);
                if (mounted) {
                  Navigator.pop(context);
                  _loadBookings();
                  setState(() {});
                }
              },
            )),
          ],
        ),
      ),
    );
  }

  Future<void> _updateStatus(int bookingId, String status) async {
    await ApiService.updateBookingStatus(bookingId: bookingId, status: status);
    _loadBookings();
    setState(() {});
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.event_busy_rounded, size: 64, color: Colors.white10),
          SizedBox(height: 16),
          Text("No active bookings", style: TextStyle(color: Colors.white38)),
        ],
      ),
    );
  }
}