import 'package:flutter/material.dart';
import 'customer_bookings_screen.dart';
//import 'create_booking/select_garage_screen.dart';
 // ✅ ADD THIS
import '../../core/utils/auth_utils.dart';
import 'create_booking/select_vehicle_screen.dart';


class CustomerDashboard extends StatelessWidget {
  const CustomerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              AuthUtils.logout(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🔹 My Bookings
            ElevatedButton(
              child: const Text('My Bookings'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CustomerBookingsScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // 🔹 Book Service
           // 🔹 Book Service
ElevatedButton.icon(
  icon: const Icon(Icons.car_repair),
  label: const Text("Book Service"),
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SelectVehicleScreen(),
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
