import 'package:flutter/material.dart';
import 'package:smart_garage_app/models/garage.dart';
import 'owner_garage_bookings_screen.dart';
import 'owner_manage_services_screen.dart';

class OwnerGarageActionsScreen extends StatelessWidget {
  final Garage garage;

  const OwnerGarageActionsScreen({super.key, required this.garage});

  Widget _actionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor:
                    theme.colorScheme.primary.withOpacity(0.15),
                child: Icon(icon, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(garage.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _actionCard(
              context: context,
              icon: Icons.receipt_long,
              title: "View Bookings",
              subtitle: "Manage all service bookings",
              onTap: () {
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
            _actionCard(
              context: context,
              icon: Icons.build,
              title: "Manage Services",
              subtitle: "Add, edit, or disable services",
              onTap: () {
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
