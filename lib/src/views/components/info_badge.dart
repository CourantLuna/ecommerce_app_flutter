import 'package:flutter/material.dart';

class InfoBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final String subText;

  const InfoBadge({
    super.key,
    required this.icon,
    required this.text,
    required this.subText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor, size: 28),
        const SizedBox(height: 4),
        Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        Text(subText, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}
