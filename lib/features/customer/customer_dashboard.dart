import 'package:flutter/material.dart';
import 'customer_bookings_screen.dart';
import '../../core/utils/auth_utils.dart';

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
        child: ElevatedButton(
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
      ),
    );
  }
}
