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
    final theme = Theme.of(context);

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
            padding: const EdgeInsets.all(12),
            itemCount: garages.length,
            itemBuilder: (context, index) {
              final g = garages[index];

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    child: Icon(Icons.garage,
                        color: theme.colorScheme.primary),
                  ),
                  title: Text(
                    g.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(g.address),
                  trailing: const Icon(Icons.chevron_right),
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
