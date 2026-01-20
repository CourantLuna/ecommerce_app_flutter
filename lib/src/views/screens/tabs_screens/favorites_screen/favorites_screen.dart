import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/src/models/firestore_models.dart';
import 'package:ecommerce_app/src/services/user_service.dart';
import 'package:ecommerce_app/src/views/components/header_text.dart';
import 'package:ecommerce_app/src/views/components/restaurant_card_horizontal.dart';
import 'package:ecommerce_app/src/views/screens/tabs_screens/explore_screen/restaurant_detail_screen.dart';
import 'package:flutter/material.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final UserService _userService = UserService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HeaderText(
                    text: "Mis Favoritos",
                    fontSize: 28,
                    color: Colors.black,
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Restaurantes que te encantan",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),

            // Lista de favoritos
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _userService.getFavoritesStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return _buildEmptyState();
                  }

                  final favorites = snapshot.data!.docs;

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    itemCount: favorites.length,
                    itemBuilder: (context, index) {
                      final data = favorites[index].data() as Map<String, dynamic>;
                      
                      // Construir RestaurantModel desde el favorito guardado
                      final restaurant = RestaurantModel(
                        id: favorites[index].id,
                        name: data['name'] ?? '',
                        imageUrl: data['imageUrl'] ?? '',
                        foodType: data['foodType'] ?? '',
                        rating: (data['rating'] ?? 0.0).toDouble(),
                        ratingCount: data['ratingCount'] ?? 0,
                        deliveryTime: data['deliveryTime'] ?? '',
                        deliveryFee: data['deliveryFee'] ?? '',
                        address: data['address'] ?? '',
                        tags: List<String>.from(data['tags'] ?? []),
                        latitude: (data['latitude'] ?? 0.0).toDouble(),
                        longitude: (data['longitude'] ?? 0.0).toDouble(),
                      );

                      return Dismissible(
                        key: Key(favorites[index].id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.delete, color: Colors.white, size: 30),
                              SizedBox(height: 5),
                              Text(
                                "Eliminar",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Confirmar"),
                                content: Text("¿Quitar ${restaurant.name} de favoritos?"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: const Text("Cancelar"),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                                    child: const Text("Eliminar"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        onDismissed: (direction) async {
                          await _userService.removeFromFavorites(restaurant.id);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${restaurant.name} eliminado de favoritos'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        child: GestureDetector(
                          onTap: () => _goToDetail(context, restaurant),
                          child: RestaurantCardHorizontal(
                            restaurantId: restaurant.id,
                            title: restaurant.name,
                            subtitle: "${restaurant.foodType} • ${restaurant.deliveryTime}",
                            imageUrl: restaurant.imageUrl,
                            rating: restaurant.rating,
                            ratingsCount: restaurant.ratingCount,
                            discountTag: null,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _goToDetail(BuildContext context, RestaurantModel restaurant) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RestaurantDetailScreen(restaurant: restaurant),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            "No tienes favoritos aún",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Empieza a guardar tus restaurantes favoritos",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
