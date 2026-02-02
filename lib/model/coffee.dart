class Product {
  final int id;
  final String name;
  final String category;
  final String brand;
  final Map<String, double> prices;
  final int discountPercent;
  final double rating;
  final int sugarPercent;
  final String description;
  final bool special;
  final String image;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.brand,
    required this.prices,
    required this.discountPercent,
    required this.rating,
    required this.sugarPercent,
    required this.description,
    required this.special,
    required this.image,
  });
factory Product.fromJson(Map<String, dynamic> json) {
  final rawPrices = json['prices'];

  return Product(
    id: json['id'] ?? 0,
    name: json['name'] ?? '',
    category: json['category'] ?? '',
    brand: json['brand'] ?? '',

    // ✅ SAFE MAP PARSING
    prices: rawPrices == null
        ? <String, double>{}
        : Map<String, double>.from(
            (rawPrices as Map).map(
              (key, value) => MapEntry(
                key.toString(),
                (value as num).toDouble(),
              ),
            ),
          ),

    discountPercent: json['discount_percent'] ?? 0,
    rating: (json['rating'] ?? 0).toDouble(),
    sugarPercent: json['sugar_percent'] ?? 0,
    description: json['description'] ?? '',
    special: json['special'] ?? false,
    image: json['image'] ?? '',
  );
}

}
