import 'package:firebase_core/firebase_core.dart'; // Import necesario para Firebase.app()
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ecommerce_app/src/services/stripe_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Tu base de datos específica
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(), 
    databaseId: 'profileappdb', 
  );

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  // --- REGISTRO (Igual que antes) ---
  Future<User?> register({
    required String email, 
    required String password, 
    required String firstName, 
    required String lastName,
    required String phone
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email, password: password
      );
      
      User? user = result.user;
      
      if (user != null) {
        String fullName = "$firstName $lastName";
        await user.updateDisplayName(fullName);
        
        String encodedName = Uri.encodeComponent(fullName);
        String defaultPhoto = "https://ui-avatars.com/api/?name=$encodedName&background=random&color=fff&size=150";
        await user.updatePhotoURL(defaultPhoto);
        await user.reload();
        user = _auth.currentUser;

        // Guardado inicial
        await _saveUserToFirestore(
          uid: user!.uid,
          email: email,
          firstName: firstName,
          lastName: lastName,
          phone: phone,
          photoUrl: defaultPhoto,
          authProvider: 'email'
        );

        // Crear perfil de Stripe
        await StripeService().ensureStripeCustomer(user);
      }
      return user;
    } catch (e) {
      print("Error Registro: $e");
      return null;
    }
  }

  // --- LOGIN CON CORREO (ACTUALIZADO CON VERIFICACIÓN) ---
  Future<User?> login(String email, String password) async {
    try {
      // 1. Login normal en Auth
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email, password: password
      );

      // 2. ¡AQUÍ ESTÁ LA VALIDACIÓN!
      // Si entra, verificamos si tiene perfil en la DB. Si no, lo crea.
      if (result.user != null) {
        await _checkAndCreateMissingProfile(result.user!, provider: 'email');
        // Verificar y crear perfil de Stripe si no existe
        await StripeService().ensureStripeCustomer(result.user!);
      }

      return result.user;
    } catch (e) {
      print("Error Login: $e");
      return null;
    }
  }

  // --- LOGIN CON GOOGLE (ACTUALIZADO) ---
  Future<User?> loginWithGoogle() async {
    try {
      final provider = GoogleAuthProvider();
      final UserCredential userCredential = await _auth.signInWithPopup(provider);
      
      // También verificamos aquí
      if (userCredential.user != null) {
        await _checkAndCreateMissingProfile(userCredential.user!, provider: 'google');
        // Verificar y crear perfil de Stripe si no existe
        await StripeService().ensureStripeCustomer(userCredential.user!);
      }

      return userCredential.user;
    } catch (e) {
      print("Error Google Sign-In: $e");
      return null;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  // =======================================================
  //      MÉTODOS DE BASE DE DATOS
  // =======================================================

  // A. Guardado Estándar (Cuando tenemos todos los datos del formulario)
  Future<void> _saveUserToFirestore({
    required String uid,
    required String email,
    required String firstName,
    required String lastName,
    required String phone,
    required String photoUrl,
    required String authProvider,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'bio': '',
      'gender': '',
      'photoUrl': photoUrl,
      'authProvider': authProvider,
      'createdAt': FieldValue.serverTimestamp(),
      'isAdmin': false,
      'stripeCustomerId': '', // Se llenará después 
    });
  }

  // B. AUTOCURACIÓN: Crear perfil si falta (Login normal o Google)
  Future<void> _checkAndCreateMissingProfile(User user, {required String provider}) async {
    final docRef = _firestore.collection('users').doc(user.uid);
    final docSnapshot = await docRef.get();

    // SI NO EXISTE EL DOCUMENTO EN LA DB...
    if (!docSnapshot.exists) {
      print("⚠️ Usuario logueado sin perfil en DB. Creando perfil de recuperación...");

      // Tratamos de adivinar el nombre usando lo que tenga Auth
      String fullName = user.displayName ?? "Usuario Nuevo";
      List<String> names = fullName.split(" ");
      String firstName = names.isNotEmpty ? names.first : "Usuario";
      String lastName = names.length > 1 ? names.sublist(1).join(" ") : "";
      
      // Si no tiene foto, le generamos una nueva
      String photoUrl = user.photoURL ?? "";
      if (photoUrl.isEmpty) {
         String encoded = Uri.encodeComponent(firstName);
         photoUrl = "https://ui-avatars.com/api/?name=$encoded&background=random&color=fff";
      }

      await docRef.set({
        'uid': user.uid,
        'firstName': firstName,
        'lastName': lastName,
        'email': user.email ?? "",
        'phone': user.phoneNumber ?? "", // A veces viene vacío en recuperación
        'bio': 'Perfil recuperado automáticamente.',
        'gender': '',
        'photoUrl': photoUrl,
        'authProvider': provider,
        'createdAt': FieldValue.serverTimestamp(),
        'isAdmin': false,
        'stripeCustomerId': '', // Se llenará después
      });
    }
  }
}