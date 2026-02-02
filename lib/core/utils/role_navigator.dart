import 'package:flutter/material.dart';
import '../../features/admin/admin_dashboard.dart';
import '../../features/customer/customer_dashboard.dart';
import '../../features/owner/owner_dashboard_screen.dart';
import '../../features/mechanic/mechanic_dashboard.dart';

class RoleNavigator {
  static Widget getHomeByRole(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN':
        return const AdminDashboard();
      case 'OWNER':
        return const OwnerDashboardScreen();
      case 'MECHANIC':
        return const MechanicDashboard();
      case 'CUSTOMER':
      default:
        return const CustomerDashboard();
    }
  }

  static void goToHomeByRole(
    BuildContext context, {
    required String role,
  }) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => getHomeByRole(role),
      ),
    );
  }

  static void resetToHomeByRole(
    BuildContext context, {
    required String role,
  }) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => getHomeByRole(role),
      ),
      (route) => false,
    );
  }
}
