import 'dart:js' as js;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class StripeWebService {
  static final StripeWebService _instance = StripeWebService._internal();
  factory StripeWebService() => _instance;
  StripeWebService._internal();

  String get _publishableKey => dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';

  // Inicializar Stripe.js
  void initialize() {
    if (js.context.hasProperty('Stripe')) {
      js.context['stripeInstance'] = js.context.callMethod('Stripe', [_publishableKey]);
      print('✅ Stripe.js inicializado en web');
    } else {
      print('⚠️ Stripe.js no está cargado');
    }
  }

  // Crear Checkout Session para agregar método de pago
  Future<String?> createCheckoutSession(String clientSecret) async {
    try {
      if (!js.context.hasProperty('Stripe')) {
        print('⚠️ Stripe no está disponible');
        return null;
      }

      final stripe = js.context['stripeInstance'];
      
      // Redirigir a Checkout para Setup Mode
      final result = await _redirectToCheckout(stripe, clientSecret);
      
      return result;
    } catch (e) {
      print('Error en createCheckoutSession: $e');
      return null;
    }
  }

  Future<String?> _redirectToCheckout(dynamic stripe, String clientSecret) async {
    try {
      // Confirmar el setup usando Stripe Elements
      js.context.callMethod('eval', [
        '''
        (async function() {
          try {
            const stripe = window.stripeInstance;
            
            // Crear elementos de Stripe
            const elements = stripe.elements({
              clientSecret: '$clientSecret',
            });
            
            // Crear el Payment Element
            const paymentElement = elements.create('payment');
            
            // Crear un contenedor temporal
            const container = document.createElement('div');
            container.id = 'stripe-payment-element-container';
            container.style.cssText = 'position: fixed; top: 50%; left: 50%; transform: translate(-50%, -50%); background: white; padding: 20px; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); z-index: 10000; width: 400px; max-width: 90%;';
            
            const header = document.createElement('div');
            header.innerHTML = '<h3 style="margin: 0 0 20px 0;">Agregar Método de Pago</h3>';
            container.appendChild(header);
            
            const elementContainer = document.createElement('div');
            container.appendChild(elementContainer);
            
            const buttonContainer = document.createElement('div');
            buttonContainer.style.cssText = 'margin-top: 20px; display: flex; gap: 10px; justify-content: flex-end;';
            
            const cancelBtn = document.createElement('button');
            cancelBtn.textContent = 'Cancelar';
            cancelBtn.style.cssText = 'padding: 10px 20px; border: 1px solid #ccc; background: white; border-radius: 4px; cursor: pointer;';
            cancelBtn.onclick = () => {
              document.body.removeChild(container);
              window.stripeSetupResult = 'cancelled';
            };
            
            const submitBtn = document.createElement('button');
            submitBtn.textContent = 'Guardar';
            submitBtn.style.cssText = 'padding: 10px 20px; border: none; background: #5469d4; color: white; border-radius: 4px; cursor: pointer;';
            submitBtn.onclick = async () => {
              submitBtn.disabled = true;
              submitBtn.textContent = 'Procesando...';
              
              const {error} = await stripe.confirmSetup({
                elements,
                confirmParams: {
                  return_url: window.location.href,
                },
                redirect: 'if_required'
              });
              
              if (error) {
                alert(error.message);
                submitBtn.disabled = false;
                submitBtn.textContent = 'Guardar';
              } else {
                document.body.removeChild(container);
                window.stripeSetupResult = 'success';
              }
            };
            
            buttonContainer.appendChild(cancelBtn);
            buttonContainer.appendChild(submitBtn);
            container.appendChild(buttonContainer);
            
            document.body.appendChild(container);
            paymentElement.mount(elementContainer);
            
            window.stripeSetupResult = 'pending';
            
            return 'mounted';
          } catch (error) {
            console.error('Error:', error);
            return 'error:' + error.message;
          }
        })()
        '''
      ]);
      
      // Esperar a que el usuario complete o cancele
      await _waitForSetupResult();
      
      final setupResult = js.context['stripeSetupResult'];
      print('Setup result: $setupResult');
      
      return setupResult?.toString();
    } catch (e) {
      print('Error en _redirectToCheckout: $e');
      return 'error';
    }
  }

  Future<void> _waitForSetupResult() async {
    for (var i = 0; i < 600; i++) { // 60 segundos máximo
      await Future.delayed(const Duration(milliseconds: 100));
      final result = js.context['stripeSetupResult'];
      if (result != null && result.toString() != 'pending') {
        break;
      }
    }
  }
}
