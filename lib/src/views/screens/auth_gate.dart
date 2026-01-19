import 'package:ecommerce_app/src/services/auth_service.dart';
import 'package:ecommerce_app/src/views/screens/auth_screens/login_screen.dart';
import 'package:ecommerce_app/src/views/screens/tabs_screens/tab_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // Escuchamos al monitor que creamos en el AuthService
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        
        // 1. Si está cargando (verificando si hay token guardado...)
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Si hay datos (snapshot.hasData), significa que el usuario ESTÁ LOGUEADO
        if (snapshot.hasData) {
          return const TabScreen(); // <--- RUTA PROTEGIDA (Home)
        }

        // 3. Si no hay datos, significa que NO hay sesión o cerró sesión
        return const LoginScreen(); // <--- RUTA PÚBLICA (Login)
      },
    );
  }
}