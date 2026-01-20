import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class StripeService {
  static final StripeService _instance = StripeService._internal();
  factory StripeService() => _instance;
  StripeService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'profileappdb',
  );

  String get _publishableKey => dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
  String get _secretKey => dotenv.env['STRIPE_SECRET_KEY'] ?? '';

  // Inicializar Stripe (llamar en main.dart)
  Future<void> initialize() async {
    if (kIsWeb) {
      print('⚠️ Stripe no está disponible en Flutter Web');
      return;
    }
    Stripe.publishableKey = _publishableKey;
    await Stripe.instance.applySettings();
  }

  // ========================================
  // CREAR CLIENTE DE STRIPE
  // ========================================
  Future<String?> createStripeCustomer({
    required String email,
    required String name,
    String? phone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/customers'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'email': email,
          'name': name,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['id'] as String;
      } else {
        print('Error creando cliente Stripe: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error en createStripeCustomer: $e');
      return null;
    }
  }

  // ========================================
  // VERIFICAR Y CREAR PERFIL DE STRIPE SI NO EXISTE
  // ========================================
  Future<void> ensureStripeCustomer(User user) async {
    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      
      if (!userDoc.exists) {
        print('⚠️ Usuario no existe en Firestore');
        return;
      }

      final userData = userDoc.data()!;
      final stripeCustomerId = userData['stripeCustomerId'] as String?;

      // Si ya tiene stripeCustomerId, no hacer nada
      if (stripeCustomerId != null && stripeCustomerId.isNotEmpty) {
        print('✅ Usuario ya tiene Stripe Customer ID: $stripeCustomerId');
        return;
      }

      // Crear nuevo cliente en Stripe
      print('🔧 Creando cliente de Stripe...');
      final customerId = await createStripeCustomer(
        email: user.email ?? '',
        name: user.displayName ?? 'Usuario',
        phone: userData['phone'] as String?,
      );

      if (customerId != null) {
        // Guardar en Firestore
        await _firestore.collection('users').doc(user.uid).update({
          'stripeCustomerId': customerId,
        });
        print('✅ Cliente Stripe creado: $customerId');
      }
    } catch (e) {
      print('Error en ensureStripeCustomer: $e');
    }
  }

  // ========================================
  // CREAR SETUP INTENT (Para guardar método de pago)
  // ========================================
  Future<Map<String, dynamic>?> createSetupIntent() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      // Obtener stripeCustomerId
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final stripeCustomerId = userDoc.data()?['stripeCustomerId'] as String?;

      if (stripeCustomerId == null) {
        print('⚠️ Usuario no tiene stripeCustomerId');
        return null;
      }

      // Crear SetupIntent en Stripe
      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/setup_intents'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'customer': stripeCustomerId,
          'payment_method_types[]': 'card',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'clientSecret': data['client_secret'],
          'setupIntentId': data['id'],
        };
      } else {
        print('Error creando SetupIntent: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error en createSetupIntent: $e');
      return null;
    }
  }

  // ========================================
  // OBTENER MÉTODOS DE PAGO DEL USUARIO
  // ========================================
  Future<List<Map<String, dynamic>>> getPaymentMethods() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final stripeCustomerId = userDoc.data()?['stripeCustomerId'] as String?;

      if (stripeCustomerId == null) return [];

      final response = await http.get(
        Uri.parse(
          'https://api.stripe.com/v1/customers/$stripeCustomerId/payment_methods?type=card',
        ),
        headers: {
          'Authorization': 'Bearer $_secretKey',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final methods = data['data'] as List;
        return methods.map((m) => m as Map<String, dynamic>).toList();
      }

      return [];
    } catch (e) {
      print('Error obteniendo métodos de pago: $e');
      return [];
    }
  }

  // ========================================
  // ELIMINAR MÉTODO DE PAGO
  // ========================================
  Future<bool> deletePaymentMethod(String paymentMethodId) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_methods/$paymentMethodId/detach'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error eliminando método de pago: $e');
      return false;
    }
  }

  // ========================================
  // OBTENER MÉTODO DE PAGO PREDETERMINADO
  // ========================================
  Future<String?> getDefaultPaymentMethod() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final stripeCustomerId = userDoc.data()?['stripeCustomerId'] as String?;

      if (stripeCustomerId == null) return null;

      final response = await http.get(
        Uri.parse('https://api.stripe.com/v1/customers/$stripeCustomerId'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['invoice_settings']?['default_payment_method'] as String?;
      }
      return null;
    } catch (e) {
      print('Error obteniendo método predeterminado: $e');
      return null;
    }
  }

  // ========================================
  // ESTABLECER MÉTODO DE PAGO COMO PREDETERMINADO
  // ========================================
  Future<bool> setDefaultPaymentMethod(String paymentMethodId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final stripeCustomerId = userDoc.data()?['stripeCustomerId'] as String?;

      if (stripeCustomerId == null) return false;

      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/customers/$stripeCustomerId'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'invoice_settings[default_payment_method]': paymentMethodId,
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error estableciendo método predeterminado: $e');
      return false;
    }
  }

  // ========================================
  // CREAR PAYMENT INTENT (Para procesar pagos)
  // ========================================
  Future<Map<String, dynamic>?> createPaymentIntent({
    required double amount,
    required String currency,
    String? paymentMethodId,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final stripeCustomerId = userDoc.data()?['stripeCustomerId'] as String?;

      if (stripeCustomerId == null) {
        print('⚠️ Usuario no tiene stripeCustomerId');
        return null;
      }

      // Convertir monto a centavos
      final amountInCents = (amount * 100).toInt();

      final body = {
        'amount': amountInCents.toString(),
        'currency': currency.toLowerCase(),
        'customer': stripeCustomerId,
        'automatic_payment_methods[enabled]': 'true',
      };

      // Si se proporciona un método de pago específico
      if (paymentMethodId != null && paymentMethodId.isNotEmpty) {
        body['payment_method'] = paymentMethodId;
        body['confirm'] = 'true';
        body['off_session'] = 'true';
      }

      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'clientSecret': data['client_secret'],
          'paymentIntentId': data['id'],
          'status': data['status'],
        };
      } else {
        print('Error creando PaymentIntent: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error en createPaymentIntent: $e');
      return null;
    }
  }

  // ========================================
  // CONFIRMAR PAGO
  // ========================================
  Future<Map<String, dynamic>?> confirmPayment({
    required String paymentIntentId,
    required String paymentMethodId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents/$paymentIntentId/confirm'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'payment_method': paymentMethodId,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'status': data['status'],
          'paymentIntentId': data['id'],
        };
      } else {
        print('Error confirmando pago: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error en confirmPayment: $e');
      return null;
    }
  }
}
