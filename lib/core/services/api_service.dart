import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/app_notification.dart';

import '../../models/booking.dart';
import '../../models/mechanic.dart';
import '../../models/login_response.dart';
import '../../models/garage.dart';
import '../../models/vehicle.dart';
import '../../models/garage_service.dart';
import '../constants/api_constants.dart';

class ApiService {
  // ================= CORE HELPERS =================

  static Future<String> _requireToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      throw Exception("Session expired. Please log in again.");
    }
    return token;
  }

  static Future<Map<String, String>> _authHeaders() async {
    final token = await _requireToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  static Exception _handleError(http.Response response) {
    print("❌ API ERROR ${response.statusCode} => ${response.body}");

    if (response.statusCode == 401) {
      return Exception("Session expired. Please log in again.");
    } else if (response.statusCode == 403) {
      return Exception("You are not authorized to perform this action.");
    } else {
      return Exception("Server error. Please try again later.");
    }
  }

  // ================= LOGIN =================

  static Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConstants.login),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final loginResponse = LoginResponse.fromJson(json);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', loginResponse.token);
      await prefs.setInt('userId', loginResponse.userId);
      await prefs.setString('role', loginResponse.role);

      return loginResponse;
    } else {
      throw _handleError(response);
    }
  }

  // ================= CUSTOMER DASHBOARD =================

  static Future<Map<String, dynamic>> getCustomerDashboard() async {
    final headers = await _authHeaders();

    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/dashboard/customer/me'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw _handleError(response);
    }
  }

  // ================= BOOKINGS =================

  static Future<List<Booking>> getCustomerBookings() async {
    final headers = await _authHeaders();

    final response = await http.get(
      Uri.parse('${ApiConstants.bookings}/me'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Booking.fromJson(e)).toList();
    } else {
      throw _handleError(response);
    }
  }

  static Future<void> createBooking({
    required int garageId,
    required int vehicleId,
    required int serviceId,
    required DateTime bookingTime,
    String? details,
  }) async {
    final headers = await _authHeaders();

    final response = await http.post(
      Uri.parse(ApiConstants.bookings),
      headers: headers,
      body: jsonEncode({
        "garageId": garageId,
        "vehicleId": vehicleId,
        "serviceId": serviceId,
        "bookingTime": bookingTime.toIso8601String(),
        "details": details,
      }),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw _handleError(response);
    }
  }

  static Future<void> cancelBooking(int bookingId) async {
    final headers = await _authHeaders();

    final response = await http.put(
      Uri.parse('${ApiConstants.bookings}/$bookingId/status'),
      headers: headers,
      body: jsonEncode({'status': 'CANCELLED'}),
    );

    if (response.statusCode != 200) {
      throw _handleError(response);
    }
  }

  // ================= GARAGES =================

  static Future<List<Garage>> getGarages() async {
    final headers = await _authHeaders();

    final response = await http.get(
      Uri.parse(ApiConstants.garages),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Garage.fromJson(e)).toList();
    } else {
      throw _handleError(response);
    }
  }

  static Future<List<Garage>> getOwnerGarages() async {
    final headers = await _authHeaders();

    final response = await http.get(
      Uri.parse('${ApiConstants.garages}/me'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Garage.fromJson(e)).toList();
    } else {
      throw _handleError(response);
    }
  }

  // ================= VEHICLES =================

  static Future<List<Vehicle>> getMyVehicles() async {
    final headers = await _authHeaders();

    final response = await http.get(
      Uri.parse(ApiConstants.vehicles),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Vehicle.fromJson(e)).toList();
    } else {
      throw _handleError(response);
    }
  }

  static Future<void> addVehicle({
    required String plateNumber,
    required String make,
    required String model,
  }) async {
    final headers = await _authHeaders();

    final response = await http.post(
      Uri.parse(ApiConstants.vehicles),
      headers: headers,
      body: jsonEncode({
        "plateNumber": plateNumber,
        "make": make,
        "model": model,
      }),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw _handleError(response);
    }
  }

  static Future<void> deleteVehicle(int vehicleId) async {
    final headers = await _authHeaders();

    final response = await http.delete(
      Uri.parse('${ApiConstants.vehicles}/$vehicleId'),
      headers: headers,
    );

    if (response.statusCode != 200 &&
        response.statusCode != 204) {
      throw _handleError(response);
    }
  }

  // ================= GARAGE SERVICES =================

  static Future<List<GarageService>> getGarageServices(
      int garageId) async {
    final headers = await _authHeaders();

    final response = await http.get(
      Uri.parse(
          '${ApiConstants.garages}/$garageId/services'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data
          .map((e) => GarageService.fromJson(e))
          .toList();
    } else {
      throw _handleError(response);
    }
  }

  static Future<void> addGarageService({
    required int garageId,
    required String name,
    required String description,
    required double price,
  }) async {
    final headers = await _authHeaders();

    final response = await http.post(
      Uri.parse(
          '${ApiConstants.baseUrl}/garages/$garageId/services'),
      headers: headers,
      body: jsonEncode({
        "name": name,
        "description": description,
        "price": price,
      }),
    );

    if (response.statusCode != 200) {
      throw _handleError(response);
    }
  }

  static Future<void> updateGarageService({
    required int serviceId,
    required String name,
    required String description,
    required double price,
  }) async {
    final headers = await _authHeaders();

    final response = await http.put(
      Uri.parse(
          '${ApiConstants.baseUrl}/garages/services/$serviceId'),
      headers: headers,
      body: jsonEncode({
        "name": name,
        "description": description,
        "price": price,
      }),
    );

    if (response.statusCode != 200) {
      throw _handleError(response);
    }
  }

  static Future<void> deactivateGarageService(
      int serviceId) async {
    final headers = await _authHeaders();

    final response = await http.put(
      Uri.parse(
          '${ApiConstants.baseUrl}/garages/services/$serviceId/deactivate'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw _handleError(response);
    }
  }

  // ================= OWNER BOOKINGS =================

  static Future<List<dynamic>> getBookingsByGarage(
      int garageId) async {
    final headers = await _authHeaders();

    final response = await http.get(
      Uri.parse(
          '${ApiConstants.bookings}/garage/$garageId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw _handleError(response);
    }
  }

  static Future<void> updateBookingStatus({
    required int bookingId,
    required String status,
  }) async {
    final headers = await _authHeaders();

    final response = await http.put(
      Uri.parse(
          '${ApiConstants.bookings}/$bookingId/status'),
      headers: headers,
      body: jsonEncode({"status": status}),
    );

    if (response.statusCode != 200) {
      throw _handleError(response);
    }
  }

  static Future<void> assignMechanic({
    required int bookingId,
    required int mechanicId,
  }) async {
    final headers = await _authHeaders();

    final response = await http.put(
      Uri.parse(
          '${ApiConstants.bookings}/$bookingId/assign?mechanicId=$mechanicId'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw _handleError(response);
    }
  }

  static Future<List<Mechanic>> getMechanicsByGarage(
      int garageId) async {
    final headers = await _authHeaders();

    final response = await http.get(
      Uri.parse(
          '${ApiConstants.baseUrl}/mechanics/garage/$garageId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data
          .map((e) => Mechanic.fromJson(e))
          .toList();
    } else {
      throw _handleError(response);
    }
  }

  // ================= COST UPDATES =================

  static Future<void> updateEstimatedCost({
    required int bookingId,
    required double estimatedCost,
  }) async {
    final headers = await _authHeaders();

    final response = await http.put(
      Uri.parse(
          '${ApiConstants.bookings}/$bookingId/estimated-cost'),
      headers: headers,
      body: jsonEncode({
        "estimatedCost": estimatedCost,
      }),
    );

    if (response.statusCode != 200) {
      throw _handleError(response);
    }
  }

  static Future<void> updateFinalCost({
    required int bookingId,
    required double finalCost,
  }) async {
    final headers = await _authHeaders();

    final response = await http.put(
      Uri.parse(
          '${ApiConstants.bookings}/$bookingId/final-cost'),
      headers: headers,
      body: jsonEncode({
        "finalCost": finalCost,
      }),
    );

    if (response.statusCode != 200) {
      throw _handleError(response);
    }
  }

  // ================= STRIPE PAYMENTS =================

  static Future<Map<String, dynamic>> initiatePayment({
    required int bookingId,
    required double amount,
  }) async {
    final headers = await _authHeaders();

    final response = await http.post(
      Uri.parse(
          '${ApiConstants.payments}/initiate/$bookingId'),
      headers: headers,
      body: jsonEncode({
        "amount": amount,
        "method": "CARD",
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw _handleError(response);
    }
  }

  static Future<Map<String, dynamic>> getPaymentStatus(
      int bookingId) async {
    final headers = await _authHeaders();

    final response = await http.get(
      Uri.parse(
          '${ApiConstants.payments}/status/$bookingId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw _handleError(response);
    }
  }

  static Future<List<dynamic>> getMyPayments() async {
    final headers = await _authHeaders();

    final response = await http.get(
      Uri.parse('${ApiConstants.payments}/me'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw _handleError(response);
    }
  }
  static Future<List<int>> downloadInvoice(
  int bookingId,
) async {

  final headers = await _authHeaders();

  final response = await http.get(
    Uri.parse(
      '${ApiConstants.baseUrl}/invoices/$bookingId/pdf',
    ),
    headers: headers,
  );

  if (response.statusCode == 200) {
    return response.bodyBytes;
  } else {
    throw _handleError(response);
  }
}

 // ================= REGISTER =================
static Future<void> register({
  required String fullName,
  required String email,
  required String password,
  required String role,
}) async {
  final response = await http.post(
    Uri.parse(ApiConstants.register),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'fullName': fullName,
      'email': email,
      'password': password,
      'role': role,
    }),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    return;
  } else {
    throw _handleError(response);
  }
}
// ================= OWNER DASHBOARD =================

static Future<Map<String, dynamic>> getOwnerDashboard() async {
  final headers = await _authHeaders();

  final response = await http.get(
    Uri.parse('${ApiConstants.baseUrl}/dashboard/owner/me'),
    headers: headers,
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw _handleError(response);
  }
}
// ================= ADMIN DASHBOARD =================
static Future<Map<String, dynamic>> getAdminDashboard() async {
  final headers = await _authHeaders();

  final response = await http.get(
    Uri.parse('${ApiConstants.baseUrl}/dashboard/admin/me'),
    headers: headers,
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw _handleError(response);
  }
}
static Future<List<dynamic>> getAllUsers() async {
  final headers = await _authHeaders();

  final response = await http.get(
    Uri.parse('${ApiConstants.baseUrl}/admin/users'),
    headers: headers,
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw _handleError(response);
  }
}
static Future<List<dynamic>> getAllGaragesAdmin() async {
  final headers = await _authHeaders();

  final response = await http.get(
    Uri.parse('${ApiConstants.baseUrl}/admin/garages'),
    headers: headers,
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw _handleError(response);
  }
}
static Future<void> toggleGarage(int garageId) async {
  final headers = await _authHeaders();

  final response = await http.put(
    Uri.parse('${ApiConstants.baseUrl}/admin/garages/$garageId/toggle'),
    headers: headers,
  );

  if (response.statusCode != 200) {
    throw _handleError(response);
  }
}
static Future<List<dynamic>> getAllBookingsAdmin() async {
  final headers = await _authHeaders();

  final response = await http.get(
    Uri.parse('${ApiConstants.baseUrl}/admin/bookings'),
    headers: headers,
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw _handleError(response);
  }
}

// ================= ADMIN - USER ACTIONS =================

static Future<void> disableUser(int userId) async {
  final headers = await _authHeaders();

  final response = await http.put(
    Uri.parse('${ApiConstants.baseUrl}/admin/users/$userId/disable'),
    headers: headers,
  );

  if (response.statusCode != 200) {
    throw _handleError(response);
  }
}

static Future<void> enableUser(int userId) async {
  final headers = await _authHeaders();

  final response = await http.put(
    Uri.parse('${ApiConstants.baseUrl}/admin/users/$userId/enable'),
    headers: headers,
  );

  if (response.statusCode != 200) {
    throw _handleError(response);
  }
}

// ================= ADMIN - AUDIT LOGS =================

static Future<List<dynamic>> getRecentAuditLogs() async {
  final headers = await _authHeaders();

  final response = await http.get(
    Uri.parse('${ApiConstants.baseUrl}/admin/audit/recent'),
    headers: headers,
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw _handleError(response);
  }
}

static Future<List<dynamic>> getAuditByEntity(
  String entityType,
  int entityId,
) async {
  final headers = await _authHeaders();

  final response = await http.get(
    Uri.parse(
      '${ApiConstants.baseUrl}/admin/audit/$entityType/$entityId',
    ),
    headers: headers,
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw _handleError(response);
  }
}
// ================= MECHANIC JOB CARDS =================

static Future<List<dynamic>> getMechanicJobs() async {
  final headers = await _authHeaders();

  final response = await http.get(
    Uri.parse('${ApiConstants.baseUrl}/jobcards/me'),
    headers: headers,
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw _handleError(response);
  }
}

static Future<void> addJobTask(
  int jobCardId,
  String description,
  double hours,
  double cost,
) async {
  final headers = await _authHeaders();

  final response = await http.post(
    Uri.parse('${ApiConstants.baseUrl}/jobcards/$jobCardId/tasks'),
    headers: headers,
    body: jsonEncode({
      "description": description,
      "hours": hours,
      "cost": cost,
    }),
  );

  if (response.statusCode != 200 && response.statusCode != 201) {
    throw _handleError(response);
  }
}

static Future<void> addJobPart(
  int jobCardId,
  String name,
  int quantity,
  double unitPrice,
) async {
  final headers = await _authHeaders();

  final response = await http.post(
    Uri.parse('${ApiConstants.baseUrl}/jobcards/$jobCardId/parts'),
    headers: headers,
    body: jsonEncode({
      "name": name,
      "quantity": quantity,
      "unitPrice": unitPrice,
    }),
  );

  if (response.statusCode != 200 && response.statusCode != 201) {
    throw _handleError(response);
  }
}

static Future<void> approveJobCard(int jobCardId) async {
  final headers = await _authHeaders();

  final response = await http.put(
    Uri.parse('${ApiConstants.baseUrl}/jobcards/$jobCardId/approve'),
    headers: headers,
  );

  if (response.statusCode != 200) {
    throw _handleError(response);
  }
}

static Future<void> closeJobCard(int jobCardId) async {
  final headers = await _authHeaders();

  final response = await http.put(
    Uri.parse('${ApiConstants.baseUrl}/jobcards/$jobCardId/close'),
    headers: headers,
  );

  if (response.statusCode != 200) {
    throw _handleError(response);
  }
}
// ================= UPDATE GARAGE =================
static Future<void> updateGarage({
  required int garageId,
  required String name,
  required String address,
  required String phone,
  double? latitude,
  double? longitude,
}) async {
  final headers = await _authHeaders();

  final response = await http.put(
    Uri.parse('${ApiConstants.garages}/$garageId'),
    headers: headers,
    body: jsonEncode({
      "name": name,
      "address": address,
      "phone": phone,
      "latitude": latitude,
      "longitude": longitude,
    }),
  );

  if (response.statusCode != 200) {
    throw _handleError(response);
  }
}

// ================= DELETE GARAGE =================
static Future<void> deleteGarage(int garageId) async {
  final headers = await _authHeaders();

  final response = await http.delete(
    Uri.parse('${ApiConstants.garages}/$garageId'),
    headers: headers,
  );

  if (response.statusCode != 200 && response.statusCode != 204) {
    throw _handleError(response);
  }
}

// ================= GET USER BY EMAIL =================
static Future<int> getUserIdByEmail(String email) async {
  final headers = await _authHeaders();

  final response = await http.get(
    Uri.parse(
      '${ApiConstants.baseUrl}/users/by-email?email=$email',
    ),
    headers: headers,
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['id'];
  } else {
    throw _handleError(response);
  }
}

// OWNER → GET GARAGE JOB CARDS
static Future<List<dynamic>> getGarageJobCards(int garageId) async {
  final headers = await _authHeaders();

  final response = await http.get(
    Uri.parse('${ApiConstants.baseUrl}/jobcards/garage/$garageId'),
    headers: headers,
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw _handleError(response);
  }
}
// ================= DELETE MECHANIC =================
static Future<void> deleteMechanic(int mechanicId) async {
  final headers = await _authHeaders();

  final response = await http.delete(
    Uri.parse(
      '${ApiConstants.baseUrl}/mechanics/$mechanicId',
    ),
    headers: headers,
  );

  if (response.statusCode != 200 &&
      response.statusCode != 204) {
    throw _handleError(response);
  }
}
static Future<void> updateMechanic(
    int id, Map<String, dynamic> body) async {

  final headers = await _authHeaders();

  final response = await http.put(
    Uri.parse(
      '${ApiConstants.baseUrl}/mechanics/$id',
    ),
    headers: headers,
    body: jsonEncode(body),
  );

  if (response.statusCode != 200) {
    throw _handleError(response);
  }
}
//notifi
static Future<List<AppNotification>> getMyNotifications() async {
  final headers = await _authHeaders();

  final response = await http.get(
    Uri.parse('${ApiConstants.baseUrl}/notifications/me'),
    headers: headers,
  );

  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);

    return data
        .map((e) => AppNotification.fromJson(e))
        .toList();
  } else {
    throw _handleError(response);
  }
}
// ================= MARK ALL READ =================
static Future<void> markAllNotificationsRead() async {
  final headers = await _authHeaders();

  final response = await http.put(
    Uri.parse('${ApiConstants.baseUrl}/notifications/read-all'),
    headers: headers,
  );

  if (response.statusCode != 200) {
    throw _handleError(response);
  }
}
// ================= MARK SINGLE READ =================
static Future<void> markNotificationRead(int id) async {
  final headers = await _authHeaders();

  final response = await http.put(
    Uri.parse('${ApiConstants.baseUrl}/notifications/$id/read'),
    headers: headers,
  );

  if (response.statusCode != 200) {
    throw _handleError(response);
  }
}// ================= UNREAD NOTIFICATION COUNT =================

// ================= UNREAD NOTIFICATION COUNT =================

static Future<int> getUnreadNotificationCount() async {

  final headers = await _authHeaders();

  final response = await http.get(
    Uri.parse(
      '${ApiConstants.baseUrl}/notifications/me/unread-count',
    ),
    headers: headers,
  );

  if (response.statusCode == 200) {
    return int.parse(response.body);
  } else {
    throw _handleError(response);
  }
}

static Future<void> confirmPayment({
  required int bookingId,
}) async {
  final headers = await _authHeaders();

  final response = await http.post(
    Uri.parse(
      '${ApiConstants.payments}/confirm/$bookingId',
    ),
    headers: headers,
  );

  if (response.statusCode != 200) {
    throw _handleError(response);
  }
}


}
