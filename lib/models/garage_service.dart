class GarageService {
  final int id;
  final String name;
  final String description;
  final double price;

  GarageService({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
  });

  factory GarageService.fromJson(Map<String, dynamic> json) {
    return GarageService(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
    );
  }
}
