import 'package:ecommerce_app/src/models/firestore_models.dart';
import 'package:ecommerce_app/src/services/cart_service.dart';
import 'package:flutter/material.dart';

class ProductCard extends StatefulWidget {
  final ProductModel product;
  final String? restaurantName;

  const ProductCard({
    super.key,
    required this.product,
    this.restaurantName,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  final CartService _cartService = CartService();
  bool _isAdding = false;

  Future<void> _addToCart() async {
    setState(() {
      _isAdding = true;
    });

    final productData = {
      'name': widget.product.name,
      'description': widget.product.description,
      'imageUrl': widget.product.imageUrl,
      'price': widget.product.price,
      'restaurantName': widget.restaurantName ?? '',
    };

    final success = await _cartService.addToCart(
      productId: widget.product.id,
      productData: productData,
    );

    if (mounted) {
      setState(() {
        _isAdding = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.product.name} añadido al carrito'),
            duration: const Duration(seconds: 1),
            action: SnackBarAction(
              label: 'Ver Carrito',
              textColor: Colors.white,
              onPressed: () {
                Navigator.pushNamed(context, '/cart');
              },
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).cardColor : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info Texto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.product.description,
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Text(
                  "\$${widget.product.price.toStringAsFixed(0)}",
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 15),
          // Imagen del Plato con botón de añadir
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.product.imageUrl,
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, _, __) => Container(
                    height: 100,
                    width: 100,
                    color: isDark ? Colors.grey[800] : Colors.grey[200],
                    child: Icon(
                      Icons.fastfood,
                      color: isDark ? Colors.grey[600] : Colors.grey,
                    ),
                  ),
                ),
              ),
              // Botón para añadir al carrito
              Positioned(
                bottom: 5,
                right: 5,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _isAdding ? null : _addToCart,
                      borderRadius: BorderRadius.circular(15),
                      splashColor: Colors.white.withOpacity(0.3),
                      highlightColor: Colors.white.withOpacity(0.1),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: _isAdding
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(
                                Icons.add,
                                size: 20,
                                color: Colors.white,
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
