import 'package:intl/intl.dart';

class Booking {
  final int id;
  final String status;
  final String paymentStatus;

  final String? serviceType;
  final DateTime bookingTime;

  final String? garageName;
  final String? vehiclePlate;
  final String? customerEmail;

  final String? mechanicName;
  final String? mechanicPhone;

  final double? estimatedCost;
  final double? finalCost;
  final String? details;

  Booking({
    required this.id,
    required this.status,
    required this.paymentStatus,
    this.serviceType,
    required this.bookingTime,
    this.garageName,
    this.vehiclePlate,
    this.customerEmail,
    this.mechanicName,
    this.mechanicPhone,
    this.estimatedCost,
    this.finalCost,
    this.details,
  });

  // ----------------------------
  // SAFE UI GETTERS
  // ----------------------------
  String get garageNameSafe =>
      garageName?.isNotEmpty == true ? garageName! : "—";

  String get vehiclePlateSafe =>
      vehiclePlate?.isNotEmpty == true ? vehiclePlate! : "—";

  String get customerEmailSafe =>
      customerEmail?.isNotEmpty == true ? customerEmail! : "—";

  String get serviceTypeSafe =>
      serviceType?.isNotEmpty == true ? serviceType! : "—";

  String get mechanicNameSafe =>
      mechanicName?.isNotEmpty == true ? mechanicName! : "—";

  String get mechanicPhoneSafe =>
      mechanicPhone?.isNotEmpty == true ? mechanicPhone! : "—";

  // ----------------------------
  // DATE FORMATTER
  // ----------------------------
  String get bookingTimeFormatted {
    return DateFormat("dd MMM yyyy, hh:mm a")
        .format(bookingTime);
  }

  // ----------------------------
  // JSON MAPPER (FIXED)
  // ----------------------------
  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? 0,
      status: json['status'] ?? "UNKNOWN",
      paymentStatus: json['paymentStatus'] ?? "PENDING",

      serviceType: json['serviceType'],
      bookingTime: DateTime.parse(
          json['bookingTime'] ?? DateTime.now().toIso8601String()),

      garageName: json['garageName'],
      vehiclePlate: json['vehiclePlate'],
      customerEmail: json['customerEmail'],
      mechanicName: json['mechanicName'],
      mechanicPhone: json['mechanicPhone'],

      estimatedCost: json['estimatedCost'] != null
          ? (json['estimatedCost'] as num).toDouble()
          : null,

      finalCost: json['finalCost'] != null
          ? (json['finalCost'] as num).toDouble()
          : null,

      details: json['details'],
    );
  }
}
