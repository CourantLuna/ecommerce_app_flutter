import 'package:ecommerce_app/src/views/screens/tabs_screens/favorites_screen/favorites_screen.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_app/src/views/screens/tabs_screens/explore_screen/explore_screen.dart';
import 'package:ecommerce_app/src/views/screens/tabs_screens/my_order_screen/my_order_screen.dart';
import 'package:ecommerce_app/src/views/screens/tabs_screens/profile_screen/profile_screen.dart';

void main() => runApp(TabScreen());

class TabScreen extends StatefulWidget {
  const TabScreen({super.key});

  @override
  State<TabScreen> createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen> {
  int currentPage = 0;
  final List<Widget> pages = [
    ExploreScreen(), // Explore Screen
    MyOrderScreen(), // My Order Screen
    FavoritesScreen(), // Favorite Screen
    ProfileScreen(), // Profile Screen
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        iconSize: 30,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        currentIndex: currentPage,
        onTap: (value) {
          setState(() {
            currentPage = value;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: "EXPLORAR"),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: "PEDIDOS",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "FAVORITOS"),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_pin),
            label: "PERFIL",
          ),
        ],
      ),
      body: pages[currentPage],
    );
  }
}
