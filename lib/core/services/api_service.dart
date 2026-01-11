import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/api_constants.dart';
import '../../models/login_response.dart';
import '../../models/garage.dart'; // ✅ REQUIRED for getGarages()

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
      return LoginResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Login failed");
    }
  }

  // ================= CUSTOMER BOOKINGS =================
  static Future<List<dynamic>> getCustomerBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('${ApiConstants.bookings}/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
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
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'status': 'CANCELLED',
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to cancel booking');
    }
  }

  // ================= FETCH GARAGES =================
  static Future<List<Garage>> getGarages() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  final url = ApiConstants.garages;
  print("➡️ GARAGES URL => $url");
  print("🔑 TOKEN => $token");

  final response = await http.get(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  print("⬅️ STATUS CODE => ${response.statusCode}");
  print("⬅️ RAW BODY => ${response.body}");

  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    return data.map((e) => Garage.fromJson(e)).toList();
  } else {
    throw Exception('Failed to load garages');
  }
}


}
