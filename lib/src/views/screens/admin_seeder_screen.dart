import 'package:ecommerce_app/src/services/data_seeder_service.dart';
import 'package:flutter/material.dart';

class AdminSeederScreen extends StatefulWidget {
  const AdminSeederScreen({super.key});

  @override
  State<AdminSeederScreen> createState() => _AdminSeederScreenState();
}

class _AdminSeederScreenState extends State<AdminSeederScreen> {
  bool _isLoading = false;
  String _status = "Listo para importar datos.";

  Future<void> _runImport() async {
    setState(() {
      _isLoading = true;
      _status = "Subiendo restaurantes y menú...";
    });

    await DataSeederService().uploadDummyData();

    if (mounted) {
      setState(() {
        _isLoading = false;
        _status = "¡Importación completada! Revisa Firebase.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Data Import")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_upload, size: 80, color: Colors.blue),
              const SizedBox(height: 20),
              const Text(
                "Importador Masivo de Restaurantes",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                "Esto borrará o duplicará datos si se ejecuta varias veces. Úsalo con cuidado.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 40),
              
              if (_isLoading) 
                const CircularProgressIndicator()
              else
                ElevatedButton.icon(
                  onPressed: _runImport,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text("EJECUTAR IMPORTACIÓN"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                ),
                
              const SizedBox(height: 20),
              Text(_status, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
            ],
          ),
        ),
      ),
    );
  }
}