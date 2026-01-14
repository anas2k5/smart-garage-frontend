import 'package:flutter/material.dart';
import 'package:smart_garage_app/core/services/api_service.dart';
import 'package:smart_garage_app/models/garage.dart';
import 'owner_garage_actions_screen.dart';

class OwnerGaragesScreen extends StatefulWidget {
  const OwnerGaragesScreen({super.key});

  @override
  State<OwnerGaragesScreen> createState() => _OwnerGaragesScreenState();
}

class _OwnerGaragesScreenState extends State<OwnerGaragesScreen> {
  late Future<List<Garage>> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService.getOwnerGarages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Garages")),
      body: FutureBuilder<List<Garage>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Failed to load garages"));
          }

          final garages = snapshot.data ?? [];

          if (garages.isEmpty) {
            return const Center(child: Text("No garages found"));
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
                        builder: (_) =>
                            OwnerGarageActionsScreen(garage: g),
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
