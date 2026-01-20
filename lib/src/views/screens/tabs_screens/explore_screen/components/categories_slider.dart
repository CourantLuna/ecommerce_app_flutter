import 'package:ecommerce_app/src/views/components/header_text.dart';
import 'package:flutter/material.dart';

class CategoriesSlider extends StatelessWidget {
  final List<String> categories;
  final Function(BuildContext, String) onCategoryTap;

  const CategoriesSlider({
    super.key,
    required this.categories,
    required this.onCategoryTap,
  });

  // Mapeo de categorías a imágenes
  static const Map<String, String> _categoryImages = {
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: HeaderText(
            text: "Categorías",
            fontSize: 22,
           color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,

          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            padding: const EdgeInsets.only(left: 15),
            itemBuilder: (context, index) {
              final category = categories[index];
              return _CategoryCard(
                category: category,
                imageUrl: _categoryImages[category],
                icon: _categoryIcons[category] ?? Icons.restaurant_menu,
                onTap: () => onCategoryTap(context, category),
              );
            },
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String category;
  final String? imageUrl;
  final IconData icon;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    this.imageUrl,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Imagen de fondo o color
              _buildBackground(),

              // Gradiente oscuro
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),

              // Texto de categoría
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      icon,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackground() {
    // Si hay imagen, intentar cargarla (aunque no existan aún)
    if (imageUrl != null) {
      return Image.asset(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Fallback: color de fondo con icono
          return _buildFallbackBackground();
        },
      );
    }

    return _buildFallbackBackground();
  }

  Widget _buildFallbackBackground() {
    // Colores por categoría
    final Map<String, Color> categoryColors = {
      "Americana": Colors.red.shade400,
      "Italiana": Colors.green.shade400,
      "Asiática": Colors.orange.shade400,
      "Criolla": Colors.brown.shade400,
      "Mexicana": Colors.amber.shade600,
      "Pollo": Colors.deepOrange.shade400,
      "Pizzas": Colors.red.shade600,
    };

    return Container(
      color: categoryColors[category] ?? Colors.blue.shade400,
      child: Center(
        child: Icon(
          icon,
          size: 60,
          color: Colors.white.withOpacity(0.3),
        ),
      ),
    );
  }
}
