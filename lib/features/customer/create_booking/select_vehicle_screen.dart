import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../models/vehicle.dart';
import 'add_vehicle_screen.dart';
import 'select_garage_screen.dart';

class SelectVehicleScreen extends StatefulWidget {
  const SelectVehicleScreen({super.key});

  @override
  State<SelectVehicleScreen> createState() =>
      _SelectVehicleScreenState();
}

class _SelectVehicleScreenState extends State<SelectVehicleScreen> {
  late Future<List<Vehicle>> _vehiclesFuture;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  void _loadVehicles() {
    _vehiclesFuture = ApiService.getMyVehicles();
  }

  void _reload() {
    setState(() {
      _loadVehicles();
    });
  }

  // ================= DELETE VEHICLE =================
  Future<void> _deleteVehicle(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Vehicle"),
        content: const Text("This action cannot be undone"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ApiService.deleteVehicle(id);
      _reload();
    }
  }

  // ================= SAFE STEP HEADER =================
  Widget _stepHeader() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: const [
            _StepChip(title: "Vehicle", active: true),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, size: 14),
            SizedBox(width: 8),
            _StepChip(title: "Garage"),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, size: 14),
            SizedBox(width: 8),
            _StepChip(title: "Service"),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, size: 14),
            SizedBox(width: 8),
            _StepChip(title: "Confirm"),
          ],
        ),
      ),
    );
  }

  // ================= EMPTY STATE =================
  Widget _emptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.directions_car, size: 64, color: Colors.grey),
        SizedBox(height: 16),
        Text(
          "No vehicles yet",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 6),
        Text(
          "Add your first vehicle to book a service",
          style: TextStyle(color: Colors.black54),
        ),
      ],
    );
  }

  // ================= VEHICLE CARD =================
  Widget _vehicleCard(Vehicle v) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.deepPurple,
          child: Icon(Icons.directions_car, color: Colors.white),
        ),
        title: Text(
          v.plateNumber,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("${v.make} • ${v.model}"),
        trailing: PopupMenuButton(
          onSelected: (value) {
            if (value == 'delete') {
              _deleteVehicle(v.id);
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'delete',
              child: Text("Delete"),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SelectGarageScreen(
                selectedVehicle: v,
              ),
            ),
          );
        },
      ),
    );
  }

  // ================= MAIN UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Vehicle"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: "Add Vehicle",
            onPressed: () async {
              final added = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddVehicleScreen(),
                ),
              );

              if (added == true) _reload();
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Vehicle>>(
        future: _vehiclesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                "Failed to load vehicles",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          }

          final vehicles = snapshot.data ?? [];

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _stepHeader(),
                  const SizedBox(height: 16),

                  // ADD VEHICLE BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text("Add New Vehicle"),
                      onPressed: () async {
                        final added = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const AddVehicleScreen(),
                          ),
                        );

                        if (added == true) _reload();
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  Expanded(
                    child: vehicles.isEmpty
                        ? _emptyState()
                        : ListView.builder(
                            physics:
                                const BouncingScrollPhysics(),
                            itemCount: vehicles.length,
                            itemBuilder: (context, index) {
                              return _vehicleCard(
                                vehicles[index],
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ================= STEP CHIP =================
class _StepChip extends StatelessWidget {
  final String title;
  final bool active;

  const _StepChip({
    required this.title,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: active
            ? Colors.deepPurple
            : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(20),
        boxShadow: active
            ? [
                BoxShadow(
                  color:
                      Colors.deepPurple.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ]
            : [],
      ),
      child: Text(
        title,
        style: TextStyle(
          color: active ? Colors.white : Colors.black54,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
