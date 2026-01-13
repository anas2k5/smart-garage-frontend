class Booking {
  final int id;
  final String status;
  final String? serviceType;
  final DateTime bookingTime;

  final String garageName;
  final String vehiclePlate;

  final String? mechanicName;
  final String? mechanicPhone;

  final double? estimatedCost;
  final double? finalCost;

  final String? details;

  Booking({
    required this.id,
    required this.status,
    this.serviceType,
    required this.bookingTime,
    required this.garageName,
    required this.vehiclePlate,
    this.mechanicName,
    this.mechanicPhone,
    this.estimatedCost,
    this.finalCost,
    this.details,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      status: json['status'],
      serviceType: json['serviceType'], // ✅ can be null
      bookingTime: DateTime.parse(json['bookingTime']), // ✅ FIX
      garageName: json['garageName'],
      vehiclePlate: json['vehiclePlate'],
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
