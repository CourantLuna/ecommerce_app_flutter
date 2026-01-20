import 'package:ecommerce_app/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class RegisterForm extends StatelessWidget {
  const RegisterForm({
    super.key,
    required this.formKey,
    required this.firstNameController,
    required this.lastNameController,
    required this.phoneController,
    required this.emailController,
    required this.passwordController,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          // --- NOMBRE Y APELLIDO ---
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: firstNameController,
                  validator: (value) => value!.isEmpty ? "Requerido" : null,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'Nombre', 
                    prefixIcon: Icon(Icons.person)
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: lastNameController,
                  validator: (value) => value!.isEmpty ? "Requerido" : null,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'Apellido', 
                    prefixIcon: Icon(Icons.person_outline)
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: defaultPadding),

          // --- TELÉFONO ---
          TextFormField(
            controller: phoneController,
            validator: (value) => value!.isEmpty ? "Teléfono requerido" : null,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              hintText: 'Teléfono',
              prefixIcon: Icon(Icons.phone_android),
            ),
          ),
          const SizedBox(height: defaultPadding),
          
          // --- EMAIL ---
          TextFormField(
            controller: emailController,
            validator: emaildValidator.call,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: 'Correo Electrónico',
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: SvgPicture.asset('assets/icons/Message.svg', height: 24, width: 24),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),
          
          // --- PASSWORD CON VALIDACIÓN VISUAL ---
          TextFormField(
            controller: passwordController,
            obscureText: true,
            // Validación estricta al presionar "Registrar"
            validator: (value) {
              if (value == null || value.isEmpty) return "Contraseña requerida";
              if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) return "Falta mayúscula";
              if (!RegExp(r'(?=.*[a-z])').hasMatch(value)) return "Falta minúscula";
              if (!RegExp(r'(?=.*[0-9])').hasMatch(value)) return "Falta número";
              if (value.length < 6) return "Mínimo 6 caracteres";
              return null;
            },
            decoration: InputDecoration(
              hintText: 'Contraseña',
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: SvgPicture.asset('assets/icons/Lock.svg', height: 24, width: 24),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // --- LISTA DE REQUISITOS EN TIEMPO REAL ---
          // Usamos ValueListenableBuilder para escuchar cambios solo en el input de password
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: passwordController,
            builder: (context, value, child) {
              final text = value.text;
              
              // Definimos las reglas
              final hasUpper = text.contains(RegExp(r'[A-Z]'));
              final hasLower = text.contains(RegExp(r'[a-z]'));
              final hasDigits = text.contains(RegExp(r'[0-9]'));
              final hasMinLength = text.length >= 6;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _RequirementItem(isMet: hasUpper, text: "Al menos una mayúscula"),
                  _RequirementItem(isMet: hasLower, text: "Al menos una minúscula"),
                  _RequirementItem(isMet: hasDigits, text: "Al menos un número"),
                  _RequirementItem(isMet: hasMinLength, text: "Mínimo 6 caracteres"),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// --- WIDGET AUXILIAR PARA CADA REQUISITO ---
class _RequirementItem extends StatelessWidget {
  final bool isMet;
  final String text;

  const _RequirementItem({required this.isMet, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          // Icono animado: Check verde o círculo gris
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: isMet ? Colors.green : Colors.transparent,
              border: isMet ? null : Border.all(color: Colors.grey.shade400),
              shape: BoxShape.circle,
            ),
            child: isMet 
                ? const Icon(Icons.check, color: Colors.white, size: 15)
                : null,
          ),
          const SizedBox(width: 10),
          // Texto que cambia de color
          Text(
            text,
            style: TextStyle(
              color: isMet ? Colors.green[700] : Colors.grey,
              fontSize: 12,
              decoration: isMet ? TextDecoration.none : null,
            ),
          ),
        ],
      ),
    );
  }
}