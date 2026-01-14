import 'package:flutter/material.dart';
import 'package:smart_garage_app/models/garage.dart';
import 'owner_garage_bookings_screen.dart';
import 'owner_manage_services_screen.dart';

class OwnerGarageActionsScreen extends StatelessWidget {
  final Garage garage;

  const OwnerGarageActionsScreen({super.key, required this.garage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(garage.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.book_online),
              label: const Text("View Bookings"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        OwnerGarageBookingsScreen(garage: garage),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.build),
              label: const Text("Manage Services"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        OwnerManageServicesScreen(garage: garage),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
