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

  @override
  void initState() {
    super.initState();
    _future = ApiService.getGarageServices(widget.garage.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Service")),
      body: FutureBuilder<List<GarageService>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Failed to load services"));
          }

          final services = snapshot.data ?? [];

          if (services.isEmpty) {
            return const Center(child: Text("No services available"));
          }

          return ListView.builder(
            itemCount: services.length,
            itemBuilder: (context, index) {
              final s = services[index];

              return Card(
                margin: const EdgeInsets.all(12),
                child: ListTile(
                  title: Text(
                    s.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(s.description ?? ''),
                  trailing: Text("₹ ${s.price}"),
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
                ),
              );
            },
          );
        },
      ),
    );
  }
}
