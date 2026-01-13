import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../models/garage.dart';
import '../../../models/vehicle.dart';
import 'select_service_screen.dart';

class SelectGarageScreen extends StatefulWidget {
  final Vehicle selectedVehicle;

  const SelectGarageScreen({
    super.key,
    required this.selectedVehicle,
  });

  @override
  State<SelectGarageScreen> createState() => _SelectGarageScreenState();
}

class _SelectGarageScreenState extends State<SelectGarageScreen> {
  late Future<List<Garage>> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService.getGarages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Garage')),
      body: FutureBuilder<List<Garage>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load garages'));
          }

          final garages = snapshot.data ?? [];

          if (garages.isEmpty) {
            return const Center(child: Text('No garages available'));
          }

          return ListView.builder(
            itemCount: garages.length,
            itemBuilder: (context, index) {
              final g = garages[index];

              return Card(
                margin: const EdgeInsets.all(12),
                child: ListTile(
                  title: Text(g.name),
                  subtitle: Text(g.address),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SelectServiceScreen(
                          garage: g,
                          vehicle: widget.selectedVehicle,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
