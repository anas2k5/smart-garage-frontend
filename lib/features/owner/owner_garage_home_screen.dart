import 'package:flutter/material.dart';
import '../../models/garage.dart';
import 'owner_garage_bookings_screen.dart';
import 'manage_services_screen.dart';

class OwnerGarageHomeScreen extends StatelessWidget {
  final Garage garage;

  const OwnerGarageHomeScreen({super.key, required this.garage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(garage.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.receipt_long),
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
                        ManageServicesScreen(garage: garage),
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
