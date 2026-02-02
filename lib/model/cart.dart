class Cart {
  final int dbId;        // cart_items.id (DB id)
  final int productId;
  final String name;
  final String size;
  final String sugar;
  final double price;
  int qty;
  double total;
  final String img;

  Cart({
    required this.dbId,
    required this.productId,
    required this.name,
    required this.size,
    required this.sugar,
    required this.price,
    required this.qty,
    required this.total,
    required this.img,
  });

  /// FROM API JSON
  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      dbId: json['id'],
      productId: json['product_id'],
      name: json['name'],
      size: json['size'],
      sugar: json['sugar'],
      price: (json['price'] as num).toDouble(),
      qty: json['qty'],
      total: (json['total'] as num).toDouble(),
      img: json['image'],
    );
  }

  /// TO API JSON (ADD TO CART)
  Map<String, dynamic> toJson(String sessionId) {
    return {
      "session_id": sessionId,
      "product_id": productId,
      "name": name,
      "size": size,
      "sugar": sugar,
      "price": price,
      "qty": qty,
      "image": img,
    };
  }
   Cart copyWith({
    int? dbId,
    int? productId,
    String? name,
    String? size,
    String? sugar,
    double? price,
    int? qty,
    double? total,
    String? img,
  }) {
    return Cart(
      dbId: dbId ?? this.dbId,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      size: size ?? this.size,
      sugar: sugar ?? this.sugar,
      price: price ?? this.price,
      qty: qty ?? this.qty,
      total: total ?? this.total,
      img: img ?? this.img,
    );
  }
}
