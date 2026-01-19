import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart'; // <--- ESTE ES EL IMPORT CLAVE

class AuthService {
  // Instancias con tipos explícitos para evitar confusión
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // ESTA ES LA CLAVE DE LA PERSISTENCIA
  // Es un "rio" de datos que nos avisa en tiempo real si el usuario entró o salió.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // --- REGISTRAR CON CORREO ---
  Future<User?> register(String email, String password, String name) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      User? user = result.user;
      if (user != null) {
        await user.updateDisplayName(name);
        await user.reload();
        user = _auth.currentUser;
      }
      return user;
    } catch (e) {
      print("Error Registro: $e");
      return null;
    }
  }

  // --- LOGIN CON CORREO ---
  Future<User?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      return result.user;
    } catch (e) {
      print("Error Login: $e");
      return null;
    }
  }

  // --- LOGIN CON GOOGLE (CORREGIDO) ---
  Future<User?> loginWithGoogle() async {
    try {
      // 1. Iniciar flujo interactivo
       final provider = new GoogleAuthProvider();
       final UserCredential userCredential = await _auth.signInWithPopup(provider);
       return userCredential.user;

    } catch (e) {
      print("Error Google Sign-In: $e");
      return null;
    }
  }

  // --- LOGOUT ---
  Future<void> logout() async {
    // await _googleSignIn.signOut();
    await _auth.signOut();
  }
}