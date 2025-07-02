import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final String description;
  final String imageUrl;
  final String category; 

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.category,
  });

  factory Product.fromDocument(DocumentSnapshot doc) {
    return Product(
      id: doc.id,
      name: doc['name'] ?? 'No Name',
      price: (doc['price'] ?? 0).toDouble(),
      description: doc['description'] ?? 'No description available',
      imageUrl: (doc.data() != null &&
              (doc.data() as Map<String, dynamic>).containsKey('imageUrl'))
          ? doc['imageUrl']
          : 'https://nbwjmjcsysehkhfwhqcz.supabase.co/storage/v1/object/public/img//load_image.jpg',
      category: doc['category'] ?? 'Uncategorized', 
    );
  }
}