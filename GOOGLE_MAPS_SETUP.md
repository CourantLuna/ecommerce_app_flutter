# Configuración de Google Maps APIs

## Error "Forbidden" en búsqueda de lugares

Si recibes un error **403 Forbidden** al buscar ubicaciones, es porque faltan habilitar algunas APIs en Google Cloud Console.

## APIs Requeridas

Tu API Key necesita tener habilitadas las siguientes APIs:

1. **Maps JavaScript API** ✅ (para mostrar mapas)
2. **Places API (New)** ⚠️ (para búsqueda de lugares)
3. **Geocoding API** ⚠️ (para convertir direcciones a coordenadas)
4. **Geolocation API** ⚠️ (para obtener ubicación actual)

## Pasos para Habilitar las APIs

### 1. Ir a Google Cloud Console
- Visita: https://console.cloud.google.com/
- Selecciona tu proyecto: **profilesapp1107303**

### 2. Habilitar Places API
1. En el menú lateral, ve a **APIs & Services** → **Library**
2. Busca **"Places API"** (la versión nueva)
3. Click en **"Places API (New)"**
4. Click en **ENABLE**

### 3. Habilitar Geocoding API
1. En Library, busca **"Geocoding API"**
2. Click en **Geocoding API**
3. Click en **ENABLE**

### 4. Habilitar Geolocation API
1. En Library, busca **"Geolocation API"**
2. Click en **Geolocation API**
3. Click en **ENABLE**

### 5. Verificar Restricciones de la API Key

1. Ve a **APIs & Services** → **Credentials**
2. Click en tu API Key existente
3. En **API restrictions**, selecciona **"Restrict key"**
4. Marca las siguientes APIs:
   - ✅ Maps JavaScript API
   - ✅ Places API (New)
   - ✅ Geocoding API
   - ✅ Geolocation API
5. Click en **SAVE**

### 6. Configurar Billing

⚠️ **IMPORTANTE**: Google Maps APIs requieren una cuenta de facturación activa, aunque tienen un nivel gratuito generoso:

- **$200 USD de crédito mensual gratis**
- La mayoría de apps pequeñas no exceden este límite

Para agregar facturación:
1. Ve a **Billing** en el menú lateral
2. Click en **Link a billing account**
3. Sigue los pasos para agregar una tarjeta

## Créditos Gratuitos Mensuales

Google Maps ofrece créditos generosos:

| API | Uso Gratuito Mensual |
|-----|---------------------|
| Maps JavaScript API | 28,500 cargas de mapa |
| Places API | 28,500 solicitudes |
| Geocoding API | 28,500 solicitudes |
| Geolocation API | 40,000 solicitudes |

## Restricciones Recomendadas

### Para Desarrollo:
```
Application restrictions: None
API restrictions: Select APIs (las 4 mencionadas arriba)
```

### Para Producción:
```
Application restrictions: 
  - HTTP referrers (websites): https://tu-dominio.com/*
  - Android apps: SHA-1 de tu app
API restrictions: Select APIs
```

## Verificar que Funciona

Después de habilitar las APIs, espera 1-2 minutos y prueba:

1. **Buscar lugar**: Escribe en el campo de búsqueda
2. **Mi Ubicación**: Click en el botón "Mi Ubicación"
3. **Arrastrar pin**: Mueve el pin en el mapa

## Troubleshooting

### Error persiste después de habilitar APIs
- Espera 5 minutos (propagación de cambios)
- Limpia caché del navegador
- Recarga la app con `flutter run`

### Error de billing
- Verifica que la cuenta de facturación esté activa
- Revisa que el proyecto tenga billing asociado

### Error de permisos
- Verifica que el proyecto tenga las APIs habilitadas
- Revisa que la API Key tenga las restricciones correctas

## API Key Actual

Tu API Key: `AIzaSyBbEFBI9qAztbHoVkVr8mMrKT7bq6EIVW4`

**Ubicación en el código:**
- `.env` → `GOOGLE_MAPS_API_KEY`
- `web/index.html` → Script tag
- `add_edit_address_screen.dart` → Carga desde dotenv

## Recursos

- [Google Maps Platform](https://cloud.google.com/maps-platform)
- [Places API Docs](https://developers.google.com/maps/documentation/places/web-service)
- [Pricing Calculator](https://mapsplatform.google.com/pricing/)
