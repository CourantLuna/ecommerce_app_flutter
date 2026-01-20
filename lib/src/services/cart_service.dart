import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class CartService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'profileappdb', 
  );

  // 1. AGREGAR PRODUCTO AL CARRITO
  Future<bool> addToCart({
    required String productId,
    required Map<String, dynamic> productData,
    int quantity = 1,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final cartRef = _firestore
          .collection('carts')
          .doc(user.uid)
          .collection('items')
          .doc(productId);

      // Verificar si ya existe
      final doc = await cartRef.get();
      
      if (doc.exists) {
        // Si existe, incrementar cantidad
        final currentQuantity = doc.data()?['quantity'] ?? 1;
        await cartRef.update({
          'quantity': currentQuantity + quantity,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Si no existe, crear nuevo
        await cartRef.set({
          ...productData,
          'quantity': quantity,
          'addedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      return true;
    } catch (e) {
      print("Error agregando al carrito: $e");
      return false;
    }
  }

  // 2. REMOVER PRODUCTO DEL CARRITO
  Future<bool> removeFromCart(String productId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await _firestore
          .collection('carts')
          .doc(user.uid)
          .collection('items')
          .doc(productId)
          .delete();

      return true;
    } catch (e) {
      print("Error removiendo del carrito: $e");
      return false;
    }
  }

  // 3. ACTUALIZAR CANTIDAD DE PRODUCTO
  Future<bool> updateQuantity(String productId, int quantity) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      if (quantity <= 0) {
        return await removeFromCart(productId);
      }

      await _firestore
          .collection('carts')
          .doc(user.uid)
          .collection('items')
          .doc(productId)
          .update({
        'quantity': quantity,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print("Error actualizando cantidad: $e");
      return false;
    }
  }

  // 4. OBTENER STREAM DEL CARRITO
  Stream<QuerySnapshot> getCartStream() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    
    return _firestore
        .collection('carts')
        .doc(uid)
        .collection('items')
        .orderBy('addedAt', descending: true)
        .snapshots();
  }

  // 5. LIMPIAR TODO EL CARRITO
  Future<bool> clearCart() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final batch = _firestore.batch();
      final cartItems = await _firestore
          .collection('carts')
          .doc(user.uid)
          .collection('items')
          .get();

      for (var doc in cartItems.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      return true;
    } catch (e) {
      print("Error limpiando carrito: $e");
      return false;
    }
  }

  // 6. OBTENER TOTAL DEL CARRITO
  Future<double> getCartTotal() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 0.0;

      final cartItems = await _firestore
          .collection('carts')
          .doc(user.uid)
          .collection('items')
          .get();

      double total = 0.0;
      for (var doc in cartItems.docs) {
        final data = doc.data();
        final price = (data['price'] ?? 0.0).toDouble();
        final quantity = data['quantity'] ?? 1;
        total += price * quantity;
      }

      return total;
    } catch (e) {
      print("Error calculando total: $e");
      return 0.0;
    }
  }

  // 7. OBTENER CANTIDAD DE ITEMS EN EL CARRITO
  Future<int> getCartItemCount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 0;

      final cartItems = await _firestore
          .collection('carts')
          .doc(user.uid)
          .collection('items')
          .get();

      int totalCount = 0;
      for (var doc in cartItems.docs) {
        final quantity = doc.data()['quantity'] ?? 1;
        totalCount += quantity as int;
      }

      return totalCount;
    } catch (e) {
      print("Error contando items: $e");
      return 0;
    }
  }
}
