class ApiConstants {
 //static const String baseUrl = 'http://10.0.2.2:8080/api';
  static const String baseUrl = 'http://192.168.0.7:8080/api';
 //static const String baseUrl = 'https://smartgarage-backend.onrender.com/api';
  // AUTH
  static const String login = '$baseUrl/auth/login';

static const String register = '$baseUrl/auth/register';  
  // BOOKINGS
  static const String bookings = '$baseUrl/bookings';
  // 🏢 GARAGES
static const String garages = '$baseUrl/garages';
static const String vehicles = '$baseUrl/vehicles';

static const String payments = "$baseUrl/payments";
}
    