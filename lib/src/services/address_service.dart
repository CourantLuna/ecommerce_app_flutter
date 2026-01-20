import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/src/models/address_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class AddressService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'profileappdb',
  );

  // 1. AGREGAR NUEVA DIRECCIÓN
  Future<bool> addAddress(AddressModel address) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Si es la primera dirección o se marca como default, quitar default a las demás
      if (address.isDefault) {
        await _clearDefaultAddresses(user.uid);
      }

      await _firestore
          .collection('addresses')
          .doc(user.uid)
          .collection('userAddresses')
          .add(address.toMap());

      return true;
    } catch (e) {
      print("Error agregando dirección: $e");
      return false;
    }
  }

  // 2. ACTUALIZAR DIRECCIÓN
  Future<bool> updateAddress(String addressId, AddressModel address) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Si se marca como default, quitar default a las demás
      if (address.isDefault) {
        await _clearDefaultAddresses(user.uid);
      }

      await _firestore
          .collection('addresses')
          .doc(user.uid)
          .collection('userAddresses')
          .doc(addressId)
          .update(address.toMap());

      return true;
    } catch (e) {
      print("Error actualizando dirección: $e");
      return false;
    }
  }

  // 3. ELIMINAR DIRECCIÓN
  Future<bool> deleteAddress(String addressId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await _firestore
          .collection('addresses')
          .doc(user.uid)
          .collection('userAddresses')
          .doc(addressId)
          .delete();

      return true;
    } catch (e) {
      print("Error eliminando dirección: $e");
      return false;
    }
  }

  // 4. OBTENER TODAS LAS DIRECCIONES (STREAM)
  Stream<List<AddressModel>> getAddressesStream() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      print('AddressService: No hay usuario autenticado');
      return Stream.value([]);
    }

    print('AddressService: Obteniendo direcciones para uid: $uid');

    return _firestore
        .collection('addresses')
        .doc(uid)
        .collection('userAddresses')
        .snapshots()
        .map((snapshot) {
          print(
            'AddressService: Snapshot recibido con ${snapshot.docs.length} documentos',
          );

          final addresses = snapshot.docs
              .map((doc) {
                try {
                  return AddressModel.fromSnapshot(doc);
                } catch (e) {
                  print('Error parseando documento ${doc.id}: $e');
                  return null;
                }
              })
              .whereType<AddressModel>()
              .toList();

          // Ordenar manualmente: primero las default, luego por fecha
          addresses.sort((a, b) {
            if (a.isDefault && !b.isDefault) return -1;
            if (!a.isDefault && b.isDefault) return 1;

            final aTime = a.createdAt?.millisecondsSinceEpoch ?? 0;
            final bTime = b.createdAt?.millisecondsSinceEpoch ?? 0;
            return bTime.compareTo(aTime); // Más reciente primero
          });

          print('AddressService: Retornando ${addresses.length} direcciones');
          return addresses;
        });
  }

  // 5. OBTENER DIRECCIÓN POR DEFECTO
  Future<AddressModel?> getDefaultAddress() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final snapshot = await _firestore
          .collection('addresses')
          .doc(user.uid)
          .collection('userAddresses')
          .where('isDefault', isEqualTo: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      return AddressModel.fromSnapshot(snapshot.docs.first);
    } catch (e) {
      print("Error obteniendo dirección default: $e");
      return null;
    }
  }

  // 6. ESTABLECER DIRECCIÓN COMO PREDETERMINADA
  Future<bool> setDefaultAddress(String addressId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Quitar default a todas
      await _clearDefaultAddresses(user.uid);

      // Establecer nueva default
      await _firestore
          .collection('addresses')
          .doc(user.uid)
          .collection('userAddresses')
          .doc(addressId)
          .update({
            'isDefault': true,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      return true;
    } catch (e) {
      print("Error estableciendo dirección default: $e");
      return false;
    }
  }

  // MÉTODO PRIVADO: Quitar default a todas las direcciones
  Future<void> _clearDefaultAddresses(String userId) async {
    final addresses = await _firestore
        .collection('addresses')
        .doc(userId)
        .collection('userAddresses')
        .where('isDefault', isEqualTo: true)
        .get();

    final batch = _firestore.batch();
    for (var doc in addresses.docs) {
      batch.update(doc.reference, {'isDefault': false});
    }
    await batch.commit();
  }

  // 7. OBTENER CANTIDAD DE DIRECCIONES
  Future<int> getAddressCount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 0;

      final snapshot = await _firestore
          .collection('addresses')
          .doc(user.uid)
          .collection('userAddresses')
          .get();

      return snapshot.docs.length;
    } catch (e) {
      print("Error contando direcciones: $e");
      return 0;
    }
  }
}
