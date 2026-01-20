import 'package:cloud_firestore/cloud_firestore.dart'; // <--- NUEVO
import 'package:ecommerce_app/src/services/auth_service.dart';
import 'package:ecommerce_app/src/services/user_service.dart';
import 'package:ecommerce_app/src/views/screens/settings_screen/manage_addresses_screen.dart';
import 'package:ecommerce_app/src/views/screens/settings_screen/payment_methods_screen.dart';
import 'package:ecommerce_app/src/views/screens/tabs_screens/profile_screen/edit_profile_screen.dart'; // <--- NUEVO: Tu pantalla de edición
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isUploading = false;

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image != null) {
      setState(() => _isUploading = true);
      await UserService().updateProfilePhoto(image);
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("¡Foto actualizada correctamente!")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. AGREGAMOS EL STREAMBUILDER PARA LEER DB EN TIEMPO REAL
    return StreamBuilder<DocumentSnapshot>(
      stream: UserService().getUserStream(),
      builder: (context, snapshot) {
        // Estado de carga inicial
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Recuperar datos (si existen)
        Map<String, dynamic> userData = {};
        if (snapshot.hasData && snapshot.data!.exists) {
          userData = snapshot.data!.data() as Map<String, dynamic>;
        }

        // Variables seguras
        final String firstName = userData['firstName'] ?? '';
        final String lastName = userData['lastName'] ?? '';

        // Nombre: Prioridad DB > Auth
        final String fullName = firstName.isNotEmpty
            ? "$firstName $lastName"
            : (AuthService().currentUser?.displayName ?? "Usuario Invitado");

        final String email =
            userData['email'] ??
            AuthService().currentUser?.email ??
            "Sin correo";

        // NUEVOS CAMPOS
        final String phone = userData['phone'] ?? "";
        final String bio = userData['bio'] ?? "";

        // Foto: Prioridad DB > Auth
        final String photoUrl =
            userData['photoUrl'] ?? AuthService().currentUser?.photoURL;
        final bool hasImage = photoUrl != null && photoUrl.isNotEmpty;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F6F9),
          appBar: AppBar(
            title: const Text(
              "Perfil",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                // ================= HEADER =================
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            spreadRadius: 2,
                            blurRadius: 10,
                            color: Colors.black.withOpacity(0.1),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[200],
                        child: _isUploading
                            ? const CircularProgressIndicator()
                            : CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.transparent,
                                backgroundImage: hasImage
                                    ? NetworkImage(photoUrl!)
                                    : null,
                                child: !hasImage
                                    ? const Icon(
                                        Icons.person,
                                        size: 60,
                                        color: Colors.grey,
                                      )
                                    : null,
                              ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 4,
                      child: GestureDetector(
                        onTap: _isUploading ? null : _pickAndUploadImage,
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // DATOS DE TEXTO
                Text(
                  fullName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  email,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),

                // 2. MOSTRAR TELÉFONO (Si existe)
                if (phone.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 5),
                        Text(
                          phone,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                // 3. MOSTRAR BIO (Si existe)
                if (bio.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 12,
                    ),
                    child: Text(
                      bio,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Colors.black54,
                      ),
                    ),
                  ),

                const SizedBox(height: 30),

                // ================= MENÚ =================
                _buildSectionHeader("Cuenta"),

                // 4. BOTÓN EDITAR PERFIL (Redirecciona a EditProfileScreen)
                _ProfileMenuWidget(
                  title: "Editar Perfil", // Cambiado nombre
                  icon: Icons.edit, // Cambiado icono
                  onPress: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditProfileScreen(currentData: userData),
                      ),
                    );
                  },
                ),

                _ProfileMenuWidget(
                  title: "Notificaciones",
                  icon: Icons.notifications_none,
                  onPress: () {},
                ),
                _ProfileMenuWidget(
                  title: "Mis Direcciones",
                  icon: Icons.location_on_outlined,
                  onPress: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ManageAddressesScreen(),
                      ),
                    );
                  },
                ),
                _ProfileMenuWidget(
                  title: "Mis Métodos de Pago",
                  icon: Icons.payment_outlined,
                  onPress: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PaymentMethodsScreen(),
                      ),
                    );
                  },
                ),
                _ProfileMenuWidget(
                  title: "Ajustes",
                  icon: Icons.settings_outlined,
                  onPress: () {},
                ),

                const SizedBox(height: 20),
                _buildSectionHeader("Soporte"),

                _ProfileMenuWidget(
                  title: "Centro de Ayuda",
                  icon: Icons.help_outline,
                  onPress: () {},
                ),

                _ProfileMenuWidget(
                  title: "Cerrar Sesión",
                  icon: Icons.logout,
                  textColor: Colors.redAccent,
                  endIcon: false,
                  onPress: () async {
                    await AuthService().logout();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

class _ProfileMenuWidget extends StatelessWidget {
  const _ProfileMenuWidget({
    required this.title,
    required this.icon,
    required this.onPress,
    this.endIcon = true,
    this.textColor,
  });

  final String title;
  final IconData icon;
  final VoidCallback onPress;
  final bool endIcon;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: textColor ?? Colors.black87,
          padding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.black.withOpacity(0.05),
        ),
        onPressed: onPress,
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: textColor ?? Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 20),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 16))),
            if (endIcon)
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
