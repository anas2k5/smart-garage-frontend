class Mechanic {
  final int id;
  final String name;
  final String phone;

  Mechanic({
    required this.id,
    required this.name,
    required this.phone,
  });

  factory Mechanic.fromJson(Map<String, dynamic> json) {
    return Mechanic(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
    );
  }
}
