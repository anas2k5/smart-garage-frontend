import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../models/vehicle.dart';
import 'add_vehicle_screen.dart';
import 'select_garage_screen.dart';

class SelectVehicleScreen extends StatefulWidget {
  const SelectVehicleScreen({super.key});

  @override
  State<SelectVehicleScreen> createState() => _SelectVehicleScreenState();
}

class _SelectVehicleScreenState extends State<SelectVehicleScreen> {
  late Future<List<Vehicle>> _vehiclesFuture;

  // 🔥 Refresh key added (no UI change)
  int _refreshKey = 0;

  static const Color brandGreen = Color(0xFF00B562);
  static const Color surfaceDark = Color(0xFF1C1C1E);
  static const Color backgroundDark = Color(0xFF121212);

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  void _loadVehicles() {
    _vehiclesFuture = ApiService.getMyVehicles();
  }

  // 🔥 Updated reload (force FutureBuilder refresh)
  void _reload() {
    setState(() {
      _refreshKey++; // forces rebuild
      _vehiclesFuture = ApiService.getMyVehicles();
    });
  }

  Future<void> _deleteVehicle(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: surfaceDark,
        title: const Text("Delete Vehicle"),
        content: const Text("This action cannot be undone"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel",
                style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete",
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ApiService.deleteVehicle(id);
      _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        useMaterial3: true,
        scaffoldBackgroundColor: backgroundDark,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Select Vehicle",
              style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: FutureBuilder<List<Vehicle>>(
          key: ValueKey(_refreshKey), // 🔥 refresh trigger
          future: _vehiclesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child:
                    CircularProgressIndicator(color: brandGreen),
              );
            }

            if (snapshot.hasError) {
              return const Center(
                  child: Text("Error loading vehicles"));
            }

            final vehicles = snapshot.data ?? [];

            return SafeArea(
              child: Column(
                children: [
                  _buildStepHeader(),
                  Expanded(
                    child: vehicles.isEmpty
                        ? _emptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: vehicles.length,
                            itemBuilder: (context, index) =>
                                _vehicleCard(
                                    vehicles[index]),
                          ),
                  ),
                  if (vehicles.isNotEmpty)
                    _buildAddFooter(),
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
      padding: const EdgeInsets.symmetric(
          vertical: 20, horizontal: 16),
      color: surfaceDark,
      child: const Row(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          _StepChip(title: "Vehicle", active: true),
          _StepLine(),
          _StepChip(title: "Garage"),
          _StepLine(),
          _StepChip(title: "Service"),
        ],
      ),
    );
  }

  Widget _vehicleCard(Vehicle v) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(
                horizontal: 20, vertical: 8),
        leading: const CircleAvatar(
          backgroundColor: Colors.white10,
          child: Icon(Icons.directions_car,
              color: brandGreen),
        ),
        title: Text(
          v.plateNumber,
          style: const TextStyle(
              fontWeight: FontWeight.bold),
        ),
        subtitle: Text("${v.make} ${v.model}"),
        trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 14),
        onLongPress: () =>
            _deleteVehicle(v.id),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                SelectGarageScreen(
                    selectedVehicle: v),
          ),
        ),
      ),
    );
  }

  Widget _buildAddFooter() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: brandGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(16),
            ),
          ),
          icon: const Icon(Icons.add),
          label:
              const Text("ADD NEW VEHICLE"),
          onPressed: () async {
            final added =
                await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const AddVehicleScreen(),
              ),
            );

            if (added == true) {
              _reload(); // 🔥 auto refresh
            }
          },
        ),
      ),
    );
  }

  Widget _emptyState() => Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(Icons.car_repair,
                size: 64,
                color: Colors.white10),
            const Text("No vehicles found"),
            const SizedBox(height: 20),
            _buildAddFooter(),
          ],
        ),
      );
}

class _StepChip extends StatelessWidget {
  final String title;
  final bool active;

  const _StepChip(
      {required this.title,
      this.active = false});

  @override
  Widget build(BuildContext context) =>
      Column(children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: active
                ? const Color(0xFF00B562)
                : Colors.white10,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              active
                  ? Icons.check
                  : Icons.circle,
              size: active ? 14 : 6,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            color: active
                ? Colors.white
                : Colors.white24,
            fontSize: 10,
          ),
        )
      ]);
}

class _StepLine extends StatelessWidget {
  const _StepLine();

  @override
  Widget build(BuildContext context) =>
      Container(
        width: 40,
        height: 2,
        margin: const EdgeInsets.only(
            left: 8,
            right: 8,
            bottom: 15),
        color: Colors.white10,
      );
}
