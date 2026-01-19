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

class _SelectVehicleScreenState
    extends State<SelectVehicleScreen> {
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

  Future<void> _deleteVehicle(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Vehicle"),
        content: const Text("Are you sure you want to delete this vehicle?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("No"),
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

  Widget _emptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.directions_car, size: 56, color: Colors.grey),
        SizedBox(height: 12),
        Text(
          "No vehicles yet",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        Text(
          "Add your first vehicle to book a service",
          style: TextStyle(color: Colors.black54),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Vehicle"),
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
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text("Failed to load vehicles"),
            );
          }

          final vehicles = snapshot.data ?? [];

          return Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // 🚀 ADD VEHICLE BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text("Add New Vehicle"),
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
                        _reload();
                      }
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // 🚗 VEHICLE LIST
                Expanded(
                  child: vehicles.isEmpty
                      ? _emptyState()
                      : ListView.builder(
                          itemCount: vehicles.length,
                          itemBuilder:
                              (context, index) {
                            final v =
                                vehicles[index];

                            return Card(
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.directions_car,
                                  color: Colors.deepPurple,
                                ),
                                title:
                                    Text(v.plateNumber),
                                subtitle: Text(
                                  "${v.make} • ${v.model}",
                                ),
                                trailing:
                                    PopupMenuButton(
                                  onSelected:
                                      (value) {
                                    if (value ==
                                        'delete') {
                                      _deleteVehicle(
                                          v.id);
                                    }
                                  },
                                  itemBuilder:
                                      (context) =>
                                          const [
                                    PopupMenuItem(
                                      value:
                                          'delete',
                                      child:
                                          Text("Delete"),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => SelectGarageScreen(
  selectedVehicle: v, // ✅ MATCHES CONSTRUCTOR
),

                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
