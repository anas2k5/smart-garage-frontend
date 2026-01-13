import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/booking.dart';

import '../constants/api_constants.dart';
import '../../models/login_response.dart';
import '../../models/garage.dart';
import '../../models/vehicle.dart';
import '../../models/garage_service.dart';

class ApiService {
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

      // ✅ SAVE TOKEN
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', loginResponse.token);
      await prefs.setInt('userId', loginResponse.userId);
      await prefs.setString('role', loginResponse.role);

      print("✅ TOKEN SAVED => ${loginResponse.token}");
      return loginResponse;
    } else {
      throw Exception("Login failed");
    }
  }

 // ================= CUSTOMER BOOKINGS =================
static Future<List<Booking>> getCustomerBookings() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  final response = await http.get(
    Uri.parse('${ApiConstants.bookings}/me'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  print("📦 BOOKINGS STATUS => ${response.statusCode}");
  print("📦 BOOKINGS BODY => ${response.body}");

  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    return data.map((e) => Booking.fromJson(e)).toList();
  } else {
    throw Exception('Failed to load bookings');
  }
}


  // ================= CANCEL BOOKING =================
  static Future<void> cancelBooking(int bookingId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.put(
      Uri.parse('${ApiConstants.bookings}/$bookingId/status'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'status': 'CANCELLED'}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to cancel booking');
    }
  }

  // ================= FETCH GARAGES =================
  static Future<List<Garage>> getGarages() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse(ApiConstants.garages),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Garage.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load garages');
    }
  }

  // ================= FETCH MY VEHICLES =================
  static Future<List<Vehicle>> getMyVehicles() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse(ApiConstants.vehicles),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print("🚗 VEHICLES STATUS => ${response.statusCode}");
    print("🚗 VEHICLES BODY => ${response.body}");

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Vehicle.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load vehicles');
    }
  }

  // ================= FETCH GARAGE SERVICES =================
  static Future<List<GarageService>> getGarageServices(int garageId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('${ApiConstants.garages}/$garageId/services'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => GarageService.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load services');
    }
  }

  // ================= CREATE BOOKING (UPDATED) =================
  static Future<void> createBooking({
    required int garageId,
    required int vehicleId,
    required int serviceId,
    required DateTime bookingTime,
    String? details,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.post(
      Uri.parse(ApiConstants.bookings),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "garageId": garageId,
        "vehicleId": vehicleId,
        "serviceId": serviceId,
        "bookingTime": bookingTime.toIso8601String(),
        "details": details,
      }),
    );

    if (response.statusCode != 200) {
      print("❌ CREATE BOOKING FAILED => ${response.body}");
      throw Exception("Failed to create booking");
    }
  }
}
