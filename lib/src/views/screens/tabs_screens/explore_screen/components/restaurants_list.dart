import 'package:ecommerce_app/src/models/firestore_models.dart';
import 'package:ecommerce_app/src/views/components/header_text.dart';
import 'package:ecommerce_app/src/views/components/restaurant_card_horizontal.dart';
import 'package:ecommerce_app/src/views/components/restaurant_card_vertical.dart';
import 'package:ecommerce_app/src/views/screens/tabs_screens/explore_screen/components/categories_slider.dart';
import 'package:flutter/material.dart';

class RestaurantsList extends StatelessWidget {
  final List<RestaurantModel> filteredRestaurants;
  final List<RestaurantModel> popularRestaurants;
  final List<String> allCategories;
  final String searchQuery;
  final Function(BuildContext, RestaurantModel) onRestaurantTap;
  final Function(BuildContext, String) onCategoryTap;

  const RestaurantsList({
    super.key,
    required this.filteredRestaurants,
    required this.popularRestaurants,
    required this.allCategories,
    required this.searchQuery,
    required this.onRestaurantTap,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    if (filteredRestaurants.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 60,
              color: Colors.grey,
            ),
            SizedBox(height: 10),
            Text(
              "No encontramos restaurantes con esa búsqueda.",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        // --- SECCIÓN 1: POPULARES ---
        if (popularRestaurants.isNotEmpty)
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: HeaderText(
                    text: "Populares",
                    fontSize: 22,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  height: 260,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: popularRestaurants.length,
                    padding: const EdgeInsets.only(left: 15),
                    clipBehavior: Clip.none,
                    itemBuilder: (context, index) {
                      final rest = popularRestaurants[index];
                      return GestureDetector(
                        onTap: () => onRestaurantTap(context, rest),
                        child: RestaurantCardVertical(
                          restaurantId: rest.id,
                          title: rest.name,
                          subtitle: rest.address,
                          imageUrl: rest.imageUrl,
                          rating: rest.rating,
                          ratingsCount: rest.ratingCount,
                          discountTag: null,
                          restaurantData: {
                            'name': rest.name,
                            'imageUrl': rest.imageUrl,
                            'foodType': rest.foodType,
                            'rating': rest.rating,
                            'ratingCount': rest.ratingCount,
                            'deliveryTime': rest.deliveryTime,
                            'deliveryFee': rest.deliveryFee,
                            'address': rest.address,
                            'tags': rest.tags,
                            'latitude': rest.latitude,
                            'longitude': rest.longitude,
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),

        // --- SECCIÓN 2: CATEGORÍAS ---
        SliverToBoxAdapter(
          child: CategoriesSlider(
            categories: allCategories,
            onCategoryTap: onCategoryTap,
          ),
        ),

        // --- SECCIÓN 3: TODOS LOS RESULTADOS ---
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 10,
            ),
            child: HeaderText(
              text: searchQuery.isEmpty
                  ? "Todos los Restaurantes"
                  : "Resultados de búsqueda",
              fontSize: 22,
              color: Colors.black,
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final rest = filteredRestaurants[index];
                return GestureDetector(
                  onTap: () => onRestaurantTap(context, rest),
                  child: RestaurantCardHorizontal(
                    restaurantId: rest.id,
                    title: rest.name,
                    subtitle: "${rest.foodType} • ${rest.deliveryTime}",
                    imageUrl: rest.imageUrl,
                    rating: rest.rating,
                    ratingsCount: rest.ratingCount,
                    discountTag: null,
                    restaurantData: {
                      'name': rest.name,
                      'imageUrl': rest.imageUrl,
                      'foodType': rest.foodType,
                      'rating': rest.rating,
                      'ratingCount': rest.ratingCount,
                      'deliveryTime': rest.deliveryTime,
                      'deliveryFee': rest.deliveryFee,
                      'address': rest.address,
                      'tags': rest.tags,
                      'latitude': rest.latitude,
                      'longitude': rest.longitude,
                    },
                  ),
                );
              },
              childCount: filteredRestaurants.length,
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }
}
