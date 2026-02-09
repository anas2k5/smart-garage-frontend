import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../models/booking.dart';
import '../../models/garage.dart';

class OwnerAllBookingsScreen extends StatefulWidget {
  final String? filter;

  const OwnerAllBookingsScreen({Key? key, this.filter}) : super(key: key);

  @override
  State<OwnerAllBookingsScreen> createState() => _OwnerAllBookingsScreenState();
}

class _OwnerAllBookingsScreenState extends State<OwnerAllBookingsScreen> {
  late Future<List<Booking>> _future;

  // Global Brand Palette
  static const Color brandGreen = Color(0xFF00B562);
  static const Color surfaceDark = Color(0xFF1C1C1E);
  static const Color backgroundDark = Color(0xFF121212);

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = _loadAllGaragesBookings();
  }

  Future<List<Booking>> _loadAllGaragesBookings() async {
    final garages = await ApiService.getOwnerGarages();
    final futures = garages.map(_fetchGarageBookings).toList();
    final results = await Future.wait(futures);

    final all = results.expand((e) => e).toList();
    all.sort((a, b) => b.bookingTime.compareTo(a.bookingTime));

    if (widget.filter == null) return all;
    return all.where((b) => b.status == widget.filter).toList();
  }

  Future<List<Booking>> _fetchGarageBookings(Garage g) async {
    final list = await ApiService.getBookingsByGarage(g.id);
    return list
        .map((e) {
          try {
            return Booking.fromJson(e);
          } catch (_) {
            return null;
          }
        })
        .whereType<Booking>()
        .toList();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'PAID': return brandGreen;
      case 'COMPLETED': return Colors.blueAccent;
      case 'IN_PROGRESS': return Colors.purpleAccent;
      case 'CANCELLED': return Colors.redAccent;
      case 'PENDING': return Colors.orangeAccent;
      case 'ACCEPTED': return Colors.cyanAccent;
      default: return Colors.white38;
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.filter == null ? "All Bookings" : "${widget.filter} Orders";

    return Theme(
      data: ThemeData.dark().copyWith(
        useMaterial3: true,
        scaffoldBackgroundColor: backgroundDark,
        appBarTheme: const AppBarTheme(backgroundColor: backgroundDark, elevation: 0),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: brandGreen),
              onPressed: () => setState(_load),
            )
          ],
        ),
        body: FutureBuilder<List<Booking>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: brandGreen));
            }

            if (snapshot.hasError) {
              return _buildErrorState();
            }

            final bookings = snapshot.data ?? [];

            if (bookings.isEmpty) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              color: brandGreen,
              onRefresh: () async => setState(_load),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                itemCount: bookings.length,
                itemBuilder: (context, index) => _buildBookingCard(bookings[index]),
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
              children: [
                Text("ORDER #${b.id}", 
                  style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                _buildStatusChip(b.status),
              ],
            ),
            const SizedBox(height: 12),
            Text(b.serviceTypeSafe, 
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            _infoLine(Icons.storefront_rounded, b.garageNameSafe),
            _infoLine(Icons.directions_car_rounded, b.vehiclePlateSafe),
            _infoLine(Icons.person_outline_rounded, b.customerEmailSafe),
            const Divider(height: 24, color: Colors.white10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCostInfo(b),
                if (b.mechanicName != null) _buildMechanicBadge(b),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoLine(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: brandGreen.withOpacity(0.7)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, 
              maxLines: 1, 
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white60, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(status, 
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildCostInfo(Booking b) {
    final isFinal = b.finalCost != null;
    final amount = isFinal ? b.finalCost! : (b.estimatedCost ?? 0.0);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(isFinal ? "FINAL COST" : "ESTIMATED", 
          style: const TextStyle(color: Colors.white24, fontSize: 9, fontWeight: FontWeight.bold)),
        Text("₹${amount.toStringAsFixed(0)}", 
          style: TextStyle(
            fontSize: 18, 
            fontWeight: FontWeight.w900, 
            color: isFinal ? brandGreen : Colors.orangeAccent
          )),
      ],
    );
  }

  Widget _buildMechanicBadge(Booking b) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          const Icon(Icons.engineering_rounded, size: 14, color: Colors.white38),
          const SizedBox(width: 6),
          Text(b.mechanicNameSafe, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 64, color: Colors.white10),
          const SizedBox(height: 16),
          Text(widget.filter == null ? "No bookings found" : "No ${widget.filter} bookings",
              style: const TextStyle(color: Colors.white38)),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),
          const SizedBox(height: 16),
          const Text("Sync Failed"),
          TextButton(onPressed: () => setState(_load), child: const Text("Retry", style: TextStyle(color: brandGreen))),
        ],
      ),
    );
  }
}