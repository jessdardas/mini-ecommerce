class Product {
  final int id;
  final String name;
  final double price;
  final String description;
  final int stock;
  final String imageUrl; 

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.stock,
    required this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      description: json['description'],
      stock: json['stock'],
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}
