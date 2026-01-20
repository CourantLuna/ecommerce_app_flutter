import 'package:ecommerce_app/src/models/address_model.dart';
import 'package:ecommerce_app/src/services/address_service.dart';
import 'package:ecommerce_app/src/views/screens/settings_screen/manage_addresses_screen.dart';
import 'package:flutter/material.dart';

class AddressSelector extends StatelessWidget {
  final AddressModel? selectedAddress;
  final bool loading;
  final ValueChanged<AddressModel?> onAddressSelected;

  const AddressSelector({
    super.key,
    required this.selectedAddress,
    required this.loading,
    required this.onAddressSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (loading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.location_on, color: Theme.of(context).primaryColor),
            const SizedBox(width: 12),
            Text(
              "Cargando ubicación...",
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: () => _showAddressPickerModal(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
          ),
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
                    selectedAddress?.name ?? "Ubicación actual",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  if (selectedAddress != null)
                    Text(
                      selectedAddress!.fullAddress,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddressPickerModal(BuildContext context) async {
    final selected = await showModalBottomSheet<AddressModel>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).cardColor
          : Colors.white,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
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
                      Text(
                        "Seleccionar Dirección",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
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
                        icon: Icon(
                          Icons.settings,
                          size: 18,
                          color: Theme.of(context).primaryColor,
                        ),
                        label: Text(
                          "Gestionar",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Lista de direcciones
                Expanded(
                  child: StreamBuilder<List<AddressModel>>(
                    stream: AddressService().getAddressesStream(),
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
                            title: Text(
                              "Ubicación actual",
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            subtitle: Text(
                              "Usar mi ubicación actual",
                              style: TextStyle(
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                            trailing: selectedAddress == null
                                ? Icon(
                                    Icons.check_circle,
                                    color: Theme.of(context).primaryColor,
                                  )
                                : null,
                            selected: selectedAddress == null,
                            onTap: () {
                              Navigator.pop(context, null);
                            },
                          ),
                          if (addresses.isNotEmpty) const Divider(),

                          // Direcciones guardadas
                          ...addresses.map((address) {
                            final isSelected =
                                selectedAddress?.id == address.id;
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: address.isDefault
                                    ? Theme.of(
                                        context,
                                      ).primaryColor.withOpacity(0.1)
                                    : isDark
                                        ? Colors.grey[700]
                                        : Colors.grey[300],
                                child: Icon(
                                  Icons.location_on,
                                  color: address.isDefault
                                      ? Theme.of(context).primaryColor
                                      : isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                ),
                              ),
                              title: Row(
                                children: [
                                  Text(
                                    address.name,
                                    style: TextStyle(
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ),
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
                                style: TextStyle(
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                ),
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

    if (selected != null || selected == null) {
      onAddressSelected(selected);
    }
  }
}
