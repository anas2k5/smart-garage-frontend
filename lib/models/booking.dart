class Booking {
  final int id;
  final String serviceType;
  final String status;
  final double estimatedCost;

  Booking({
    required this.id,
    required this.serviceType,
    required this.status,
    required this.estimatedCost,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      serviceType: json['serviceType'],
      status: json['status'],
      estimatedCost: (json['estimatedCost'] ?? 0).toDouble(),
    );
  }
}
