import 'package:ecommerce_app/constants.dart';
import 'package:ecommerce_app/src/services/auth_service.dart';
import 'package:ecommerce_app/src/views/components/register_form.dart';
import 'package:ecommerce_app/src/views/screens/tabs_screens/tab_screen.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
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
            
            RegisterForm(
              formKey: _formKey,
              nameController: _nameCtrl,
              emailController: _emailCtrl,
              passwordController: _passCtrl,
            ),
            
            const SizedBox(height: defaultPadding * 2),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() => _isLoading = true);
                    
                    // CREAR USUARIO EN FIREBASE
                    final user = await AuthService().register(
                      _emailCtrl.text.trim(),
                      _passCtrl.text.trim(),
                      _nameCtrl.text.trim(),
                    );
                    
                    setState(() => _isLoading = false);

                    if (user != null) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const TabScreen()),
                        (route) => false,
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                         const SnackBar(content: Text("Error al registrar. El correo ya existe.")),
                      );
                    }
                  }
                },
                child: _isLoading ? const CircularProgressIndicator() : const Text("Register"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}