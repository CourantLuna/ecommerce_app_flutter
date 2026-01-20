import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/src/models/firestore_models.dart';
import 'package:ecommerce_app/src/services/user_service.dart';
import 'package:ecommerce_app/src/views/components/info_badge.dart';
import 'package:ecommerce_app/src/views/components/product_card.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final RestaurantModel restaurant;

  const RestaurantDetailScreen({super.key, required this.restaurant});

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  final UserService _userService = UserService();
  bool _isFavorite = false;
  bool _isLoading = false;

  FirebaseFirestore get _firestore => FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'profileappdb',
      );

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final isFav = await _userService.isFavorite(widget.restaurant.id);
    if (mounted) {
      setState(() {
        _isFavorite = isFav;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    setState(() {
      _isLoading = true;
    });

    final restaurantData = {
      'name': widget.restaurant.name,
      'imageUrl': widget.restaurant.imageUrl,
      'foodType': widget.restaurant.foodType,
      'rating': widget.restaurant.rating,
      'ratingCount': widget.restaurant.ratingCount,
      'deliveryTime': widget.restaurant.deliveryTime,
      'deliveryFee': widget.restaurant.deliveryFee,
      'address': widget.restaurant.address,
      'tags': widget.restaurant.tags,
      'latitude': widget.restaurant.latitude,
      'longitude': widget.restaurant.longitude,
    };

    final success = await _userService.toggleFavorite(widget.restaurant.id, restaurantData);

    if (mounted) {
      setState(() {
        if (success) {
          _isFavorite = !_isFavorite;
        }
        _isLoading = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isFavorite ? 'Agregado a favoritos' : 'Eliminado de favoritos'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // 1. APPBAR COLAPSABLE CON IMAGEN (Banner)
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: Colors.white,
            iconTheme: const IconThemeData(color: Colors.white, shadows: [Shadow(color: Colors.black, blurRadius: 10)]),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    widget.restaurant.imageUrl,
                    fit: BoxFit.cover,
                  ),
                  // Gradiente oscuro abajo para que se lea el texto si lo hubiera
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black.withOpacity(0.3), Colors.transparent, Colors.black.withOpacity(0.5)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
                onPressed: _isLoading ? null : _toggleFavorite,
              ),
              IconButton(icon: const Icon(Icons.share), onPressed: () {}),
            ],
          ),

          // 2. INFORMACIÓN DEL RESTAURANTE
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre
                  Text(
                    widget.restaurant.name,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  // Categoría y Tags
                  Text(
                    "${widget.restaurant.foodType} • ${widget.restaurant.tags.join(', ')}",
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 15),
                  
                  // Fila de Info (Rating, Tiempo, Envío)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InfoBadge(icon: Icons.star, text: "${widget.restaurant.rating}", subText: "(${widget.restaurant.ratingCount})"),
                      InfoBadge(icon: Icons.access_time_filled, text: widget.restaurant.deliveryTime, subText: "Entrega"),
                      InfoBadge(icon: Icons.delivery_dining, text: widget.restaurant.deliveryFee, subText: "Envío"),
                    ],
                  ),
                  const SizedBox(height: 30),
                  
                  // Ubicación y Mapa (Colapsable)
                  ExpansionTile(
                    initiallyExpanded: false,
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: const EdgeInsets.only(top: 10, bottom: 5),
                    shape: const Border(),
                    collapsedShape: const Border(),
                    leading: Icon(Icons.location_on, color: Theme.of(context).primaryColor, size: 24),
                    title: const Text(
                      "Ubicación",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text(
                      "Toca para ver en mapa",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    children: [
                      // Dirección
                      Row(
                        children: [
                          Icon(Icons.place_outlined, color: Colors.grey[600], size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.restaurant.address,
                              style: TextStyle(color: Colors.grey[700], fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Mapa interactivo con coordenadas
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: LatLng(widget.restaurant.latitude, widget.restaurant.longitude),
                              zoom: 15,
                            ),
                            markers: {
                              Marker(
                                markerId: const MarkerId('restaurant_location'),
                                position: LatLng(widget.restaurant.latitude, widget.restaurant.longitude),
                                infoWindow: InfoWindow(
                                  title: widget.restaurant.name,
                                  snippet: widget.restaurant.address,
                                ),
                              ),
                            },
                            myLocationButtonEnabled: false,
                            zoomControlsEnabled: true,
                            mapToolbarEnabled: false,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 30),
                  const Text("Menú", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),

          // 3. LISTA DE PLATOS (StreamBuilder filtrado por ID)
          StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('products')
                .where('restaurantId', isEqualTo: widget.restaurant.id) // <--- FILTRO MÁGICO
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(child: Text("Menú no disponible por el momento.")),
                  ),
                );
              }

              final products = snapshot.data!.docs.map((doc) => ProductModel.fromSnapshot(doc)).toList();

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final product = products[index];
                    return ProductCard(
                      product: product,
                      restaurantName: widget.restaurant.name,
                    );
                  },
                  childCount: products.length,
                ),
              );
            },
          ),
          
          // Espacio final
          const SliverToBoxAdapter(child: SizedBox(height: 50)),
        ],
      ),
    );
  }
}