import 'package:ecommerce_app/firebase_options.dart'; // <--- Importamos la config que creamos
import 'package:ecommerce_app/src/providers/theme_provider.dart';
import 'package:ecommerce_app/src/services/stripe_service.dart';
import 'package:ecommerce_app/src/services/stripe_web_service.dart';
import 'package:ecommerce_app/src/themes/app.theme.dart';
import 'package:ecommerce_app/src/views/screens/cart_screen/cart_screen.dart';
import 'package:ecommerce_app/src/views/screens/tabs_screens/explore_screen/category_restaurants_screen.dart';
// import 'package:ecommerce_app/src/views/screens/auth_screens/login_screen.dart'; // <--- Importamos el Login
import 'package:firebase_core/firebase_core.dart'; // <--- Importamos el Core de Firebase
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // <--- 1. Importar dotenv
import 'package:ecommerce_app/src/views/screens/auth_gate.dart'; // <--- Importa el Gate
import 'package:provider/provider.dart';

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

  // 3. Inicializar Stripe según la plataforma
  if (kIsWeb) {
    // En web, usar Stripe.js
    StripeWebService().initialize();
  } else {
    // En móvil, usar flutter_stripe
    await StripeService().initialize();
  }

  // 3. Arrancamos la App
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const IntecEcommerceApp(),
    ),
  );
}

class IntecEcommerceApp extends StatelessWidget {
  const IntecEcommerceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'E-commerce Heydi',
          theme: AppTheme.lightTheme(context),
          darkTheme: AppTheme.darkTheme(context),
          themeMode: themeProvider.themeMode,
          debugShowCheckedModeBanner: false,
          // 4. Cambiamos 'TabScreen' por 'LoginScreen' para obligar a iniciar sesión
          home: const AuthGate(),
          // Rutas nombradas
          routes: {
            '/cart': (context) => const CartScreen(),
          },
          onGenerateRoute: (settings) {
            // Ruta dinámica para categorías de restaurantes
            if (settings.name == '/category_restaurants') {
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (context) => CategoryRestaurantsScreen(
                  category: args['category'] as String,
                ),
              );
            }
            return null;
          },
          //AdminSeederScreen()
          
        );
      },
    );
  }
}