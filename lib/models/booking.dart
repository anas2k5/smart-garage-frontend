class Booking {
  final int id;

  final int garageId;
  final String garageName;

  final int customerId;
  final String customerEmail;

  final int vehicleId;
  final String vehiclePlate;

  final String serviceType;
  final String status;
  final String details;
  final DateTime bookingTime;

  final int? mechanicId;
  final String? mechanicName;
  final String? mechanicPhone;

  final double? estimatedCost;
  final double? finalCost;

  Booking({
    required this.id,
    required this.garageId,
    required this.garageName,
    required this.customerId,
    required this.customerEmail,
    required this.vehicleId,
    required this.vehiclePlate,
    required this.serviceType,
    required this.status,
    required this.details,
    required this.bookingTime,
    this.mechanicId,
    this.mechanicName,
    this.mechanicPhone,
    this.estimatedCost,
    this.finalCost,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      garageId: json['garageId'],
      garageName: json['garageName'],
      customerId: json['customerId'],
      customerEmail: json['customerEmail'],
      vehicleId: json['vehicleId'],
      vehiclePlate: json['vehiclePlate'],
      serviceType: json['serviceType'],
      status: json['status'],
      details: json['details'] ?? '',
      bookingTime: DateTime.parse(json['bookingTime']),
      mechanicId: json['mechanicId'],
      mechanicName: json['mechanicName'],
      mechanicPhone: json['mechanicPhone'],
      estimatedCost: json['estimatedCost']?.toDouble(),
      finalCost: json['finalCost']?.toDouble(),
    );
  }
}
