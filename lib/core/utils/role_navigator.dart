import 'package:flutter/material.dart';
import '../../features/admin/admin_dashboard.dart';
import '../../features/customer/customer_dashboard.dart';
import '../../features/owner/owner_dashboard_screen.dart';

class RoleNavigator {
  // ================= EXISTING LOGIC (UNCHANGED) =================
  static Widget getHomeByRole(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN':
        return const AdminDashboard();
      case 'OWNER':
        return const OwnerDashboardScreen();
      case 'CUSTOMER':
      default:
        return const CustomerDashboard();
    }
  }

  // ================= NEW NAVIGATION HELPERS =================

  /// Replaces current screen with the user's home based on role
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

  /// Customer shortcut (fixes your missing method error)
  static void goToCustomerHome(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const CustomerDashboard(),
      ),
    );
  }

  /// Clears full stack and goes home (use for logout / JWT expiry)
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
