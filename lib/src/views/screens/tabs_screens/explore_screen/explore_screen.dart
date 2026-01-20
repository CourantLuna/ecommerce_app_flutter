import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/src/models/address_model.dart';
import 'package:ecommerce_app/src/models/firestore_models.dart';
import 'package:ecommerce_app/src/services/address_service.dart';
import 'package:ecommerce_app/src/views/components/header_text.dart';
import 'package:ecommerce_app/src/views/components/restaurant_card_horizontal.dart';
import 'package:ecommerce_app/src/views/components/restaurant_card_vertical.dart';
import 'package:ecommerce_app/src/views/screens/settings_screen/manage_addresses_screen.dart';
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

  // 1. VARIABLES DE ESTADO (Para búsqueda y filtros)
  String _searchQuery = "";
  String? _selectedCategory; // Si es null, muestra todo.
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  AddressModel? _selectedAddress;
  bool _loadingAddress = true;

  // Filtros adicionales
  RangeValues _priceRange = const RangeValues(0, 1000);
  double _maxDeliveryTime = 60; // minutos
  double _minRating = 0; // 0 a 5

  // Categorías disponibles (Deben coincidir con tu 'foodType' en Firebase)
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
                    // SELECTOR DE DIRECCIÓN
                    _buildAddressSelector(),
                    const SizedBox(height: 15),

                    _topBar(context),

                    // Si hay filtro activo, mostramos un "chip" para poder quitarlo
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

              // --- LISTA DE RESTAURANTES (DENTRO DEL STREAM) ---
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

                    // 2. OBTENER Y FILTRAR LA DATA
                    // Primero convertimos todo a modelos
                    List<RestaurantModel> allRestaurants = snapshot.data!.docs
                        .map((doc) => RestaurantModel.fromSnapshot(doc))
                        .toList();

                    // LÓGICA DE FILTRADO
                    final filteredRestaurants = allRestaurants.where((rest) {
                      // A. Filtro por Texto (Buscador)
                      final matchesSearch =
                          _searchQuery.isEmpty ||
                          rest.name.toLowerCase().contains(
                            _searchQuery.toLowerCase(),
                          ) ||
                          rest.tags.any(
                            (tag) => tag.toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            ),
                          );

                      // B. Filtro por Categoría (Botón de ajustes)
                      final matchesCategory =
                          _selectedCategory == null ||
                          _selectedCategory == "Todas" ||
                          rest.foodType == _selectedCategory;

                      // Filtro de precio (asumir que hay un campo de precio promedio)
                      final averagePrice = (rest.deliveryFee is num) ? (rest.deliveryFee as num).toDouble() : 0.0;
                      final matchesPrice =
                          averagePrice >= _priceRange.start &&
                          averagePrice <= _priceRange.end;

                      // Filtro de tiempo de entrega
                      final deliveryTimeMatch = RegExp(r'(\d+)').firstMatch(rest.deliveryTime);
                      final deliveryTime = deliveryTimeMatch != null 
                          ? double.tryParse(deliveryTimeMatch.group(1)!) ?? 999
                          : 999;
                      final matchesDeliveryTime =
                          deliveryTime <= _maxDeliveryTime;

                      // Filtro de calificación
                      final rating = (rest.rating is num) ? (rest.rating as num).toDouble() : 0.0;
                      final matchesRating = rating >= _minRating;

                      return matchesSearch &&
                          matchesCategory &&
                          matchesPrice &&
                          matchesDeliveryTime &&
                          matchesRating;
                    }).toList();

                    // 3. Preparar las listas para la UI
                    final popularRestaurants = filteredRestaurants
                        .where((r) => r.rating >= 4.5)
                        .toList();

                    // SI NO HAY RESULTADOS
                    if (filteredRestaurants.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 60,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 10),
                            Text(
                              "No encontramos restaurantes con esa búsqueda.",
                              style: TextStyle(color: Colors.grey),
                            ),
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
                                  child: HeaderText(
                                    text: "Populares",
                                    fontSize: 22,
                                    color: Colors.black,
                                  ),
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 10,
                            ),
                            child: HeaderText(
                              text: _searchQuery.isEmpty
                                  ? "Todos los Restaurantes"
                                  : "Resultados de búsqueda",
                              fontSize: 22,
                              color: Colors.black,
                            ),
                          ),
                        ),

                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final rest = filteredRestaurants[index];
                              return GestureDetector(
                                onTap: () => _goToDetail(context, rest),
                                child: RestaurantCardHorizontal(
                                  restaurantId: rest.id,
                                  title: rest.name,
                                  subtitle:
                                      "${rest.foodType} • ${rest.deliveryTime}",
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
                            }, childCount: filteredRestaurants.length),
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
              boxShadow: [
                BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5),
              ],
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
                        _searchQuery =
                            value; // <--- AQUÍ ACTUALIZAMOS LA BÚSQUEDA
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: "Buscar restaurante...",
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(bottom: 5),
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
                    child: const Icon(
                      Icons.close,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ),
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
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.75,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Filtros",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setModalState(() {
                                _selectedCategory = null;
                                _priceRange = const RangeValues(0, 1000);
                                _maxDeliveryTime = 60;
                                _minRating = 0;
                              });
                              setState(() {
                                _selectedCategory = null;
                                _priceRange = const RangeValues(0, 1000);
                                _maxDeliveryTime = 60;
                                _minRating = 0;
                              });
                            },
                            child: const Text("Limpiar"),
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 15),

                      // CATEGORÍA
                      const Text(
                        "Categoría",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _categories.map((category) {
                          final isSelected =
                              _selectedCategory == category ||
                              (_selectedCategory == null &&
                                  category == "Todas");
                          return FilterChip(
                            label: Text(category),
                            selected: isSelected,
                            selectedColor: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.2),
                            checkmarkColor: Theme.of(context).primaryColor,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : Colors.black,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            onSelected: (bool selected) {
                              setModalState(() {
                                if (category == "Todas") {
                                  _selectedCategory = null;
                                } else {
                                  _selectedCategory = category;
                                }
                              });
                              setState(() {
                                if (category == "Todas") {
                                  _selectedCategory = null;
                                } else {
                                  _selectedCategory = category;
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 25),

                      // RANGO DE PRECIO
                      const Text(
                        "Rango de Precio (Envío)",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "\$${_priceRange.start.round()}",
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          Text(
                            "\$${_priceRange.end.round()}",
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ],
                      ),
                      RangeSlider(
                        values: _priceRange,
                        min: 0,
                        max: 1000,
                        divisions: 20,
                        labels: RangeLabels(
                          "\$${_priceRange.start.round()}",
                          "\$${_priceRange.end.round()}",
                        ),
                        onChanged: (RangeValues values) {
                          setModalState(() {
                            _priceRange = values;
                          });
                          setState(() {
                            _priceRange = values;
                          });
                        },
                      ),

                      const SizedBox(height: 20),

                      // TIEMPO DE ENTREGA
                      const Text(
                        "Tiempo de Entrega Máximo",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("10 min"),
                          Text(
                            "${_maxDeliveryTime.round()} min",
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: _maxDeliveryTime,
                        min: 10,
                        max: 60,
                        divisions: 10,
                        label: "${_maxDeliveryTime.round()} min",
                        onChanged: (double value) {
                          setModalState(() {
                            _maxDeliveryTime = value;
                          });
                          setState(() {
                            _maxDeliveryTime = value;
                          });
                        },
                      ),

                      const SizedBox(height: 20),

                      // CALIFICACIÓN MÍNIMA
                      const Text(
                        "Calificación Mínima",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("0 ⭐"),
                          Text(
                            "${_minRating.toStringAsFixed(1)} ⭐",
                            style: TextStyle(
                              color: Colors.amber[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: _minRating,
                        min: 0,
                        max: 5,
                        divisions: 10,
                        label: "${_minRating.toStringAsFixed(1)} ⭐",
                        activeColor: Colors.amber,
                        onChanged: (double value) {
                          setModalState(() {
                            _minRating = value;
                          });
                          setState(() {
                            _minRating = value;
                          });
                        },
                      ),

                      const SizedBox(height: 30),

                      // BOTÓN APLICAR
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Aplicar Filtros",
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

  // --- SELECTOR DE DIRECCIÓN ---
  Widget _buildAddressSelector() {
    if (_loadingAddress) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.location_on, color: Theme.of(context).primaryColor),
            const SizedBox(width: 12),
            const Text("Cargando ubicación...", style: TextStyle(fontSize: 14)),
          ],
        ),
      );
    }

    return InkWell(
      onTap: () async {
        final selected = await _showAddressPickerModal();
        if (selected != null && mounted) {
          setState(() {
            _selectedAddress = selected;
          });
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_on,
              color: Theme.of(context).primaryColor,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedAddress?.name ?? "Ubicación actual",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (_selectedAddress != null)
                    Text(
                      _selectedAddress!.fullAddress,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Future<AddressModel?> _showAddressPickerModal() async {
    return showModalBottomSheet<AddressModel>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Seleccionar Dirección",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ManageAddressesScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.settings, size: 18),
                        label: const Text("Gestionar"),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Lista de direcciones
                Expanded(
                  child: StreamBuilder<List<AddressModel>>(
                    stream: _addressService.getAddressesStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final addresses = snapshot.data ?? [];

                      return ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        children: [
                          // Opción "Ubicación actual"
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.1),
                              child: Icon(
                                Icons.my_location,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            title: const Text("Ubicación actual"),
                            subtitle: const Text("Usar mi ubicación actual"),
                            trailing: _selectedAddress == null
                                ? Icon(
                                    Icons.check_circle,
                                    color: Theme.of(context).primaryColor,
                                  )
                                : null,
                            selected: _selectedAddress == null,
                            onTap: () {
                              Navigator.pop(context, null);
                            },
                          ),
                          if (addresses.isNotEmpty) const Divider(),

                          // Direcciones guardadas
                          ...addresses.map((address) {
                            final isSelected =
                                _selectedAddress?.id == address.id;
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: address.isDefault
                                    ? Theme.of(
                                        context,
                                      ).primaryColor.withOpacity(0.1)
                                    : Colors.grey[200],
                                child: Icon(
                                  Icons.location_on,
                                  color: address.isDefault
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey[600],
                                ),
                              ),
                              title: Row(
                                children: [
                                  Text(address.name),
                                  if (address.isDefault) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(
                                          context,
                                        ).primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        "Predeterminada",
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              subtitle: Text(
                                address.fullAddress,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: isSelected
                                  ? Icon(
                                      Icons.check_circle,
                                      color: Theme.of(context).primaryColor,
                                    )
                                  : null,
                              selected: isSelected,
                              onTap: () {
                                Navigator.pop(context, address);
                              },
                            );
                          }),
                        ],
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
