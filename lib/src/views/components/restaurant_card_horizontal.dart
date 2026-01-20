import 'package:ecommerce_app/src/services/user_service.dart';
import 'package:flutter/material.dart';

class RestaurantCardHorizontal extends StatefulWidget {
  final String restaurantId;
  final String title;
  final String subtitle;
  final String imageUrl;
  final double rating;
  final int ratingsCount;
  final String? discountTag;
  final Map<String, dynamic>? restaurantData;

  const RestaurantCardHorizontal({
    super.key,
    required this.restaurantId,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.rating,
    required this.ratingsCount,
    this.discountTag,
    this.restaurantData,
  });

  @override
  State<RestaurantCardHorizontal> createState() => _RestaurantCardHorizontalState();
}

class _RestaurantCardHorizontalState extends State<RestaurantCardHorizontal> {
  final UserService _userService = UserService();
  bool _isFavorite = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final isFav = await _userService.isFavorite(widget.restaurantId);
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

    final restaurantData = widget.restaurantData ?? {
      'name': widget.title,
      'imageUrl': widget.imageUrl,
      'foodType': '',
      'rating': widget.rating,
      'ratingCount': widget.ratingsCount,
      'deliveryTime': '',
      'deliveryFee': '',
      'address': widget.subtitle,
      'tags': [],
      'latitude': 0.0,
      'longitude': 0.0,
    };

    final success = await _userService.toggleFavorite(widget.restaurantId, restaurantData);

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
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).cardColor : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 1. IMAGEN CUADRADA A LA IZQUIERDA
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                // CORRECCIÓN: Usamos Image.network para cargar desde URL
                Image.network(
                  widget.imageUrl,
                  height: 90,
                  width: 90,
                  fit: BoxFit.cover,
                  // Protección contra errores (404, sin internet)
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 90,
                      width: 90,
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image, size: 30, color: Colors.grey),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 90,
                      width: 90,
                      color: isDark ? Colors.grey[800] : Colors.grey[100],
                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    );
                  },
                ),
                // Botón de favoritos
                Positioned(
                  top: 5,
                  right: 5,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _isLoading ? null : _toggleFavorite,
                        borderRadius: BorderRadius.circular(15),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.3),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                                  ),
                                )
                              : Icon(
                                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                                  size: 18,
                                  color: Colors.red,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (widget.discountTag != null)
                   Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: Colors.redAccent.withOpacity(0.9),
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        widget.discountTag!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
              ],
            ),
          ),
          
          const SizedBox(width: 15),
          
          // 2. COLUMNA DE INFORMACIÓN A LA DERECHA
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey,
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        widget.subtitle,
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    Text(
                      " ${widget.rating}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Text(
                      " (${widget.ratingsCount})",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const Spacer(),
                    const Text(
                      "Free Delivery", // Extra sugerido: Costo de envío
                      style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}