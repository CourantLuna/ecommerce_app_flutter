import 'package:ecommerce_app/constants.dart';
import 'package:ecommerce_app/src/services/auth_service.dart'; // Asegúrate de tener este archivo
import 'package:ecommerce_app/src/views/components/login_form.dart';
import 'package:ecommerce_app/src/views/screens/auth_screens/register_screen.dart';
import 'package:ecommerce_app/src/views/screens/tabs_screens/tab_screen.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  // 1. Creamos los controladores para capturar texto
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoading = false; // Para mostrar cargando

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset('assets/images/login_dark.png', fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "Welcome Back",
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: defaultPadding),
                  const Center(child: Text('Log in with your data')),
                  const SizedBox(height: defaultPadding),
                  
                  // 2. Pasamos los controladores al Formulario
                  LoginForm(
                    formKey: _formKey,
                    emailController: _emailController,
                    passwordController: _passwordController,
                  ),
                  
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text('Forgot Password'),
                    ),
                  ),
                  const SizedBox(height: defaultPadding),
                  
                  // 3. Botón con Lógica Real
                  SizedBox(
                    width: double.infinity, // Botón ancho completo
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() => _isLoading = true); // Activar carga
                          
                          // Llamada a Firebase
                          final user = await AuthService().login(
                            _emailController.text.trim(),
                            _passwordController.text.trim(),
                          );
                                        
                          if (user == null) {
                            // SI FALLA: Mostramos error
                            if (context.mounted) {
                              setState(() => _isLoading = false); // Quitamos carga para que intente de nuevo
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Error: Verifica tu correo y contraseña")),
                              );
                            }
                          }
                        }
                      },
                      child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Login'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton(
  onPressed: () async {

    // Activamos carga visual si quieres (opcional)
    setState(() => _isLoading = true);
    // 1. Llamamos a la nueva función
    final user = await AuthService().loginWithGoogle();
    // 2. Si falló (canceló o error), quitamos la carga
    if (user == null) {
       setState(() => _isLoading = false);
       // Opcional: Mostrar error
    }
    // 3. SI FUE ÉXITO: NO HACEMOS NADA.
    // El AuthGate nos llevará al TabScreen automáticamente.
   
  },
  style: OutlinedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 12),
    side: const BorderSide(color: Colors.grey),
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      // Icono de Google (texto simple si no tienes la imagen)
      const Icon(Icons.g_mobiledata, size: 30, color: Colors.red), 
      const SizedBox(width: 10),
      const Text("Sign in with Google", style: TextStyle(color: Colors.black)),
    ],
  ),
),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: const Text('Register Now'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}