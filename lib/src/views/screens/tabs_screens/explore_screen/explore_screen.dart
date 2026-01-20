import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/src/models/firestore_models.dart';
import 'package:ecommerce_app/src/views/components/header_text.dart';
import 'package:ecommerce_app/src/views/components/restaurant_card_horizontal.dart';
import 'package:ecommerce_app/src/views/components/restaurant_card_vertical.dart';
import 'package:ecommerce_app/src/views/screens/tabs_screens/explore_screen/restaurant_detail_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  // 1. VARIABLES DE ESTADO (Para búsqueda y filtros)
  String _searchQuery = "";
  String? _selectedCategory; // Si es null, muestra todo.
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // Categorías disponibles (Deben coincidir con tu 'foodType' en Firebase)
  final List<String> _categories = [
    "Todas",
    "Americana",
    "Italiana",
    "Asiática",
    "Criolla",
    "Mexicana",
    "Pollo",
    "Pizzas"
  ];

  FirebaseFirestore get _firestore => FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'profileappdb',
      );

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        // Cierra el teclado si tocas fuera (pero no si tocas el TextField)
        onTap: () {
          if (!_searchFocusNode.hasFocus) {
            FocusScope.of(context).unfocus();
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              // --- BARRA SUPERIOR CON BUSCADOR (FUERA DEL STREAM) ---
              Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _topBar(context),
                  
                    // Si hay filtro activo, mostramos un "chip" para poder quitarlo
                    if (_selectedCategory != null && _selectedCategory != "Todas")
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: ActionChip(
                          label: Text("Filtro: $_selectedCategory"),
                          avatar: const Icon(Icons.close, size: 16),
                          onPressed: () {
                            setState(() => _selectedCategory = null);
                          },
                          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                        ),
                      ),
                  ],
                ),
              ),
              
              // --- LISTA DE RESTAURANTES (DENTRO DEL STREAM) ---
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('restaurants').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("No hay restaurantes disponibles"));
                    }

                    // 2. OBTENER Y FILTRAR LA DATA
                    // Primero convertimos todo a modelos
                    List<RestaurantModel> allRestaurants = snapshot.data!.docs
                        .map((doc) => RestaurantModel.fromSnapshot(doc))
                        .toList();

                    // LÓGICA DE FILTRADO
                    final filteredRestaurants = allRestaurants.where((rest) {
                      // A. Filtro por Texto (Buscador)
                      final matchesSearch = _searchQuery.isEmpty || 
                                            rest.name.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                                            rest.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()));
                      
                      // B. Filtro por Categoría (Botón de ajustes)
                      final matchesCategory = _selectedCategory == null || 
                                              _selectedCategory == "Todas" || 
                                              rest.foodType == _selectedCategory;

                      return matchesSearch && matchesCategory;
                    }).toList();

                    // 3. Preparar las listas para la UI
                    final popularRestaurants = filteredRestaurants.where((r) => r.rating >= 4.5).toList();
                    
                    // SI NO HAY RESULTADOS
                    if (filteredRestaurants.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 60, color: Colors.grey),
                            SizedBox(height: 10),
                            Text("No encontramos restaurantes con esa búsqueda.", style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      );
                    }
                    
                    return CustomScrollView(
                      slivers: [
                        // --- SECCIÓN 1: POPULARES (Ocultar si no hay populares en la búsqueda) ---
                        if (popularRestaurants.isNotEmpty)
                          SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 15),
                                  child: HeaderText(text: "Populares", fontSize: 22, color: Colors.black),
                                ),
                                const SizedBox(height: 15),
                                SizedBox(
                                  height: 260,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: popularRestaurants.length,
                                    padding: const EdgeInsets.only(left: 15),
                                    clipBehavior: Clip.none,
                                    itemBuilder: (context, index) {
                                      final rest = popularRestaurants[index];
                                      return GestureDetector(
                                        onTap: () => _goToDetail(context, rest),
                                        child: RestaurantCardVertical(
                                          restaurantId: rest.id,
                                          title: rest.name,
                                          subtitle: rest.address,
                                          imageUrl: rest.imageUrl,
                                          rating: rest.rating,
                                          ratingsCount: rest.ratingCount,
                                          discountTag: null,
                                          restaurantData: {
                                            'name': rest.name,
                                            'imageUrl': rest.imageUrl,
                                            'foodType': rest.foodType,
                                            'rating': rest.rating,
                                            'ratingCount': rest.ratingCount,
                                            'deliveryTime': rest.deliveryTime,
                                            'deliveryFee': rest.deliveryFee,
                                            'address': rest.address,
                                            'tags': rest.tags,
                                            'latitude': rest.latitude,
                                            'longitude': rest.longitude,
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 30),
                              ],
                            ),
                          ),

                        // --- SECCIÓN 2: TODOS LOS RESULTADOS ---
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                            child: HeaderText(
                              text: _searchQuery.isEmpty ? "Todos los Restaurantes" : "Resultados de búsqueda", 
                              fontSize: 22, 
                              color: Colors.black
                            ),
                          ),
                        ),
                        
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final rest = filteredRestaurants[index];
                                return GestureDetector(
                                  onTap: () => _goToDetail(context, rest),
                                  child: RestaurantCardHorizontal(
                                    restaurantId: rest.id,
                                    title: rest.name,
                                    subtitle: "${rest.foodType} • ${rest.deliveryTime}",
                                    imageUrl: rest.imageUrl,
                                    rating: rest.rating,
                                    ratingsCount: rest.ratingCount,
                                    discountTag: null,
                                    restaurantData: {
                                      'name': rest.name,
                                      'imageUrl': rest.imageUrl,
                                      'foodType': rest.foodType,
                                      'rating': rest.rating,
                                      'ratingCount': rest.ratingCount,
                                      'deliveryTime': rest.deliveryTime,
                                      'deliveryFee': rest.deliveryFee,
                                      'address': rest.address,
                                      'tags': rest.tags,
                                      'latitude': rest.latitude,
                                      'longitude': rest.longitude,
                                    },
                                  ),
                                );
                              },
                              childCount: filteredRestaurants.length,
                            ),
                          ),
                        ),

                        const SliverToBoxAdapter(child: SizedBox(height: 80)),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navegar a la pantalla de carrito/pago
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ir al carrito - Funcionalidad pendiente'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        backgroundColor: Theme.of(context).primaryColor,
        icon: const Icon(Icons.shopping_cart, color: Colors.white,),
        label: const Text(
          'Ir a carrito',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // --- NAVEGACIÓN ---
  void _goToDetail(BuildContext context, RestaurantModel restaurant) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RestaurantDetailScreen(restaurant: restaurant),
      ),
    );
  }

  // --- BARRA SUPERIOR (UI) ---
  Widget _topBar(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5)]
            ),
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.grey),
                const SizedBox(width: 10),
                // CAMPO DE TEXTO INTERACTIVO
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value; // <--- AQUÍ ACTUALIZAMOS LA BÚSQUEDA
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: "Buscar restaurante...",
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(bottom: 5)
                    ),
                  ),
                ),
                // Botón X para borrar búsqueda
                if (_searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() => _searchQuery = "");
                    },
                    child: const Icon(Icons.close, color: Colors.grey, size: 20),
                  )
              ],
            ),
          ),
        ),
        const SizedBox(width: 15),
        
        // BOTÓN DE FILTROS
        GestureDetector(
          onTap: () => _showFilterModal(context), // <--- ABRIR MODAL
          child: Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              // Cambia de color si hay un filtro activo
              color: (_selectedCategory != null && _selectedCategory != "Todas") 
                  ? Colors.black87 
                  : Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.tune, color: Colors.white),
          ),
        ),
      ],
    );
  }

  // --- MODAL DE FILTROS ---
  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Filtrar por Categoría", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _categories.map((category) {
                  final isSelected = _selectedCategory == category || (_selectedCategory == null && category == "Todas");
                  return FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                    checkmarkColor: Theme.of(context).primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? Theme.of(context).primaryColor : Colors.black,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                    ),
                    onSelected: (bool selected) {
                      setState(() {
                        if (category == "Todas") {
                          _selectedCategory = null;
                        } else {
                          _selectedCategory = category;
                        }
                      });
                      Navigator.pop(context); // Cierra el modal
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}