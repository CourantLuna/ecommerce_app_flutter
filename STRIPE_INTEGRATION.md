# Integración de Stripe - Guía de Uso

## ✅ Configuración Completada

### 1. Variables de Entorno (.env)
```
STRIPE_PUBLISHABLE_KEY=pk_test_51SrWuK....
STRIPE_SECRET_KEY=sk_test_51Sr....
```

### 2. Dependencias Instaladas
- `flutter_stripe: ^11.3.0`
- `http: ^1.2.2`

### 3. Servicios Creados

#### StripeService (`lib/src/services/stripe_service.dart`)
- `initialize()`: Inicializa Stripe con la clave publicable
- `createStripeCustomer()`: Crea un cliente en Stripe
- `ensureStripeCustomer()`: Verifica y crea perfil de Stripe automáticamente
- `createSetupIntent()`: Crea un SetupIntent para guardar métodos de pago
- `getPaymentMethods()`: Obtiene todos los métodos de pago del usuario
- `deletePaymentMethod()`: Elimina un método de pago
- `setDefaultPaymentMethod()`: Establece un método como predeterminado

### 4. Base de Datos
Se agregó el campo `stripeCustomerId` a la colección `users` en Firestore.

### 5. Flujo Automático
1. Al registrarse o iniciar sesión, se verifica si el usuario tiene `stripeCustomerId`
2. Si no existe, se crea automáticamente un cliente en Stripe
3. El ID del cliente se guarda en Firestore

## 📱 Uso de la Aplicación

### Acceder a Métodos de Pago
1. Ve a **Perfil** en la app
2. Toca en **"Mis Métodos de Pago"**
3. Si no tienes métodos, verás una pantalla vacía

### Agregar Método de Pago
1. Toca el botón flotante **"Agregar Método"**
2. Se abrirá el Payment Sheet de Stripe
3. Completa los datos de la tarjeta
4. El método se guardará automáticamente

### Gestionar Métodos
- **Ver detalles**: Cada tarjeta muestra marca, últimos 4 dígitos y fecha de vencimiento
- **Predeterminada**: La primera tarjeta se marca como predeterminada
- **Cambiar predeterminada**: Toca "Predeterminada" en otra tarjeta
- **Eliminar**: Toca "Eliminar" y confirma

## 🧪 Tarjetas de Prueba

Para probar en modo test, usa estas tarjetas:

### ✅ Tarjeta Exitosa
- **Número**: 4242 4242 4242 4242
- **Fecha**: Cualquier fecha futura (ej: 12/25)
- **CVC**: Cualquier 3 dígitos (ej: 123)
- **ZIP**: Cualquier código postal

### ❌ Tarjeta Declinada
- **Número**: 4000 0000 0000 0002
- Simula un pago declinado

### 🔐 Tarjeta con Autenticación 3D Secure
- **Número**: 4000 0025 0000 3155
- Requiere verificación adicional

## 🔧 Próximos Pasos

### Integrar Pagos en Cart Screen
Para procesar pagos reales:
1. Usar `createPaymentIntent()` en lugar de `createSetupIntent()`
2. Pasar el monto del pedido
3. Llamar a `confirmPayment()` de Stripe
4. Guardar el pedido en Firestore al confirmar el pago

### Ejemplo de Payment Intent
```dart
Future<void> _processPayment(double amount) async {
  // 1. Crear PaymentIntent en el servidor
  final paymentIntent = await createPaymentIntent(amount);
  
  // 2. Confirmar pago con Stripe
  await Stripe.instance.confirmPayment(
    paymentIntentClientSecret: paymentIntent['clientSecret'],
  );
  
  // 3. Guardar orden en Firestore
  await saveOrder();
}
```

## 📋 Estructura de Archivos

```
lib/
├── src/
│   ├── services/
│   │   ├── stripe_service.dart       (Nuevo)
│   │   └── auth_service.dart         (Actualizado)
│   └── views/
│       └── screens/
│           ├── settings_screen/
│           │   └── payment_methods_screen.dart  (Nuevo)
│           └── tabs_screens/
│               └── profile_screen/
│                   └── profile_screen.dart      (Actualizado)
└── main.dart                         (Actualizado)
```

## ⚠️ Importante

- **Modo Test**: Actualmente configurado con claves de prueba
- **Producción**: Cambiar las claves en `.env` por las de producción cuando estés listo
- **Seguridad**: NUNCA subir el archivo `.env` a Git (ya está en `.gitignore`)
- **Servidor**: Para producción, considera crear un backend para manejar las llamadas a Stripe API (más seguro)

## 🐛 Solución de Problemas

### Error: "No se pudo crear el SetupIntent"
- Verifica que el usuario tenga `stripeCustomerId` en Firestore
- Comprueba que las claves de Stripe sean correctas

### Error: "Stripe not initialized"
- Asegúrate de que `StripeService().initialize()` se llama en `main.dart`
- Verifica que el `.env` esté cargado correctamente

### La tarjeta no se guarda
- Revisa la consola para ver logs de errores
- Verifica que el cliente de Stripe exista
- Confirma que estás usando tarjetas de prueba válidas
