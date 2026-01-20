import 'package:ecommerce_app/constants.dart'; // Asegúrate de tener tus constantes aquí
import 'package:ecommerce_app/src/services/user_service.dart';
import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  // Recibimos los datos actuales para rellenar los campos
  final Map<String, dynamic> currentData;

  const EditProfileScreen({super.key, required this.currentData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _firstNameCtrl;
  late TextEditingController _lastNameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _bioCtrl;
  String? _selectedGender;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Inicializamos con los datos que vienen de la pantalla anterior
    _firstNameCtrl = TextEditingController(text: widget.currentData['firstName'] ?? '');
    _lastNameCtrl = TextEditingController(text: widget.currentData['lastName'] ?? '');
    _phoneCtrl = TextEditingController(text: widget.currentData['phone'] ?? '');
    _bioCtrl = TextEditingController(text: widget.currentData['bio'] ?? '');
    _selectedGender = widget.currentData['gender'];
    
    // Si el género viene vacío o nulo, lo dejamos null para que el usuario elija
    if (_selectedGender == null || _selectedGender!.isEmpty) {
      _selectedGender = null; 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Perfil", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // NOMBRE Y APELLIDO
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _firstNameCtrl,
                      decoration: const InputDecoration(labelText: "Nombre", prefixIcon: Icon(Icons.person)),
                      validator: (v) => v!.isEmpty ? "Requerido" : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _lastNameCtrl,
                      decoration: const InputDecoration(labelText: "Apellido"),
                      validator: (v) => v!.isEmpty ? "Requerido" : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // TELEFONO
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: "Teléfono", prefixIcon: Icon(Icons.phone)),
              ),
              const SizedBox(height: 20),

              // GÉNERO (Dropdown)
              DropdownButtonFormField<String>(
                value: _selectedGender, // Debe coincidir con uno de los items
                decoration: const InputDecoration(labelText: "Género", prefixIcon: Icon(Icons.people)),
                items: const [
                  DropdownMenuItem(value: "Masculino", child: Text("Masculino")),
                  DropdownMenuItem(value: "Femenino", child: Text("Femenino")),
                  DropdownMenuItem(value: "Otro", child: Text("Otro")),
                ],
                onChanged: (val) => setState(() => _selectedGender = val),
              ),
              const SizedBox(height: 20),

              // BIO (Multilínea)
              TextFormField(
                controller: _bioCtrl,
                maxLines: 3,
                maxLength: 150,
                decoration: const InputDecoration(
                  labelText: "Biografía", 
                  alignLabelWithHint: true,
                  hintText: "Escribe algo breve sobre ti...",
                  prefixIcon: Icon(Icons.info_outline),
                ),
              ),
              const SizedBox(height: 30),

              // BOTÓN GUARDAR
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Guardar Cambios"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final success = await UserService().updateProfileData(
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        bio: _bioCtrl.text.trim(),
        gender: _selectedGender ?? "No especificado",
      );

      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          Navigator.pop(context); // Volver al perfil
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Perfil actualizado correctamente")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error al guardar cambios")),
          );
        }
      }
    }
  }
}