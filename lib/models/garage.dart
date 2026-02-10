import 'dart:math' as Math;

class Garage {
  final int id;
  final String name;
  final String address;
  final String phone;
  final bool active;

  // ✅ NEW (safe additions)
  final double? latitude;
  final double? longitude;

  Garage({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.active,
    this.latitude,
    this.longitude,
  });

  factory Garage.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] ?? json['garageId'];

    if (rawId == null) {
      throw Exception("Garage JSON missing id field: $json");
    }

    return Garage(
      id: rawId is int ? rawId : int.parse(rawId.toString()),
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      active: json['active'] ?? true,

      // ✅ Parse coordinates (SAFE)
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,

      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
    );
  }

  // ✅ Distance calculator (KM)
  double distanceFrom(double userLat, double userLng) {
    if (latitude == null || longitude == null) return 0;

    const double earthRadius = 6371; // KM

    final dLat = _degToRad(latitude! - userLat);
    final dLng = _degToRad(longitude! - userLng);

    final a =
        (Math.sin(dLat / 2) * Math.sin(dLat / 2)) +
        Math.cos(_degToRad(userLat)) *
            Math.cos(_degToRad(latitude!)) *
            (Math.sin(dLng / 2) * Math.sin(dLng / 2));

    final c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

    return earthRadius * c;
  }

  double _degToRad(double deg) => deg * (3.141592653589793 / 180);
}
