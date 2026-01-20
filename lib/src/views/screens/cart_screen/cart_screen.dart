import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/src/models/address_model.dart';
import 'package:ecommerce_app/src/models/order_model.dart';
import 'package:ecommerce_app/src/services/address_service.dart';
import 'package:ecommerce_app/src/services/cart_service.dart';
import 'package:ecommerce_app/src/services/order_service.dart';
import 'package:ecommerce_app/src/services/stripe_service.dart';
import 'package:ecommerce_app/src/views/screens/tabs_screens/tab_screen.dart';
import 'package:flutter/material.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();
  final StripeService _stripeService = StripeService();
  final AddressService _addressService = AddressService();
  final OrderService _orderService = OrderService();
  
  String? _selectedPaymentMethodId;
  AddressModel? _selectedAddress;
  bool _loadingAddress = true;
  bool _processingPayment = false;

  @override
  void initState() {
    super.initState();
    _loadDefaultAddress();
  }

  Future<void> _loadDefaultAddress() async {
    final address = await _addressService.getDefaultAddress();
    if (mounted) {
      setState(() {
        _selectedAddress = address;
        _loadingAddress = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Mi Carrito',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => _showClearCartDialog(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _cartService.getCartStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyCart();
          }

          final cartItems = snapshot.data!.docs;
          
          // Calcular totales
          double subtotal = 0;
          for (var doc in cartItems) {
            final data = doc.data() as Map<String, dynamic>;
            final price = (data['price'] ?? 0.0).toDouble();
            final quantity = data['quantity'] ?? 1;
            subtotal += price * quantity;
          }

          final deliveryFee = subtotal > 0 ? 150.0 : 0.0; // DOP 150
          final total = subtotal + deliveryFee;

          return Column(
            children: [
              // Lista de productos
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final doc = cartItems[index];
                    final data = doc.data() as Map<String, dynamic>;
                    
                    return _CartItemCard(
                      productId: doc.id,
                      name: data['name'] ?? '',
                      description: data['description'] ?? '',
                      imageUrl: data['imageUrl'] ?? '',
                      price: (data['price'] ?? 0.0).toDouble(),
                      quantity: data['quantity'] ?? 1,
                      restaurantName: data['restaurantName'] ?? '',
                      onQuantityChanged: (newQuantity) {
                        _cartService.updateQuantity(doc.id, newQuantity);
                      },
                      onRemove: () {
                        _cartService.removeFromCart(doc.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Producto eliminado del carrito'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              // Resumen de pago
              _buildPaymentSummary(subtotal, deliveryFee, total, cartItems),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            "Tu carrito está vacío",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Agrega productos para empezar tu pedido",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.restaurant_menu),
            label: const Text('Explorar Restaurantes'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary(double subtotal, double deliveryFee, double total, List<QueryDocumentSnapshot> cartItems) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Subtotal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal', style: TextStyle(fontSize: 15)),
                Text(
                  '\$${subtotal.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Delivery
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Envío', style: TextStyle(fontSize: 15)),
                Text(
                  '\$${deliveryFee.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const Divider(height: 25),
            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${total.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            // Botón de pagar
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _processingPayment
                    ? null
                    : () {
                        _showCheckoutDialog(total, cartItems);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: _processingPayment
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Proceder al Pago',
                        style: TextStyle(
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

  void _showCheckoutDialog(double total, List<QueryDocumentSnapshot> cartItems) async {
    // Obtener métodos de pago
    final paymentMethods = await _stripeService.getPaymentMethods();

    if (!mounted) return;

    if (paymentMethods.isEmpty) {
      // No hay métodos de pago guardados
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Sin métodos de pago'),
          content: const Text(
            'Debes agregar un método de pago antes de realizar una compra.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
      return;
    }

    // Auto-seleccionar el método de pago predeterminado
    String? selectedPaymentMethod = _selectedPaymentMethodId;
    if (selectedPaymentMethod == null && paymentMethods.isNotEmpty) {
      // Obtener el método predeterminado del cliente en Stripe
      final defaultPaymentMethodId = await _stripeService.getDefaultPaymentMethod();
      
      if (defaultPaymentMethodId != null) {
        // Verificar que el método predeterminado esté en la lista
        final hasDefault = paymentMethods.any(
          (method) => method['id'] == defaultPaymentMethodId,
        );
        selectedPaymentMethod = hasDefault ? defaultPaymentMethodId : paymentMethods.first['id'] as String;
      } else {
        // Si no hay predeterminado, seleccionar el primero
        selectedPaymentMethod = paymentMethods.first['id'] as String;
      }
    }

    // Mostrar diálogo de checkout
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Confirmar Pedido',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),
                      const SizedBox(height: 15),

                      // Dirección de entrega
                      const Text(
                        'Dirección de entrega',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (_selectedAddress != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedAddress!.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      _selectedAddress!.fullAddress,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '⚠️ No has seleccionado una dirección de entrega',
                            style: TextStyle(color: Colors.orange),
                          ),
                        ),

                      const SizedBox(height: 20),

                      // Método de pago
                      const Text(
                        'Método de pago',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: paymentMethods.length,
                          itemBuilder: (context, index) {
                            final method = paymentMethods[index];
                            final card = method['card'] as Map<String, dynamic>;
                            final brand = card['brand'] as String;
                            final last4 = card['last4'] as String;
                            final paymentMethodId = method['id'] as String;
                            final isSelected =
                                selectedPaymentMethod == paymentMethodId;

                            return RadioListTile<String>(
                              value: paymentMethodId,
                              groupValue: selectedPaymentMethod,
                              onChanged: (value) {
                                setModalState(() {
                                  selectedPaymentMethod = value;
                                });
                              },
                              title: Text(
                                '${_getCardBrandName(brand)} •••• $last4',
                              ),
                              secondary: Icon(
                                Icons.credit_card,
                                color: isSelected
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Resumen
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total'),
                                Text(
                                  '\$${total.toStringAsFixed(0)} DOP',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Botón de confirmar
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: selectedPaymentMethod == null ||
                                  _selectedAddress == null
                              ? null
                              : () async {
                                  Navigator.pop(context);
                                  await _processPayment(
                                    total,
                                    cartItems,
                                    selectedPaymentMethod!,
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Confirmar y Pagar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _processPayment(
    double total,
    List<QueryDocumentSnapshot> cartItems,
    String paymentMethodId,
  ) async {
    setState(() => _processingPayment = true);

    try {
      // 1. Crear Payment Intent
      final paymentIntent = await _stripeService.createPaymentIntent(
        amount: total,
        currency: 'DOP',
        paymentMethodId: paymentMethodId,
      );

      if (paymentIntent == null) {
        _showError('No se pudo crear la intención de pago');
        setState(() => _processingPayment = false);
        return;
      }

      final status = paymentIntent['status'] as String;

      if (status == 'succeeded' || status == 'processing') {
        // 2. Crear el pedido
        final items = cartItems.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return OrderItem(
            productId: doc.id,
            name: data['name'] ?? '',
            description: data['description'] ?? '',
            imageUrl: data['imageUrl'] ?? '',
            price: (data['price'] ?? 0.0).toDouble(),
            quantity: data['quantity'] ?? 1,
            restaurantName: data['restaurantName'] ?? '',
          );
        }).toList();

        final order = OrderModel(
          id: '',
          userId: '',
          items: items,
          subtotal: total - 150.0,
          deliveryFee: 150.0,
          total: total,
          status: 'pending',
          createdAt: DateTime.now(),
          addressId: _selectedAddress?.id,
          addressName: _selectedAddress?.name,
          fullAddress: _selectedAddress?.fullAddress,
          paymentMethodId: paymentMethodId,
          paymentIntentId: paymentIntent['paymentIntentId'],
        );

        final orderId = await _orderService.createOrder(order);

        if (orderId != null) {
          // 3. Vaciar el carrito
          await _cartService.clearCart();

          if (mounted) {
            setState(() => _processingPayment = false);

            // Mostrar éxito
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                title: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 30),
                    SizedBox(width: 10),
                    Text('¡Pago Exitoso!'),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tu pedido ha sido confirmado.'),
                    const SizedBox(height: 10),
                    Text(
                      'ID de pedido: $orderId',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Cerrar diálogo de éxito
                      // Volver al TabScreen con el tab de pedidos activo
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TabScreen(initialTab: 1),
                        ),
                        (route) => false,
                      );
                    },
                    child: const Text('Ver mis pedidos'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Cerrar diálogo de éxito
                      Navigator.pop(context); // Cerrar pantalla de carrito
                    },
                    child: const Text('Aceptar'),
                  ),
                ],
              ),
            );
          }
        } else {
          _showError('No se pudo crear el pedido');
          setState(() => _processingPayment = false);
        }
      } else {
        _showError('El pago no pudo ser procesado: $status');
        setState(() => _processingPayment = false);
      }
    } catch (e) {
      print('Error procesando pago: $e');
      _showError('Error al procesar el pago');
      setState(() => _processingPayment = false);
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getCardBrandName(String brand) {
    switch (brand.toLowerCase()) {
      case 'visa':
        return 'Visa';
      case 'mastercard':
        return 'Mastercard';
      case 'amex':
        return 'American Express';
      default:
        return brand.toUpperCase();
    }
  }

  void _showClearCartDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Vaciar Carrito"),
          content: const Text("¿Estás seguro de que quieres eliminar todos los productos del carrito?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _cartService.clearCart();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Carrito vaciado'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Vaciar"),
            ),
          ],
        );
      },
    );
  }

}


// Widget para cada item del carrito
class _CartItemCard extends StatelessWidget {
  final String productId;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final int quantity;
  final String restaurantName;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  const _CartItemCard({
    required this.productId,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    required this.restaurantName,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              imageUrl,
              height: 80,
              width: 80,
              fit: BoxFit.cover,
              errorBuilder: (ctx, _, __) => Container(
                height: 80,
                width: 80,
                color: Colors.grey[200],
                child: const Icon(Icons.fastfood, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (restaurantName.isNotEmpty)
                  Text(
                    restaurantName,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '\$${price.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    // Controles de cantidad
                    _buildQuantityControls(),
                  ],
                ),
              ],
            ),
          ),
          
          // Botón eliminar
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
            onPressed: onRemove,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityControls() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Botón menos
          InkWell(
            onTap: quantity > 1 ? () => onQuantityChanged(quantity - 1) : null,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(6),
              child: Icon(
                Icons.remove,
                size: 16,
                color: quantity > 1 ? Colors.black : Colors.grey,
              ),
            ),
          ),
          // Cantidad
          Container(
            constraints: const BoxConstraints(minWidth: 30),
            alignment: Alignment.center,
            child: Text(
              '$quantity',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          // Botón más
          InkWell(
            onTap: () => onQuantityChanged(quantity + 1),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(6),
              child: const Icon(
                Icons.add,
                size: 16,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
