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

  static const Color brandGreen = Color(0xFF00B562);
  static const Color surfaceDark = Color(0xFF1C1C1E);
  static const Color backgroundDark = Color(0xFF121212);

  DateTime? _selectedDate;
  String? _selectedSlot;

  // 🔥 NEW
  Map<String, int> _slotCounts = {};
  bool _loadingSlots = false;

  final List<String> _timeSlots = [
    "09:00",
    "11:00",
    "13:00",
    "15:00",
    "17:00",
  ];

  // ===============================
  // DATE PICKER + SLOT FETCH
  // ===============================
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _selectedSlot = null;
        _loadingSlots = true;
      });

      try {
        final data = await ApiService.getSlotAvailability(
          garageId: widget.garage.id,
          date: picked,
        );

        if (!mounted) return;

        setState(() {
          _slotCounts = data;
          _loadingSlots = false;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _slotCounts = {};
          _loadingSlots = false;
        });
      }
    }
  }

  // ===============================
  // CONFIRM BOOKING
  // ===============================
  Future<void> _confirmBooking() async {
    setState(() => _loading = true);

    if (_selectedDate == null || _selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select date and time slot"),
          backgroundColor: Colors.redAccent,
        ),
      );
      setState(() => _loading = false);
      return;
    }

    final hour = int.parse(_selectedSlot!.split(":")[0]);

    final bookingDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      hour,
      0,
    );

    try {
      await ApiService.createBooking(
        garageId: widget.garage.id,
        vehicleId: widget.vehicle.id,
        serviceId: widget.service.id,
        bookingTime: bookingDateTime,
        details: "Booked via Smart Garage Mobile",
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: brandGreen,
          content: Text(
            "✅ Booking Confirmed!",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const CustomerBookingsScreen()),
        (route) => route.isFirst,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text("❌ Connection error. Please try again."),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ===============================
  // BUILD
  // ===============================
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        useMaterial3: true,
        scaffoldBackgroundColor: backgroundDark,
        appBarTheme:
            const AppBarTheme(backgroundColor: backgroundDark, elevation: 0),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Final Review",
              style: TextStyle(fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        bottomNavigationBar: _buildBottomBar(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStepHeader(),
              const SizedBox(height: 32),
              const Text(
                "Review Your Selection",
                style: TextStyle(
                    color: Colors.white38,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.2),
              ),
              const SizedBox(height: 16),
              _buildSummaryCard(Icons.storefront_rounded,
                  "Selected Garage", widget.garage.name,
                  subtitle: widget.garage.address),
              _buildSummaryCard(Icons.directions_car_filled_rounded,
                  "Service Vehicle", widget.vehicle.plateNumber,
                  subtitle:
                      "${widget.vehicle.make} ${widget.vehicle.model}"),
              _buildSummaryCard(Icons.settings_suggest_rounded,
                  "Service Type", widget.service.name,
                  subtitle:
                      widget.service.description ?? "Standard Package"),
              const SizedBox(height: 24),
              _buildPriceBreakdown(),
              const SizedBox(height: 24),
              _buildScheduleSection(),
            ],
          ),
        ),
      ),
    );
  }

  // ===============================
  // SLOT SECTION
  // ===============================
  Widget _buildScheduleSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Select Date & Time",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 16),

          // DATE PICKER
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: backgroundDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedDate == null
                        ? "Choose Date"
                        : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                    style: const TextStyle(color: Colors.white),
                  ),
                  const Icon(Icons.calendar_today, size: 16),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // LOADING
          if (_loadingSlots)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            )
          else
            DropdownButtonFormField<String>(
              value: _selectedSlot,
              dropdownColor: surfaceDark,
              decoration: const InputDecoration(
                labelText: "Select Time Slot",
                border: OutlineInputBorder(),
              ),
              items: _timeSlots.map((slot) {
                final count = _slotCounts[slot] ?? 0;
                final isFull = count >= 3;

                return DropdownMenuItem(
                  value: isFull ? null : slot,
                  enabled: !isFull,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(slot),
                      if (isFull)
                        const Text("FULL",
                            style: TextStyle(color: Colors.redAccent))
                      else
                        Text("$count/3",
                            style:
                                const TextStyle(color: Colors.white54)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSlot = value;
                });
              },
            ),
        ],
      ),
    );
  }

  // ===============================
  // EXISTING METHODS (UNCHANGED)
  // ===============================
  Widget _buildSummaryCard(
      IconData icon, String label, String value,
      {String? subtitle}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: brandGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: brandGreen, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
                Text(value,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                if (subtitle != null)
                  Text(subtitle,
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdown() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: brandGreen.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: brandGreen.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Estimated Total",
                  style:
                      TextStyle(color: Colors.white70, fontSize: 14)),
              Text("Includes taxes",
                  style:
                      TextStyle(color: Colors.white38, fontSize: 10)),
            ],
          ),
          Text("₹${widget.service.price}",
              style: const TextStyle(
                  color: brandGreen,
                  fontSize: 24,
                  fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: surfaceDark,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: brandGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            onPressed: _loading ? null : _confirmBooking,
            child: _loading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : const Text("CONFIRM & BOOK SERVICE",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1)),
          ),
        ),
      ),
    );
  }

  Widget _buildStepHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        _StepChip(title: "Vehicle", isDone: true),
        _StepLine(isDone: true),
        _StepChip(title: "Garage", isDone: true),
        _StepLine(isDone: true),
        _StepChip(title: "Service", isDone: true),
        _StepLine(isDone: true),
        _StepChip(title: "Confirm", isActive: true),
      ],
    );
  }
}

class _StepChip extends StatelessWidget {
  final String title;
  final bool isActive;
  final bool isDone;

  const _StepChip(
      {required this.title, this.isActive = false, this.isDone = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isDone || isActive
                ? const Color(0xFF00B562)
                : Colors.white10,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              isDone ? Icons.check : Icons.circle,
              size: isDone ? 14 : 6,
              color: isDone || isActive
                  ? Colors.white
                  : Colors.white24,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(title,
            style: TextStyle(
                color: isDone || isActive
                    ? Colors.white
                    : Colors.white24,
                fontSize: 8,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _StepLine extends StatelessWidget {
  final bool isDone;
  const _StepLine({this.isDone = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 2,
      margin:
          const EdgeInsets.only(left: 4, right: 4, bottom: 12),
      color:
          isDone ? const Color(0xFF00B562) : Colors.white10,
    );
  }
}