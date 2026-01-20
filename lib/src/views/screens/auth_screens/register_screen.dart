import 'package:ecommerce_app/constants.dart';
import 'package:ecommerce_app/src/services/auth_service.dart';
import 'package:ecommerce_app/src/views/components/register_form.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // 1. NUEVOS CONTROLADORES
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up"), backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            const Text("Create Account", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: defaultPadding * 2),
            
            // 2. FORMULARIO ACTUALIZADO
            RegisterForm(
              formKey: _formKey,
              firstNameController: _firstNameCtrl,
              lastNameController: _lastNameCtrl,
              phoneController: _phoneCtrl,
              emailController: _emailCtrl,
              passwordController: _passCtrl,
            ),
            
            const SizedBox(height: defaultPadding * 2),
            
            SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    onPressed: _isLoading ? null : () async {
      // 1. Validamos que cumpla todas las reglas (Mayúsculas, números, etc.)
      if (_formKey.currentState!.validate()) {
        
        // Iniciamos la carga
        setState(() => _isLoading = true);

        try {
          // 2. Intentamos registrar
          final user = await AuthService().register(
            email: _emailCtrl.text.trim(),
            password: _passCtrl.text.trim(),
            firstName: _firstNameCtrl.text.trim(),
            lastName: _lastNameCtrl.text.trim(),
            phone: _phoneCtrl.text.trim(),
          );

          if (!mounted) return; // Si la pantalla se cerró, paramos.

          if (user != null) {
            // ÉXITO: Cerramos pantalla (el AuthGate nos llevará al Home)
            Navigator.pop(context);
          } else {
            // ERROR CONOCIDO (AuthService devolvió null)
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Error al registrar. Revisa si el correo ya existe."),
                backgroundColor: Colors.red,
              ),
            );
          }
        } catch (e) {
          // ERROR INESPERADO
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error inesperado: $e")),
          );
        } finally {
          // 3. ESTO SE EJECUTA SIEMPRE: Quitamos el cargando
          if (mounted) {
            setState(() => _isLoading = false);
          }
        }
      }
    },
    child: _isLoading 
      ? const CircularProgressIndicator(color: Colors.white) 
      : const Text("Register"),
  ),
),
          ],
        ),
      ),
    );
  }
}