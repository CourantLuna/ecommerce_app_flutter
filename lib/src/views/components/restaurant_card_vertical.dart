import 'package:ecommerce_app/src/services/user_service.dart';
import 'package:flutter/material.dart';

class RestaurantCardVertical extends StatefulWidget {
  final String restaurantId;
  final String title;
  final String subtitle; // Ubicación
  final String imageUrl;
  final double rating;
  final int ratingsCount;
  final String? discountTag; // Ej: "20% OFF", "2x1"
  final Map<String, dynamic>? restaurantData;

  const RestaurantCardVertical({
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
  State<RestaurantCardVertical> createState() => _RestaurantCardVerticalState();
}

class _RestaurantCardVerticalState extends State<RestaurantCardVertical> {
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
    return Container(
      width: 220, // Ancho fijo para sliders horizontales
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. IMAGEN + TAG
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                // CORRECCIÓN: Usamos Image.network porque vienen de internet
                child: Image.network(
                  widget.imageUrl,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  // Si la imagen falla o no carga (Error 404), mostramos esto:
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 140,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    );
                  },
                  // Mientras carga la imagen, mostramos esto:
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 140,
                      width: double.infinity,
                      color: Colors.grey[100],
                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    );
                  },
                ),
              ),
              // TAG DE DESCUENTO (Si existe)
              if (widget.discountTag != null)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      widget.discountTag!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              // Botón de favoritos
              Positioned(
                top: 10,
                right: 10,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _isLoading ? null : _toggleFavorite,
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        padding: const EdgeInsets.all(6),
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
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                                ),
                              )
                            : Icon(
                                _isFavorite ? Icons.favorite : Icons.favorite_border,
                                size: 20,
                                color: Colors.red,
                              ),
                      ),
                    ),
                  ),
                ),
              ),
              // TIEMPO DE ENTREGA (Elemento extra UI recomendado)
              Positioned(
                bottom: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Text(
                    "20-30 min",
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          
          // 2. INFORMACIÓN
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // FILA DE CALIFICACIÓN
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      widget.rating.toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Text(
                      " (${widget.ratingsCount})",
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                    const Spacer(),
                    // TIPO DE ENTREGA
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        "Delivery",
                        style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
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