import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({Key? key, required this.status}) : super(key: key);

  Color _color(String v) {
    switch (v.toLowerCase()) {
      case 'confirmed':
        return const Color(0xFF3498DB);
      case 'prepared':
        return const Color(0xFFF39C12);
      case 'shipped':
        return const Color(0xFF9B59B6);
      case 'delivered':
        return const Color(0xFF2ECC71);
      case 'canceled':
        return const Color(0xFFE74C3C);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _color(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c.withOpacity(0.15),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: c),
      ),
    );
  }
}
