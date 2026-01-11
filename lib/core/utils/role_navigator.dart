import 'package:flutter/material.dart';
import '../../features/admin/admin_dashboard.dart';
import '../../features/customer/customer_dashboard.dart';
import '../../features/owner/owner_dashboard.dart';

class RoleNavigator {
  static Widget getHomeByRole(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN':
        return const AdminDashboard();
      case 'OWNER':
        return const OwnerDashboard();
      case 'CUSTOMER':
        return const CustomerDashboard();
      default:
        return const CustomerDashboard();
    }
  }
}
