import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/src/models/firestore_models.dart';
import 'package:ecommerce_app/src/views/components/restaurant_card_vertical.dart';
import 'package:ecommerce_app/src/views/screens/tabs_screens/explore_screen/restaurant_detail_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class CategoryRestaurantsScreen extends StatelessWidget {
  final String category;

  const CategoryRestaurantsScreen({
    super.key,
    required this.category,
  });

  FirebaseFirestore get _firestore => FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'profileappdb',
      );

  // Mapeo de categorías a imágenes de portada
  static const Map<String, String> _categoryCovers = {
    "Americana": "assets/images/categoria_americana.jpg",
    "Italiana": "assets/images/categoria_italiana.jpg",
    "Asiática": "assets/images/categoria_asiatica.jpg",
    "Criolla": "assets/images/categoria_criolla.jpg",
    "Mexicana": "assets/images/categoria_mexicana.jpg",
    "Pollo": "assets/images/categoria_pollo.jpg",
    "Pizzas": "assets/images/categoria_pizzas.jpg",
  };

  // Iconos por categoría como fallback
  static const Map<String, IconData> _categoryIcons = {
    "Americana": Icons.lunch_dining,
    "Italiana": Icons.local_pizza,
    "Asiática": Icons.ramen_dining,
    "Criolla": Icons.restaurant,
    "Mexicana": Icons.local_dining,
    "Pollo": Icons.set_meal,
    "Pizzas": Icons.local_pizza,
  };

  // Colores por categoría
  static const Map<String, Color> _categoryColors = {
    "Americana": Color(0xFFEF5350),
    "Italiana": Color(0xFF66BB6A),
    "Asiática": Color(0xFFFF9800),
    "Criolla": Color(0xFF8D6E63),
    "Mexicana": Color(0xFFFFB300),
    "Pollo": Color(0xFFFF7043),
    "Pizzas": Color(0xFFE53935),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar con imagen de portada
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: _categoryColors[category] ?? Colors.blue,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                category,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3,
                      color: Colors.black45,
                    ),
                  ],
                ),
              ),
              background: _buildCoverImage(),
            ),
          ),

          // Lista de restaurantes filtrados por categoría
          StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('restaurants')
                .where('foodType', isEqualTo: category)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _categoryIcons[category] ?? Icons.restaurant_menu,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No hay restaurantes de $category disponibles",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final restaurants = snapshot.data!.docs
                  .map((doc) => RestaurantModel.fromSnapshot(doc))
                  .toList();

              return SliverPadding(
                padding: const EdgeInsets.all(15),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final restaurant = restaurants[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RestaurantDetailScreen(
                                restaurant: restaurant,
                              ),
                            ),
                          );
                        },
                        child: RestaurantCardVertical(
                          restaurantId: restaurant.id,
                          title: restaurant.name,
                          subtitle: restaurant.address,
                          imageUrl: restaurant.imageUrl,
                          rating: restaurant.rating,
                          ratingsCount: restaurant.ratingCount,
                          discountTag: null,
                          restaurantData: {
                            'name': restaurant.name,
                            'imageUrl': restaurant.imageUrl,
                            'foodType': restaurant.foodType,
                            'rating': restaurant.rating,
                            'ratingCount': restaurant.ratingCount,
                            'deliveryTime': restaurant.deliveryTime,
                            'deliveryFee': restaurant.deliveryFee,
                            'address': restaurant.address,
                            'tags': restaurant.tags,
                            'latitude': restaurant.latitude,
                            'longitude': restaurant.longitude,
                          },
                        ),
                      );
                    },
                    childCount: restaurants.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCoverImage() {
    final imageUrl = _categoryCovers[category];

    return Stack(
      fit: StackFit.expand,
      children: [
        // Intentar cargar imagen de assets
        if (imageUrl != null)
          Image.asset(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildFallbackCover();
            },
          )
        else
          _buildFallbackCover(),

        // Gradiente oscuro
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.5),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFallbackCover() {
    return Container(
      color: _categoryColors[category] ?? Colors.blue,
      child: Center(
        child: Icon(
          _categoryIcons[category] ?? Icons.restaurant_menu,
          size: 100,
          color: Colors.white.withOpacity(0.3),
        ),
      ),
    );
  }
}
