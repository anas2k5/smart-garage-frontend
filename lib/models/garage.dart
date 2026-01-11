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
    return Garage(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      phone: json['phone'],
      active: json['active'],
    );
  }
}
