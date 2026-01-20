import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onFilterTap;
  final bool hasActiveFilters;

  const SearchBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onFilterTap,
    required this.hasActiveFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
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
                Expanded(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    onChanged: onSearchChanged,
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black87,
                    ),
                    decoration: const InputDecoration(
                      hintText: "Buscar restaurante...",
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.only(bottom: 5),
                    ),
                  ),
                ),
                if (searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      controller.clear();
                      onSearchChanged('');
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
          onTap: onFilterTap,
          child: Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: hasActiveFilters
                  ? Colors.black87
                  : Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.tune, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
