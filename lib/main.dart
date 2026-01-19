import 'package:ecommerce_app/firebase_options.dart'; // <--- Importamos la config que creamos
import 'package:ecommerce_app/src/themes/app.theme.dart';
// import 'package:ecommerce_app/src/views/screens/auth_screens/login_screen.dart'; // <--- Importamos el Login
import 'package:firebase_core/firebase_core.dart'; // <--- Importamos el Core de Firebase
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // <--- 1. Importar dotenv
import 'package:ecommerce_app/src/views/screens/auth_gate.dart'; // <--- Importa el Gate

// Cambiamos a 'async' para poder esperar a que cargue Firebase
void main() async {
  // 1. Aseguramos que el motor gráfico de Flutter esté listo
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Cargar el archivo .env ANTES de inicializar Firebase
  await dotenv.load(fileName: ".env");

  // 2. Inicializamos la conexión con Firebase usando tus credenciales
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. Arrancamos la App
  runApp(const IntecEcommerceApp());
}

class IntecEcommerceApp extends StatelessWidget {
  const IntecEcommerceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-commerce Heydi',
      theme: AppTheme.lightTheme(context),
      debugShowCheckedModeBanner: false,
      // 4. Cambiamos 'TabScreen' por 'LoginScreen' para obligar a iniciar sesión
      home: const AuthGate(),
      );
  }
}