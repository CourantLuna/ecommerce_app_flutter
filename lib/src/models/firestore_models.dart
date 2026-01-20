import 'package:cloud_firestore/cloud_firestore.dart';

// Modelo para el Restaurante
class RestaurantModel {
  final String id;
  final String name;
  final String imageUrl;
  final String foodType;
  final double rating;
  final int ratingCount;
  final String deliveryTime;
  final String deliveryFee;
  final String address;
  final double latitude;
  final double longitude;
  final List<String> tags;

  RestaurantModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.foodType,
    required this.rating,
    required this.ratingCount,
    required this.deliveryTime,
    required this.deliveryFee,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.tags,
  });

  // Fábrica para crear el objeto desde Firebase
  factory RestaurantModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RestaurantModel(
      id: doc.id,
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      foodType: data['foodType'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      ratingCount: data['ratingCount'] ?? 0,
      deliveryTime: data['deliveryTime'] ?? '',
      deliveryFee: data['deliveryFee'] ?? '',
      address: data['address'] ?? '',
      latitude: (data['latitude'] ?? 18.4861).toDouble(),
      longitude: (data['longitude'] ?? -69.9312).toDouble(),
      tags: List<String>.from(data['tags'] ?? []),
    );
  }
}

// Modelo para el Plato (Producto)
class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
  });

  factory ProductModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? '',
    );
  }
}