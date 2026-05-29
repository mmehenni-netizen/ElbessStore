import 'package:flutter/material.dart';

typedef OnTab = void Function(int index);

class ElbessBottomNav extends StatefulWidget {
  final int currentIndex;
  final OnTab onTab;
  const ElbessBottomNav({Key? key, required this.currentIndex, required this.onTab}) : super(key: key);

  @override
  State<ElbessBottomNav> createState() => _ElbessBottomNavState();
}

class _ElbessBottomNavState extends State<ElbessBottomNav> {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 6,
      elevation: 8,
      child: SizedBox(
        height: 72,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildTab(icon: Icons.home_outlined, index: 0, label: 'Home'),
            _buildTab(icon: Icons.list_alt_outlined, index: 1, label: 'Orders'),
            const SizedBox(width: 48), // space for FAB
            _buildTab(icon: Icons.inventory_2_outlined, index: 3, label: 'Inventory'),
            _buildTab(icon: Icons.person_outline, index: 4, label: 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildTab({required IconData icon, required int index, required String label}) {
    final active = widget.currentIndex == index;
    return GestureDetector(
      onTap: () => widget.onTab(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: active ? const Color(0xFF8B4513) : Colors.grey, size: 24),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(color: active ? const Color(0xFF8B4513) : Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}
