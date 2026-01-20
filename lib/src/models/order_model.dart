import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String status; // pending, confirmed, preparing, delivering, delivered, cancelled
  final DateTime createdAt;
  final String? addressId;
  final String? addressName;
  final String? fullAddress;
  final String paymentMethodId;
  final String? paymentIntentId;
  final String? notes;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.status,
    required this.createdAt,
    this.addressId,
    this.addressName,
    this.fullAddress,
    required this.paymentMethodId,
    this.paymentIntentId,
    this.notes,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      items: (data['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      subtotal: (data['subtotal'] ?? 0.0).toDouble(),
      deliveryFee: (data['deliveryFee'] ?? 0.0).toDouble(),
      total: (data['total'] ?? 0.0).toDouble(),
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      addressId: data['addressId'],
      addressName: data['addressName'],
      fullAddress: data['fullAddress'],
      paymentMethodId: data['paymentMethodId'] ?? '',
      paymentIntentId: data['paymentIntentId'],
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'total': total,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
      'addressId': addressId,
      'addressName': addressName,
      'fullAddress': fullAddress,
      'paymentMethodId': paymentMethodId,
      'paymentIntentId': paymentIntentId,
      'notes': notes,
    };
  }
}

class OrderItem {
  final String productId;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final int quantity;
  final String restaurantName;

  OrderItem({
    required this.productId,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    required this.restaurantName,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      quantity: map['quantity'] ?? 1,
      restaurantName: map['restaurantName'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'price': price,
      'quantity': quantity,
      'restaurantName': restaurantName,
    };
  }
}
