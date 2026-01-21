import 'package:ecommerce_app/src/services/stripe_service.dart';
import 'package:ecommerce_app/src/services/stripe_web_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final StripeService _stripeService = StripeService();
  List<Map<String, dynamic>> _paymentMethods = [];
  String? _defaultPaymentMethodId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  Future<void> _loadPaymentMethods() async {
    setState(() => _loading = true);
    try {
      final methods = await _stripeService.getPaymentMethods();
      final defaultId = await _stripeService.getDefaultPaymentMethod();
      if (mounted) {
        setState(() {
          _paymentMethods = methods;
          _defaultPaymentMethodId = defaultId;
          _loading = false;
        });
      }
    } catch (e) {
      print('Error cargando métodos de pago: $e');
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _addPaymentMethod() async {
    if (kIsWeb) {
      // Flujo para WEB usando Stripe.js
      await _addPaymentMethodWeb();
    } else {
      // Flujo para MÓVIL usando flutter_stripe
      await _addPaymentMethodMobile();
    }
  }

  Future<void> _addPaymentMethodWeb() async {
    try {
      // 1. Crear SetupIntent
      final setupData = await _stripeService.createSetupIntent();
      if (setupData == null) {
        _showError('No se pudo crear el SetupIntent');
        return;
      }

      // 2. Usar Stripe.js Payment Element
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final result = await StripeWebService().createCheckoutSession(
        setupData['clientSecret'],
        isDarkMode: isDark,
      );

      if (mounted) {
        if (result == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Método de pago agregado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
          _loadPaymentMethods();
        } else if (result == 'cancelled') {
          // Usuario canceló, no hacer nada
        } else {
          _showError('Error al procesar la tarjeta');
        }
      }
    } catch (e) {
      _showError('Error al agregar método de pago');
      print('Error en _addPaymentMethodWeb: $e');
    }
  }

  Future<void> _addPaymentMethodMobile() async {
    try {
      // 1. Crear SetupIntent
      final setupData = await _stripeService.createSetupIntent();
      if (setupData == null) {
        _showError('No se pudo crear el SetupIntent');
        return;
      }

      // 2. Inicializar Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          merchantDisplayName: 'Ecommerce App',
          setupIntentClientSecret: setupData['clientSecret'],
          style: ThemeMode.light,
          billingDetailsCollectionConfiguration:
              const BillingDetailsCollectionConfiguration(
            name: CollectionMode.always,
            email: CollectionMode.always,
            phone: CollectionMode.always,
          ),
        ),
      );

      // 3. Mostrar Payment Sheet
      await Stripe.instance.presentPaymentSheet();

      // 4. Si llegamos aquí, el método se guardó exitosamente
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Método de pago agregado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        _loadPaymentMethods();
      }
    } catch (e) {
      if (e is StripeException) {
        if (e.error.code == FailureCode.Canceled) {
          // Usuario canceló, no mostrar error
          return;
        }
        _showError('Error: ${e.error.localizedMessage}');
      } else {
        _showError('Error al agregar método de pago');
      }
      print('Error en _addPaymentMethodMobile: $e');
    }
  }

  Future<void> _deletePaymentMethod(String paymentMethodId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar método de pago'),
        content: const Text('¿Estás seguro de que quieres eliminar este método de pago?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final success = await _stripeService.deletePaymentMethod(paymentMethodId);
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Método de pago eliminado'),
            backgroundColor: Colors.green,
          ),
        );
        _loadPaymentMethods();
      } else {
        _showError('No se pudo eliminar el método de pago');
      }
    }
  }

  Future<void> _setDefaultPaymentMethod(String paymentMethodId) async {
    final success = await _stripeService.setDefaultPaymentMethod(paymentMethodId);
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Método predeterminado actualizado'),
            backgroundColor: Colors.green,
          ),
        );
        _loadPaymentMethods();
      } else {
        _showError('No se pudo establecer como predeterminado');
      }
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? Theme.of(context).scaffoldBackgroundColor : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: isDark ? Theme.of(context).scaffoldBackgroundColor : Colors.white,
        elevation: 0,
        title: Text(
          'Métodos de Pago',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _paymentMethods.isEmpty
              ? _buildEmptyState()
              : _buildPaymentMethodsList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addPaymentMethod,
        backgroundColor: Theme.of(context).primaryColor,
        icon: const Icon(Icons.add_card, color: Colors.white),
        label: const Text(
          'Agregar Método',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.credit_card_off,
            size: 100,
            color: isDark ? Colors.grey[700] : Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            'No tienes métodos de pago',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Agrega una tarjeta para realizar pagos',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[500] : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsList() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: _paymentMethods.length,
      itemBuilder: (context, index) {
        final method = _paymentMethods[index];
        final card = method['card'] as Map<String, dynamic>;
        final brand = card['brand'] as String;
        final last4 = card['last4'] as String;
        final expMonth = card['exp_month'];
        final expYear = card['exp_year'];
        final paymentMethodId = method['id'] as String;

        // Verificar si es el método predeterminado
        final isDefault = _defaultPaymentMethodId == paymentMethodId;

        return Card(
          margin: const EdgeInsets.only(bottom: 15),
          elevation: 2,
          color: isDark ? Theme.of(context).cardColor : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: isDefault
                ? BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  )
                : BorderSide.none,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _getCardIcon(brand),
                      size: 40,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_getCardBrandName(brand)} •••• $last4',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            'Vence $expMonth/$expYear',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isDefault)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Predeterminada',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!isDefault)
                      TextButton.icon(
                        onPressed: () =>
                            _setDefaultPaymentMethod(paymentMethodId),
                        icon: const Icon(Icons.star_border, size: 18),
                        label: const Text('Predeterminada'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.amber[700],
                        ),
                      ),
                    TextButton.icon(
                      onPressed: () => _deletePaymentMethod(paymentMethodId),
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Eliminar'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getCardIcon(String brand) {
    switch (brand.toLowerCase()) {
      case 'visa':
        return Icons.credit_card;
      case 'mastercard':
        return Icons.credit_card;
      case 'amex':
        return Icons.credit_card;
      default:
        return Icons.payment;
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
}
