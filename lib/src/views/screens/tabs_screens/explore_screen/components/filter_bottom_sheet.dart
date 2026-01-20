import 'package:flutter/material.dart';

class FilterBottomSheet extends StatefulWidget {
  final String? selectedCategory;
  final List<String> categories;
  final RangeValues priceRange;
  final double maxDeliveryTime;
  final double minRating;
  final Function(String?) onCategoryChanged;
  final Function(RangeValues) onPriceChanged;
  final Function(double) onDeliveryTimeChanged;
  final Function(double) onRatingChanged;
  final VoidCallback onClearFilters;

  const FilterBottomSheet({
    super.key,
    required this.selectedCategory,
    required this.categories,
    required this.priceRange,
    required this.maxDeliveryTime,
    required this.minRating,
    required this.onCategoryChanged,
    required this.onPriceChanged,
    required this.onDeliveryTimeChanged,
    required this.onRatingChanged,
    required this.onClearFilters,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String? _selectedCategory;
  late RangeValues _priceRange;
  late double _maxDeliveryTime;
  late double _minRating;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory;
    _priceRange = widget.priceRange;
    _maxDeliveryTime = widget.maxDeliveryTime;
    _minRating = widget.minRating;
  }

  @override
  Widget build(BuildContext context) {
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
                      setState(() {
                        _selectedCategory = null;
                        _priceRange = const RangeValues(0, 1000);
                        _maxDeliveryTime = 60;
                        _minRating = 0;
                      });
                      widget.onClearFilters();
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
                children: widget.categories.map((category) {
                  final isSelected = _selectedCategory == category ||
                      (_selectedCategory == null && category == "Todas");
                  return FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    selectedColor:
                        Theme.of(context).primaryColor.withOpacity(0.2),
                    checkmarkColor: Theme.of(context).primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.black,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (bool selected) {
                      setState(() {
                        if (category == "Todas") {
                          _selectedCategory = null;
                        } else {
                          _selectedCategory = category;
                        }
                      });
                      widget.onCategoryChanged(_selectedCategory);
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
                  setState(() {
                    _priceRange = values;
                  });
                  widget.onPriceChanged(values);
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
                  setState(() {
                    _maxDeliveryTime = value;
                  });
                  widget.onDeliveryTimeChanged(value);
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
                  setState(() {
                    _minRating = value;
                  });
                  widget.onRatingChanged(value);
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
  }
}
