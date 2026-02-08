import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../models/garage.dart';
import '../../../models/vehicle.dart';
import '../../../models/garage_service.dart';
import 'confirm_booking_screen.dart';

class SelectServiceScreen extends StatefulWidget {
  final Garage garage;
  final Vehicle vehicle;

  const SelectServiceScreen({
    super.key,
    required this.garage,
    required this.vehicle,
  });

  @override
  State<SelectServiceScreen> createState() => _SelectServiceScreenState();
}

class _SelectServiceScreenState extends State<SelectServiceScreen> {
  late Future<List<GarageService>> _future;
  final ScrollController _stepScroll = ScrollController();

  // Unified Design System Colors
  static const Color brandGreen = Color(0xFF00B562);
  static const Color surfaceDark = Color(0xFF1C1C1E);
  static const Color backgroundDark = Color(0xFF121212);

  @override
  void initState() {
    super.initState();
    _future = ApiService.getGarageServices(widget.garage.id);

    // Auto-scroll logic preserved for UX
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_stepScroll.hasClients) {
        _stepScroll.animateTo(
          120,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutQuart,
        );
      }
    });
  }

  @override
  void dispose() {
    _stepScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        useMaterial3: true,
        scaffoldBackgroundColor: backgroundDark,
        appBarTheme: const AppBarTheme(
          backgroundColor: backgroundDark,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Select Service", style: TextStyle(fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: FutureBuilder<List<GarageService>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: brandGreen));
            }

            if (snapshot.hasError) {
              return _buildErrorState();
            }

            final services = snapshot.data ?? [];

            return SafeArea(
              child: Column(
                children: [
                  _buildStepHeader(),
                  Expanded(
                    child: services.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                            physics: const BouncingScrollPhysics(),
                            itemCount: services.length,
                            itemBuilder: (context, index) => _serviceCard(services[index], index),
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStepHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: surfaceDark,
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: SingleChildScrollView(
        controller: _stepScroll,
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            _StepChip(title: "Vehicle", isDone: true),
            _StepLine(isDone: true),
            _StepChip(title: "Garage", isDone: true),
            _StepLine(isDone: true),
            _StepChip(title: "Service", isActive: true),
            _StepLine(),
            _StepChip(title: "Confirm"),
          ],
        ),
      ),
    );
  }

  Widget _serviceCard(GarageService s, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: surfaceDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ConfirmBookingScreen(
                  garage: widget.garage,
                  vehicle: widget.vehicle,
                  service: s,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: brandGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.build_circle_outlined, color: brandGreen, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        s.description ?? "Complete professional service",
                        style: const TextStyle(color: Colors.white54, fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: brandGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "₹${s.price}",
                    style: const TextStyle(color: brandGreen, fontWeight: FontWeight.w900, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.miscellaneous_services_rounded, size: 64, color: Colors.white10),
          SizedBox(height: 16),
          Text("No services available here", style: TextStyle(color: Colors.white38)),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off_rounded, size: 48, color: Colors.redAccent),
          const SizedBox(height: 16),
          const Text("Sync Error"),
          TextButton(
            onPressed: () => setState(() { _future = ApiService.getGarageServices(widget.garage.id); }),
            child: const Text("Retry", style: TextStyle(color: brandGreen)),
          ),
        ],
      ),
    );
  }
}

class _StepChip extends StatelessWidget {
  final String title;
  final bool isActive;
  final bool isDone;

  const _StepChip({required this.title, this.isActive = false, this.isDone = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isDone || isActive ? const Color(0xFF00B562) : Colors.white10,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              isDone ? Icons.check : Icons.circle,
              size: isDone ? 18 : 8,
              color: isDone || isActive ? Colors.white : Colors.white24,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            color: isDone || isActive ? Colors.white : Colors.white24,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
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
      width: 40,
      height: 2,
      // FIXED: Replaced 'marginBottom' with 'EdgeInsets.only'
      margin: const EdgeInsets.only(left: 8, right: 8, bottom: 15),
      color: isDone ? const Color(0xFF00B562) : Colors.white10,
    );
  }
}