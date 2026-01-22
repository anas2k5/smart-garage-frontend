class Garage {
  final int id;
  final String name;
  final String address;
  final String phone;
  final bool active;

  Garage({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.active,
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
    );
  }
}
