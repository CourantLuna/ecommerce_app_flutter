import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  // Tu base de datos específica
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'profileappdb', 
  );

  // 1. OBTENER DATOS EN TIEMPO REAL (STREAM)
  // Esto permite que si cambias la bio, se actualice sola en la pantalla anterior
  Stream<DocumentSnapshot> getUserStream() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return _firestore.collection('users').doc(uid).snapshots();
  }

  // 2. ACTUALIZAR DATOS DEL PERFIL
  Future<bool> updateProfileData({
    required String firstName,
    required String lastName,
    required String phone,
    required String bio,
    required String gender,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Actualizamos Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'bio': bio,
        'gender': gender,
      });

      // Actualizamos también el DisplayName de Auth (para que Google lo vea)
      await user.updateDisplayName("$firstName $lastName");
      await user.reload();

      return true;
    } catch (e) {
      print("Error actualizando perfil: $e");
      return false;
    }
  }

  // ... (MANTÉN TU MÉTODO updateProfilePhoto AQUÍ ABAJO IGUAL QUE ANTES) ...
   Future<String?> updateProfilePhoto(XFile imageFile) async {
      // ... tu código de foto que ya tenías ...
       try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final ref = _storage.ref().child('profile_pictures/${user.uid}/profile.jpg');
      
      if (kIsWeb) {
        final bytes = await imageFile.readAsBytes();
        await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      } else {
        await ref.putFile(File(imageFile.path));
      }

      final String downloadUrl = await ref.getDownloadURL();

      await user.updatePhotoURL(downloadUrl);
      await user.reload(); 

      await _firestore.collection('users').doc(user.uid).update({
        'photoUrl': downloadUrl,
      });

      return downloadUrl;
    } catch (e) {
      print("Error subiendo imagen en UserService: $e");
      return null;
    }
   }

  // 3. FAVORITOS - Agregar restaurante a favoritos
  Future<bool> addToFavorites(String restaurantId, Map<String, dynamic> restaurantData) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await _firestore
          .collection('favorites')
          .doc(user.uid)
          .collection('restaurants')
          .doc(restaurantId)
          .set({
        ...restaurantData,
        'addedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print("Error agregando a favoritos: $e");
      return false;
    }
  }

  // 4. FAVORITOS - Remover restaurante de favoritos
  Future<bool> removeFromFavorites(String restaurantId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await _firestore
          .collection('favorites')
          .doc(user.uid)
          .collection('restaurants')
          .doc(restaurantId)
          .delete();

      return true;
    } catch (e) {
      print("Error removiendo de favoritos: $e");
      return false;
    }
  }

  // 5. FAVORITOS - Verificar si un restaurante está en favoritos
  Future<bool> isFavorite(String restaurantId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final doc = await _firestore
          .collection('favorites')
          .doc(user.uid)
          .collection('restaurants')
          .doc(restaurantId)
          .get();

      return doc.exists;
    } catch (e) {
      print("Error verificando favorito: $e");
      return false;
    }
  }

  // 6. FAVORITOS - Obtener stream de favoritos en tiempo real
  Stream<QuerySnapshot> getFavoritesStream() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    
    return _firestore
        .collection('favorites')
        .doc(uid)
        .collection('restaurants')
        .orderBy('addedAt', descending: true)
        .snapshots();
  }

  // 7. FAVORITOS - Toggle (agregar o quitar según estado)
  Future<bool> toggleFavorite(String restaurantId, Map<String, dynamic> restaurantData) async {
    final isFav = await isFavorite(restaurantId);
    
    if (isFav) {
      return await removeFromFavorites(restaurantId);
    } else {
      return await addToFavorites(restaurantId, restaurantData);
    }
  }
}