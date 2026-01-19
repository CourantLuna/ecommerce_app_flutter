import 'package:flutter/material.dart';

void main() => runApp(const FavoriteScreen());

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Favorite Screen'));
  }
}