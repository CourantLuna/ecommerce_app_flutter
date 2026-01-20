import 'package:ecommerce_app/src/models/address_model.dart';
import 'package:ecommerce_app/src/services/address_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:geolocator/geolocator.dart';

class AddEditAddressScreen extends StatefulWidget {
  final AddressModel? address; // Si es null, es modo "agregar"

  const AddEditAddressScreen({super.key, this.address});

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final AddressService _addressService = AddressService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _searchController;

  GoogleMapController? _mapController;
  LatLng _currentPosition = const LatLng(
    18.4861,
    -69.9312,
  ); // Santo Domingo default
  Set<Marker> _markers = {};

  bool _isDefault = false;
  bool _isSaving = false;
  bool _showMap = false;
  bool _loadingLocation = false;

  bool get _isEditMode => widget.address != null;

  // API Key desde .env
  String get _googleApiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  @override
  void initState() {
    super.initState();

    // Inicializar controladores con datos existentes si está en modo edición
    _nameController = TextEditingController(text: widget.address?.name ?? '');
    _addressController = TextEditingController(
      text: widget.address?.fullAddress ?? '',
    );
    _searchController = TextEditingController();
    _isDefault = widget.address?.isDefault ?? false;

    // Si hay dirección existente, configurar posición inicial
    if (widget.address != null) {
      _currentPosition = LatLng(
        widget.address!.latitude,
        widget.address!.longitude,
      );
      _updateMarker(_currentPosition);
    } else {
      _updateMarker(_currentPosition);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _updateMarker(LatLng position) {
    setState(() {
      _currentPosition = position;
      _markers = {
        Marker(
          markerId: const MarkerId('selected_location'),
          position: position,
          draggable: true,
          onDragEnd: (newPosition) {
            _onMarkerDragged(newPosition);
          },
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      };
    });
  }

  Future<void> _onMarkerDragged(LatLng newPosition) async {
    setState(() {
      _currentPosition = newPosition;
    });

    // Obtener dirección desde coordenadas
    try {
      List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(
        newPosition.latitude,
        newPosition.longitude,
      );

      if (placemarks.isNotEmpty && mounted) {
        final place = placemarks.first;
        final address = '${place.street}, ${place.locality}, ${place.country}';
        _addressController.text = address;
      }
    } catch (e) {
      print('Error obteniendo dirección: $e');
    }
  }

  Future<void> _onPlaceSelected(Prediction prediction) async {
    // Obtener coordenadas del lugar seleccionado
    try {
      List<geo.Location> locations = await geo.locationFromAddress(
        prediction.description ?? '',
      );

      if (locations.isNotEmpty && mounted) {
        final location = locations.first;
        final newPosition = LatLng(location.latitude, location.longitude);

        _updateMarker(newPosition);
        _addressController.text = prediction.description ?? '';

        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(newPosition, 15),
        );
      }
    } catch (e) {
      print('Error obteniendo coordenadas: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _loadingLocation = true;
    });

    try {
      // Para web, usar directamente getCurrentPosition sin verificar el servicio
      // ya que isLocationServiceEnabled no funciona en web
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Permiso de ubicación denegado'),
                backgroundColor: Colors.red,
              ),
            );
          }
          setState(() {
            _loadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Permiso de ubicación denegado permanentemente. Habilítalo en configuración.',
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
            ),
          );
        }
        setState(() {
          _loadingLocation = false;
        });
        return;
      }

      // Obtener ubicación actual
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );

      final newPosition = LatLng(position.latitude, position.longitude);

      if (mounted) {
        _updateMarker(newPosition);
        await _onMarkerDragged(newPosition);

        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(newPosition, 16),
        );

        // Auto-expandir el mapa si está cerrado
        if (!_showMap) {
          setState(() {
            _showMap = true;
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ubicación actual obtenida'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error obteniendo ubicación: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al obtener ubicación: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loadingLocation = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Editar Dirección' : 'Agregar Dirección'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Nombre de la dirección
            _buildSectionTitle('Nombre de la dirección'),
            const SizedBox(height: 10),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Ej: Casa, Trabajo, Oficina...',
                prefixIcon: const Icon(Icons.label),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingresa un nombre para la dirección';
                }
                return null;
              },
            ),

            const SizedBox(height: 25),

            // Búsqueda de lugares con Google Maps
            _buildSectionTitle('Buscar ubicación en el mapa'),
            const SizedBox(height: 10),

            // Nota informativa sobre la búsqueda
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.orange[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Si la búsqueda no funciona, verifica que Places API esté habilitada en Google Cloud Console',
                      style: TextStyle(fontSize: 11, color: Colors.orange[900]),
                    ),
                  ),
                ],
              ),
            ),

            GooglePlaceAutoCompleteTextField(
              textEditingController: _searchController,
              googleAPIKey: _googleApiKey,
              inputDecoration: InputDecoration(
                hintText: 'Buscar dirección, restaurante, lugar...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              debounceTime: 800,
              countries: const ["do"], // República Dominicana
              isLatLngRequired: true,
              getPlaceDetailWithLatLng: (Prediction prediction) {
                _onPlaceSelected(prediction);
              },
              itemClick: (Prediction prediction) {
                _searchController.text = prediction.description ?? "";
                _searchController.selection = TextSelection.fromPosition(
                  TextPosition(offset: prediction.description?.length ?? 0),
                );
              },
              seperatedBuilder: const Divider(),
              containerHorizontalPadding: 10,
              itemBuilder: (context, index, Prediction prediction) {
                return Container(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.grey),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          prediction.description ?? "",
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 15),

            // Botones: Usar mi ubicación y Mostrar/Ocultar mapa
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _loadingLocation ? null : _getCurrentLocation,
                    icon: _loadingLocation
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location),
                    label: const Text('Mi Ubicación'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green[700],
                      side: BorderSide(color: Colors.green[700]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _showMap = !_showMap;
                      });
                    },
                    icon: Icon(_showMap ? Icons.expand_less : Icons.map),
                    label: Text(_showMap ? 'Ocultar' : 'Ver Mapa'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor,
                      side: BorderSide(color: Theme.of(context).primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ],
            ),

            // Mapa interactivo (expandible)
            if (_showMap) ...[
              const SizedBox(height: 15),
              Container(
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                clipBehavior: Clip.hardEdge,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition,
                    zoom: 15,
                  ),
                  markers: _markers,
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  onTap: (position) {
                    _updateMarker(position);
                    _onMarkerDragged(position);
                  },
                  myLocationButtonEnabled: true,
                  myLocationEnabled: true,
                  zoomControlsEnabled: true,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Arrastra el pin o toca en el mapa para seleccionar la ubicación exacta',
                        style: TextStyle(fontSize: 12, color: Colors.blue[900]),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 25),

            // Dirección completa (autocompletada o manual)
            _buildSectionTitle('Dirección completa'),
            const SizedBox(height: 10),
            TextFormField(
              controller: _addressController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Calle, número, sector, ciudad...',
                prefixIcon: const Icon(Icons.location_on),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingresa la dirección completa';
                }
                return null;
              },
            ),

            const SizedBox(height: 15),

            // Coordenadas (solo lectura, info)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.my_location, color: Colors.grey[600], size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Coordenadas: ${_currentPosition.latitude.toStringAsFixed(6)}, ${_currentPosition.longitude.toStringAsFixed(6)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Establecer como predeterminada
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: SwitchListTile(
                title: const Text('Establecer como predeterminada'),
                subtitle: const Text(
                  'Esta será tu dirección de entrega por defecto',
                ),
                value: _isDefault,
                onChanged: (value) {
                  setState(() {
                    _isDefault = value;
                  });
                },
                activeColor: Theme.of(context).primaryColor,
              ),
            ),

            const SizedBox(height: 30),

            // Botón guardar
            SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveAddress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _isEditMode
                            ? 'Actualizar Dirección'
                            : 'Guardar Dirección',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final address = AddressModel(
      id: widget.address?.id ?? '',
      name: _nameController.text.trim(),
      fullAddress: _addressController.text.trim(),
      latitude: _currentPosition.latitude,
      longitude: _currentPosition.longitude,
      isDefault: _isDefault,
      createdAt: widget.address?.createdAt,
    );

    bool success;
    if (_isEditMode) {
      success = await _addressService.updateAddress(
        widget.address!.id,
        address,
      );
    } else {
      success = await _addressService.addAddress(address);
    }

    if (mounted) {
      setState(() {
        _isSaving = false;
      });

      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode
                  ? 'Dirección actualizada correctamente'
                  : 'Dirección agregada correctamente',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al guardar la dirección'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
