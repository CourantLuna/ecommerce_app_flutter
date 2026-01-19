import 'package:ecommerce_app/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class RegisterForm extends StatelessWidget {
  const RegisterForm({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          // NOMBRE
          TextFormField(
            controller: nameController,
            validator: (value) => value!.isEmpty ? "Name required" : null,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(hintText: 'Full Name', prefixIcon: Icon(Icons.person)),
          ),
          const SizedBox(height: defaultPadding),
          
          // EMAIL
          TextFormField(
            controller: emailController,
            validator: emaildValidator.call,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: 'Email',
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: SvgPicture.asset('assets/icons/Message.svg', height: 24, width: 24),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),
          
          // PASSWORD
          TextFormField(
            controller: passwordController,
            obscureText: true,
            validator: passwordValidator.call,
            decoration: InputDecoration(
              hintText: 'Password',
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: SvgPicture.asset('assets/icons/Lock.svg', height: 24, width: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}