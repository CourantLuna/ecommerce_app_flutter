import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/src/models/address_model.dart';
import 'package:ecommerce_app/src/models/firestore_models.dart';
import 'package:ecommerce_app/src/services/address_service.dart';
import 'package:ecommerce_app/src/views/screens/tabs_screens/explore_screen/components/address_selector.dart';
import 'package:ecommerce_app/src/views/screens/tabs_screens/explore_screen/components/filter_bottom_sheet.dart';
import 'package:ecommerce_app/src/views/screens/tabs_screens/explore_screen/components/restaurants_list.dart';
import 'package:ecommerce_app/src/views/screens/tabs_screens/explore_screen/components/search_bar.dart'
    as custom;
import 'package:ecommerce_app/src/views/screens/tabs_screens/explore_screen/restaurant_detail_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final AddressService _addressService = AddressService();

  // VARIABLES DE ESTADO
  String _searchQuery = "";
  String? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  AddressModel? _selectedAddress;
  bool _loadingAddress = true;

  // Filtros adicionales
  RangeValues _priceRange = const RangeValues(0, 1000);
  double _maxDeliveryTime = 60;
  double _minRating = 0;

  // Categorías disponibles
  final List<String> _categories = [
    "Todas",
    "Americana",
    "Italiana",
    "Asiática",
    "Criolla",
    "Mexicana",
    "Pollo",
    "Pizzas",
  ];

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? Theme.of(context).scaffoldBackgroundColor : const Color(0xFFF5F6F9),
      body: GestureDetector(
        onTap: () {
          if (!_searchFocusNode.hasFocus) {
            FocusScope.of(context).unfocus();
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              // BARRA SUPERIOR
              Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SELECTOR DE DIRECCIÓN
                    AddressSelector(
                      selectedAddress: _selectedAddress,
                      loading: _loadingAddress,
                      onAddressSelected: (address) {
                        setState(() {
                          _selectedAddress = address;
                        });
                      },
                    ),
                    const SizedBox(height: 15),

                    // BARRA DE BÚSQUEDA Y FILTROS
                    custom.SearchBar(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      searchQuery: _searchQuery,
                      onSearchChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      onFilterTap: () => _showFilterModal(context),
                      hasActiveFilters: _hasActiveFilters(),
                    ),

                    // Chip de filtro activo
                    if (_selectedCategory != null &&
                        _selectedCategory != "Todas")
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: ActionChip(
                          label: Text("Filtro: $_selectedCategory"),
                          avatar: const Icon(Icons.close, size: 16),
                          onPressed: () {
                            setState(() => _selectedCategory = null);
                          },
                          backgroundColor: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.1),
                        ),
                      ),
                  ],
                ),
              ),

              // LISTA DE RESTAURANTES
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('restaurants').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text("No hay restaurantes disponibles"),
                      );
                    }

                    // Convertir y filtrar restaurantes
                    final allRestaurants = snapshot.data!.docs
                        .map((doc) => RestaurantModel.fromSnapshot(doc))
                        .toList();

                    final filteredRestaurants = _filterRestaurants(allRestaurants);
                    
                    // Tomar solo los primeros 5 para populares
                    final popularRestaurants = filteredRestaurants.take(5).toList();
                    
                    // Los demás restaurantes (excluyendo los primeros 5)
                    final remainingRestaurants = filteredRestaurants.skip(5).toList();

                    return RestaurantsList(
                      filteredRestaurants: remainingRestaurants,
                      popularRestaurants: popularRestaurants,
                      allCategories: _categories.where((c) => c != "Todas").toList(),
                      searchQuery: _searchQuery,
                      onRestaurantTap: _goToDetail,
                      onCategoryTap: _goToCategoryScreen,
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
          Navigator.pushNamed(context, '/cart');
        },
        backgroundColor: Theme.of(context).primaryColor,
        icon: const Icon(Icons.shopping_cart, color: Colors.white),
        label: const Text(
          'Ir a carrito',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  List<RestaurantModel> _filterRestaurants(List<RestaurantModel> restaurants) {
    return restaurants.where((rest) {
      // Filtro por texto
      final matchesSearch = _searchQuery.isEmpty ||
          rest.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          rest.tags.any(
            (tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()),
          );

      // Filtro por categoría
      final matchesCategory = _selectedCategory == null ||
          _selectedCategory == "Todas" ||
          rest.foodType == _selectedCategory;

      // Filtro de precio
      final averagePrice =
          (rest.deliveryFee is num) ? (rest.deliveryFee as num).toDouble() : 0.0;
      final matchesPrice =
          averagePrice >= _priceRange.start && averagePrice <= _priceRange.end;

      // Filtro de tiempo de entrega
      final deliveryTimeMatch = RegExp(r'(\d+)').firstMatch(rest.deliveryTime);
      final deliveryTime = deliveryTimeMatch != null
          ? double.tryParse(deliveryTimeMatch.group(1)!) ?? 999
          : 999;
      final matchesDeliveryTime = deliveryTime <= _maxDeliveryTime;

      // Filtro de calificación
      final rating = (rest.rating is num) ? (rest.rating as num).toDouble() : 0.0;
      final matchesRating = rating >= _minRating;

      return matchesSearch &&
          matchesCategory &&
          matchesPrice &&
          matchesDeliveryTime &&
          matchesRating;
    }).toList();
  }

  // NAVEGACIÓN
  void _goToDetail(BuildContext context, RestaurantModel restaurant) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RestaurantDetailScreen(restaurant: restaurant),
      ),
    );
  }

  void _goToCategoryScreen(BuildContext context, String category) {
    Navigator.pushNamed(
      context,
      '/category_restaurants',
      arguments: {'category': category},
    );
  }

  // MODAL DE FILTROS
  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return FilterBottomSheet(
          selectedCategory: _selectedCategory,
          categories: _categories,
          priceRange: _priceRange,
          maxDeliveryTime: _maxDeliveryTime,
          minRating: _minRating,
          onCategoryChanged: (category) {
            setState(() => _selectedCategory = category);
          },
          onPriceChanged: (range) {
            setState(() => _priceRange = range);
          },
          onDeliveryTimeChanged: (time) {
            setState(() => _maxDeliveryTime = time);
          },
          onRatingChanged: (rating) {
            setState(() => _minRating = rating);
          },
          onClearFilters: _clearAllFilters,
        );
      },
    );
  }

  bool _hasActiveFilters() {
    return (_selectedCategory != null && _selectedCategory != "Todas") ||
        _priceRange.start > 0 ||
        _priceRange.end < 1000 ||
        _maxDeliveryTime < 60 ||
        _minRating > 0;
  }

  void _clearAllFilters() {
    setState(() {
      _selectedCategory = null;
      _priceRange = const RangeValues(0, 1000);
      _maxDeliveryTime = 60;
      _minRating = 0;
    });
  }
}
