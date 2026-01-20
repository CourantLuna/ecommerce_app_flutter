import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/src/models/order_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class OrderService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'profileappdb',
  );

  // Crear un nuevo pedido
  Future<String?> createOrder(OrderModel order) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final docRef = await _firestore
          .collection('orders')
          .doc(user.uid)
          .collection('userOrders')
          .add(order.toMap());

      return docRef.id;
    } catch (e) {
      print('Error creando pedido: $e');
      return null;
    }
  }

  // Obtener pedidos del usuario
  Stream<List<OrderModel>> getOrdersStream() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value([]);

    return _firestore
        .collection('orders')
        .doc(uid)
        .collection('userOrders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();
    });
  }

  // Obtener un pedido específico
  Future<OrderModel?> getOrder(String orderId) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return null;

      final doc = await _firestore
          .collection('orders')
          .doc(uid)
          .collection('userOrders')
          .doc(orderId)
          .get();

      if (!doc.exists) return null;

      return OrderModel.fromFirestore(doc);
    } catch (e) {
      print('Error obteniendo pedido: $e');
      return null;
    }
  }

  // Actualizar estado del pedido
  Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return false;

      await _firestore
          .collection('orders')
          .doc(uid)
          .collection('userOrders')
          .doc(orderId)
          .update({'status': status});

      return true;
    } catch (e) {
      print('Error actualizando estado del pedido: $e');
      return false;
    }
  }

  // Cancelar pedido
  Future<bool> cancelOrder(String orderId) async {
    return await updateOrderStatus(orderId, 'cancelled');
  }
}
