import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class DataSeederService {
  // Aseguramos conectar a tu base de datos específica
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'profileappdb', 
  );

  // ==========================================
  // 🍔 DATA DUMMY MAESTRA (Restaurantes + Menú anidado)
  // ==========================================
  final List<Map<String, dynamic>> _allData = [
    // --- 1. RESTAURANTE ITALIANO ---
    {
      "name": "La Trattoria Romana",
      "imageUrl": "https://images.unsplash.com/photo-1559339352-11d035aa65de?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80",
      "foodType": "Italiana",
      "rating": 4.7,
      "ratingCount": 320,
      "deliveryTime": "30-45 min",
      "deliveryFee": "\$75",
      "address": "Calle Las Damas #5, Zona Colonial, Santo Domingo",
      "latitude": 18.4735,
      "longitude": -69.8836,
      "tags": ["Pasta", "Pizza", "Vinos", "Romántico"],
      "menu": [
        {
          "name": "Pizza Margarita",
          "description": "Salsa de tomate San Marzano, mozzarella di bufala y albahaca fresca.",
          "price": 550.00,
          "imageUrl": "https://images.unsplash.com/photo-1574071318508-1cdbab80d002?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60",
          "category": "Pizzas"
        },
        {
          "name": "Fettuccine Alfredo",
          "description": "Pasta fresca con salsa cremosa de queso parmesano y mantequilla.",
          "price": 480.00,
          "imageUrl": "https://images.unsplash.com/photo-1645112411341-6c4fd023714a?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60",
          "category": "Pastas"
        },
        {
          "name": "Lasaña de Carne",
          "description": "Capas de pasta, carne molida, salsa bechamel y queso gratinado.",
          "price": 520.00,
          "imageUrl": "https://images.unsplash.com/photo-1574868291534-1888645a2c39?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60",
          "category": "Pastas"
        },
         {
          "name": "Tiramisú",
          "description": "Postre clásico italiano con café y mascarpone.",
          "price": 250.00,
          "imageUrl": "https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60",
          "category": "Postres"
        }
      ]
    },

    // --- 2. RESTAURANTE DE HAMBURGUESAS ---
    {
      "name": "Burger Factory",
      "imageUrl": "https://images.unsplash.com/photo-1586816001966-79b736744398?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80",
      "foodType": "Americana",
      "rating": 4.5,
      "ratingCount": 540,
      "deliveryTime": "20-30 min",
      "deliveryFee": "Free",
      "address": "Av. Winston Churchill, Plaza Central, Santo Domingo",
      "latitude": 18.4700,
      "longitude": -69.9400,
      "tags": ["Burgers", "Fast Food", "Papas Fritas"],
      "menu": [
        {
          "name": "Classic Cheeseburger",
          "description": "Carne angus 8oz, queso cheddar americano, lechuga y tomate.",
          "price": 350.00,
          "imageUrl": "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60",
          "category": "Burgers"
        },
        {
          "name": "Bacon Lovers",
          "description": "Doble carne, cuádruple tocino, salsa BBQ y aros de cebolla.",
          "price": 450.00,
          "imageUrl": "https://images.unsplash.com/photo-1594212699903-ec8a3eca50f5?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60",
          "category": "Burgers"
        },
        {
          "name": "Papas Trufadas",
          "description": "Papas fritas con aceite de trufa y queso parmesano.",
          "price": 200.00,
          "imageUrl": "https://images.unsplash.com/photo-1573080496987-a199f8cd75c5?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60",
          "category": "Acompañamientos"
        }
      ]
    },

    // --- 3. RESTAURANTE ASIÁTICO ---
    {
      "name": "Sushi Zen",
      "imageUrl": "https://images.unsplash.com/photo-1579871494447-9811cf80d66c?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80",
      "foodType": "Asiática",
      "rating": 4.8,
      "ratingCount": 120,
      "deliveryTime": "40-50 min",
      "deliveryFee": "\$100",
      "address": "BlueMall, Piso 3, Santo Domingo",
      "latitude": 18.4861,
      "longitude": -69.9312,
      "tags": ["Sushi", "Japonesa", "Healthy"],
      "menu": [
        {
          "name": "Dragon Roll",
          "description": "Camarón tempura, aguacate, cubierto de anguila y salsa dulce.",
          "price": 580.00,
          "imageUrl": "https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60",
          "category": "Rolls"
        },
        {
          "name": "Spicy Tuna Roll",
          "description": "Atún fresco picante, pepino y sésamo.",
          "price": 420.00,
          "imageUrl": "https://images.unsplash.com/photo-1617196019294-dc44dfacb251?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60",
          "category": "Rolls"
        },
        {
          "name": "Gyozas de Cerdo",
          "description": "Empanaditas japonesas al vapor o fritas (5 unidades).",
          "price": 300.00,
          "imageUrl": "https://images.unsplash.com/photo-1496116218417-1a781b1c416c?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60",
          "category": "Entradas"
        }
      ]
    },

    // --- 4. RESTAURANTE CRIOLLO (DOMINICANO) ---
    {
      "name": "El Sazón de Doña Ana",
      "imageUrl": "https://images.unsplash.com/photo-1547592180-85f173990554?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80",
      "foodType": "Criolla",
      "rating": 4.9,
      "ratingCount": 85,
      "deliveryTime": "35-45 min",
      "deliveryFee": "\$50",
      "address": "Calle El Conde, Zona Colonial, Santo Domingo",
      "latitude": 18.4655,
      "longitude": -69.8876,
      "tags": ["Dominicana", "Almuerzo", "Económico"],
      "menu": [
        {
          "name": "La Bandera Dominicana",
          "description": "Arroz blanco, habichuelas rojas guisadas y pollo guisado.",
          "price": 250.00,
          "imageUrl": "https://i0.wp.com/www.cocinadominicana.com/wp-content/uploads/2023/02/bandera-dominicana-arroz-habichuelas-pollo-1.jpg?fit=1200%2C901&ssl=1", 
          "category": "Almuerzos"
        },
        {
          "name": "Mofongo de Chicharrón",
          "description": "Plátano majado con ajo y chicharrón crujiente, servido con caldo.",
          "price": 350.00,
          "imageUrl": "https://imag.bonviveur.com/mofongo-foto-cerca.jpg",
          "category": "Platos Fuertes"
        },
        {
          "name": "Jugo de Chinola Natural",
          "description": "Jugo recién hecho de maracuyá.",
          "price": 100.00,
          "imageUrl": "https://images.unsplash.com/photo-1623065422902-30a2d299bbe4?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60",
          "category": "Bebidas"
        }
      ]
    },
     // --- 5. TACOS MEXICANOS ---
    {
      "name": "Tacos El Guero",
      "imageUrl": "https://images.unsplash.com/photo-1504674900247-0877df9cc836?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80",
      "foodType": "Mexicana",
      "rating": 4.6,
      "ratingCount": 210,
      "deliveryTime": "15-25 min",
      "deliveryFee": "\$60",
      "address": "Av. Abraham Lincoln, Santo Domingo",
      "latitude": 18.4760,
      "longitude": -69.9500,
      "tags": ["Tacos", "Picante", "Noche"],
      "menu": [
        {
          "name": "Tacos al Pastor (3)",
          "description": "Cerdo marinado, piña, cilantro y cebolla.",
          "price": 280.00,
          "imageUrl": "https://images.unsplash.com/photo-1551504734-5ee1c4a1479b?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60",
          "category": "Tacos"
        },
        {
          "name": "Quesadilla de Pollo",
          "description": "Tortilla de harina grande con queso fundido y pollo.",
          "price": 320.00,
          "imageUrl": "https://images.unsplash.com/photo-1618040996337-56904b7850b9?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60",
          "category": "Quesadillas"
        },
        {
          "name": "Nachos Supremos",
          "description": "Totopos con queso, frijoles, jalapeños, crema y guacamole.",
          "price": 400.00,
          "imageUrl": "https://images.unsplash.com/photo-1582169296194-e9d648411dff?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60",
          "category": "Entradas"
        }
      ]
    },

    // --- 6. GREEN BOWL - HEALTHY FOOD ---
    {
      "name": "Green Bowl",
      "imageUrl": "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80",
      "foodType": "Healthy",
      "rating": 4.8,
      "ratingCount": 285,
      "deliveryTime": "25-35 min",
      "deliveryFee": "\$80",
      "address": "Av. Gustavo Mejía Ricart, Naco, Santo Domingo",
      "latitude": 18.4810,
      "longitude": -69.9350,
      "tags": ["Saludable", "Vegano", "Bowls", "Smoothies"],
      "menu": [
        {
          "name": "Poke Bowl de Salmón",
          "description": "Arroz sushi, salmón fresco, edamame, aguacate, pepino y sésamo.",
          "price": 520.00,
          "imageUrl": "https://images.unsplash.com/photo-1546069901-d5bfd2cbfb1f?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60",
          "category": "Bowls"
        },
        {
          "name": "Buddha Bowl Vegetariano",
          "description": "Quinoa, garbanzos rostizados, hummus, col morada y tahini.",
          "price": 380.00,
          "imageUrl": "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60",
          "category": "Bowls"
        },
        {
          "name": "Green Smoothie Detox",
          "description": "Espinaca, piña, pepino, jengibre y menta.",
          "price": 220.00,
          "imageUrl": "https://images.unsplash.com/photo-1610970881699-44a5587cabec?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60",
          "category": "Bebidas"
        },
        {
          "name": "Ensalada César con Pollo",
          "description": "Lechuga romana, pollo grillado, parmesano, crutones y aderezo césar.",
          "price": 420.00,
          "imageUrl": "https://images.unsplash.com/photo-1546793665-c74683f339c1?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60",
          "category": "Ensaladas"
        }
      ]
    },

    // --- 7. TAMASHI JAPANESE CUISINE ---
    {
      "name": "Tamashi Japanese Cuisine",
      "imageUrl": "https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80",
      "foodType": "Asiática",
      "rating": 4.9,
      "ratingCount": 410,
      "deliveryTime": "35-50 min",
      "deliveryFee": "\$120",
      "address": "Av. Anacaona, Los Cacicazgos, Santo Domingo",
      "latitude": 18.4640,
      "longitude": -69.9280,
      "tags": ["Japonesa", "Sushi Premium", "Ramen", "Sake"],
      "menu": [
        {
          "name": "Ramen Tonkotsu",
          "description": "Caldo de hueso de cerdo, chashu, huevo marinado, nori y cebollín.",
          "price": 650.00,
          "imageUrl": "https://images.unsplash.com/photo-1569718212165-3a8278d5f624?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60",
          "category": "Ramen"
        },
        {
          "name": "Sashimi Premium (12 piezas)",
          "description": "Selección del chef: salmón, atún, hamachi y pez mantequilla.",
          "price": 780.00,
          "imageUrl": "https://images.unsplash.com/photo-1583623025817-d180a2221d0a?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60",
          "category": "Sashimi"
        },
        {
          "name": "Rainbow Roll",
          "description": "California roll cubierto con salmón, atún, aguacate y masago.",
          "price": 620.00,
          "imageUrl": "https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60",
          "category": "Rolls"
        },
        {
          "name": "Tempura Mixta",
          "description": "Camarones y vegetales en tempura con salsa tentsuyu.",
          "price": 480.00,
          "imageUrl": "https://images.unsplash.com/photo-1562158147-f8c8d8b3e1b4?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60",
          "category": "Entradas"
        }
      ]
    },

    // --- 8. PAT'E PALO EUROPEAN BRASSERIE ---
    {
      "name": "Pat'e Palo European Brasserie",
      "imageUrl": "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80",
      "foodType": "Europea",
      "rating": 4.7,
      "ratingCount": 195,
      "deliveryTime": "40-55 min",
      "deliveryFee": "\$100",
      "address": "Calle La Atarazana, Zona Colonial, Santo Domingo",
      "latitude": 18.4720,
      "longitude": -69.8830,
      "tags": ["Europea", "Fine Dining", "Steaks", "Vinos"],
      "menu": [
        {
          "name": "Filet Mignon",
          "description": "Lomo de res 8oz con salsa de champiñones y papas gratinadas.",
          "price": 1250.00,
          "imageUrl": "https://images.unsplash.com/photo-1600891964092-4316c288032e?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60",
          "category": "Carnes"
        },
        {
          "name": "Paella Valenciana",
          "description": "Arroz con mariscos, pollo, chorizo y azafrán.",
          "price": 980.00,
          "imageUrl": "https://images.unsplash.com/photo-1534080564583-6be75777b70a?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60",
          "category": "Especialidades"
        },
        {
          "name": "Risotto de Hongos",
          "description": "Arroz arborio con mezcla de hongos silvestres y trufa.",
          "price": 720.00,
          "imageUrl": "https://images.unsplash.com/photo-1476124369491-c4ca2990d6c8?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60",
          "category": "Pastas y Arroces"
        }
      ]
    },

    // --- 9. EL MESÓN DE LA CAVA ---
    {
      "name": "El Mesón de la Cava",
      "imageUrl": "https://images.unsplash.com/photo-1590846406792-0adc7f938f1d?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80",
      "foodType": "Criolla",
      "rating": 4.6,
      "ratingCount": 340,
      "deliveryTime": "35-50 min",
      "deliveryFee": "\$90",
      "address": "Av. Mirador Sur, Mirador Sur, Santo Domingo",
      "latitude": 18.4580,
      "longitude": -69.9450,
      "tags": ["Dominicana", "Mariscos", "Caribeña", "Ambiente"],
      "menu": [
        {
          "name": "Chivo Guisado",
          "description": "Carne de chivo en salsa criolla con yuca y tostones.",
          "price": 580.00,
          "imageUrl": "https://images.unsplash.com/photo-1626645738196-c2a7c87a8f58?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60",
          "category": "Platos Típicos"
        },
        {
          "name": "Langosta a la Criolla",
          "description": "Langosta en salsa criolla con arroz blanco y ensalada.",
          "price": 1450.00,
          "imageUrl": "https://images.unsplash.com/photo-1626645738196-c2a7c87a8f58?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60",
          "category": "Mariscos"
        },
        {
          "name": "Casabe con Aguacate",
          "description": "Torta de casabe artesanal con aguacate y queso frito.",
          "price": 280.00,
          "imageUrl": "https://images.unsplash.com/photo-1509440159596-0249088772ff?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60",
          "category": "Entradas"
        }
      ]
    },

    // --- 10. ADRIAN TROPICAL ---
    {
      "name": "Adrian Tropical",
      "imageUrl": "https://images.unsplash.com/photo-1544025162-d76694265947?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80",
      "foodType": "Criolla",
      "rating": 4.4,
      "ratingCount": 620,
      "deliveryTime": "30-40 min",
      "deliveryFee": "\$60",
      "address": "Av. George Washington (Malecón), Santo Domingo",
      "latitude": 18.4625,
      "longitude": -69.9050,
      "tags": ["Dominicana", "24 Horas", "Buffet", "Familiar"],
      "menu": [
        {
          "name": "Yaroa Mixta",
          "description": "Plátanos majados con carne, pollo, queso y salsas.",
          "price": 380.00,
          "imageUrl": "https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60",
          "category": "Especialidades"
        },
        {
          "name": "Chicharrón de Pollo con Tostones",
          "description": "Pollo frito crujiente con tostones y ensalada.",
          "price": 320.00,
          "imageUrl": "https://images.unsplash.com/photo-1626645738196-c2a7c87a8f58?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60",
          "category": "Pollo"
        },
        {
          "name": "Sancocho Dominicano",
          "description": "Sopa de siete carnes con tubérculos y aguacate.",
          "price": 420.00,
          "imageUrl": "https://images.unsplash.com/photo-1547592166-23ac45744acd?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60",
          "category": "Sopas"
        },
        {
          "name": "Morir Soñando",
          "description": "Bebida típica de leche con jugo de naranja y hielo.",
          "price": 120.00,
          "imageUrl": "https://images.unsplash.com/photo-1624222247344-550fb60583bb?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60",
          "category": "Bebidas"
        }
      ]
    },

    // --- 11. NOAH RESTAURANT & LOUNGE ---
    {
      "name": "Noah Restaurant & Lounge",
      "imageUrl": "https://images.unsplash.com/photo-1414235077428-338989a2e8c0?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80",
      "foodType": "Internacional",
      "rating": 4.7,
      "ratingCount": 275,
      "deliveryTime": "40-55 min",
      "deliveryFee": "\$110",
      "address": "Plaza Andalucía II, Bella Vista, Santo Domingo",
      "latitude": 18.4670,
      "longitude": -69.9320,
      "tags": ["Fusión", "Steaks", "Mariscos", "Cocktails"],
      "menu": [
        {
          "name": "Pulpo a la Parrilla",
          "description": "Pulpo con papas confitadas, pimientos y alioli de ajo negro.",
          "price": 980.00,
          "imageUrl": "https://images.unsplash.com/photo-1599084993091-1cb5c0721cc6?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60",
          "category": "Mariscos"
        },
        {
          "name": "Ribeye 12oz",
          "description": "Carne angus madurada con mantequilla de hierbas y vegetales.",
          "price": 1380.00,
          "imageUrl": "https://images.unsplash.com/photo-1558030006-450675393462?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60",
          "category": "Carnes"
        },
        {
          "name": "Tártaro de Atún",
          "description": "Atún rojo con aguacate, sésamo y salsa ponzu.",
          "price": 720.00,
          "imageUrl": "https://images.unsplash.com/photo-1580959375944-356f4f43f4a6?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60",
          "category": "Entradas"
        }
      ]
    },

    // --- 12. SBG SANTO DOMINGO ---
    {
      "name": "SBG Santo Domingo",
      "imageUrl": "https://images.unsplash.com/photo-1552566626-52f8b828add9?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80",
      "foodType": "Internacional",
      "rating": 4.8,
      "ratingCount": 310,
      "deliveryTime": "45-60 min",
      "deliveryFee": "\$130",
      "address": "Hotel Sofitel Juan Dolio, Juan Dolio",
      "latitude": 18.4320,
      "longitude": -69.4320,
      "tags": ["Gourmet", "Mediterránea", "Vista al Mar", "Lujo"],
      "menu": [
        {
          "name": "Ceviche Peruano",
          "description": "Pescado blanco marinado en limón con cebolla morada y camote.",
          "price": 680.00,
          "imageUrl": "https://images.unsplash.com/photo-1617093727343-374698b1b08d?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60",
          "category": "Mariscos"
        },
        {
          "name": "Medallones de Cordero",
          "description": "Cordero con puré de papas trufado y reducción de vino tinto.",
          "price": 1580.00,
          "imageUrl": "https://images.unsplash.com/photo-1633504581786-316c8002b1b2?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60",
          "category": "Carnes"
        },
        {
          "name": "Carpaccio de Res",
          "description": "Láminas finas de res con rúcula, parmesano y aceite de trufa.",
          "price": 850.00,
          "imageUrl": "https://images.unsplash.com/photo-1608877907149-a206d75ba011?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60",
          "category": "Entradas"
        }
      ]
    }
  ];

  // ==========================================
  // 🚀 LÓGICA DE SEPARACIÓN Y SUBIDA
  // ==========================================
  Future<void> uploadDummyData() async {
    print("🚀 --- INICIANDO IMPORTACIÓN DE RESTAURANTES Y PLATOS ---");

    try {
      final WriteBatch batch = _firestore.batch();
      
      int countRest = 0;
      int countProducts = 0;

      for (var restaurantMap in _allData) {
        // PASO 1: Crear REFERENCIA del Restaurante (Aquí se genera el ID 'xyz123')
        DocumentReference restRef = _firestore.collection('restaurants').doc();
        String restaurantId = restRef.id;

        // PASO 2: Separar el menú de la info del restaurante
        // No queremos guardar el array 'menu' dentro de la colección 'restaurants'
        // porque los platos van a su propia colección.
        List<Map<String, dynamic>> menuItems = restaurantMap['menu'] as List<Map<String, dynamic>>;
        
        Map<String, dynamic> restaurantInfo = Map.from(restaurantMap);
        restaurantInfo.remove('menu'); // Quitamos el menú de este objeto
        
        // Agregamos campos de auditoría
        restaurantInfo['id'] = restaurantId; 
        restaurantInfo['createdAt'] = FieldValue.serverTimestamp();

        // Agregamos al Batch (Cola de guardado)
        batch.set(restRef, restaurantInfo);
        countRest++;

        // PASO 3: Crear los PLATOS asociados a este Restaurante
        for (var dish in menuItems) {
          DocumentReference productRef = _firestore.collection('products').doc();

          batch.set(productRef, {
            'id': productRef.id,
            'restaurantId': restaurantId, // <--- AQUÍ ESTÁ LA MAGIA (Foreign Key)
            'name': dish['name'],
            'description': dish['description'],
            'price': dish['price'], // Asegúrate que sea double o int
            'imageUrl': dish['imageUrl'],
            'category': dish['category'],
            'isAvailable': true,
            'createdAt': FieldValue.serverTimestamp(),
          });
          countProducts++;
        }
      }

      // PASO 4: Guardar todo de golpe
      await batch.commit();
      
      print("✅ IMPORTACIÓN FINALIZADA CON ÉXITO");
      print("📊 Restaurantes creados: $countRest");
      print("🍔 Platos creados: $countProducts");
      print("------------------------------------------------");

    } catch (e) {
      print("❌ ERROR CRÍTICO EN SEEDER: $e");
    }
  }
}