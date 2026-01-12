class Vehicle {
  final int id;
  final String plateNumber;
  final String make;
  final String model;
  final int ownerId;
  final String? createdAt;

  Vehicle({
    required this.id,
    required this.plateNumber,
    required this.make,
    required this.model,
    required this.ownerId,
    this.createdAt,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      plateNumber: json['plateNumber'],
      make: json['make'],
      model: json['model'],
      ownerId: json['ownerId'],
      createdAt: json['createdAt'],
    );
  }
}
