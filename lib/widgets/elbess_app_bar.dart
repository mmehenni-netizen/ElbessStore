import 'package:flutter/material.dart';

class ElbessAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;

  const ElbessAppBar({Key? key, required this.title, this.subtitle, this.actions}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 4,
      shadowColor: Colors.black12,
      titleSpacing: 16,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Color(0xFF2C1A0E), fontWeight: FontWeight.w800, fontSize: 18)),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, style: const TextStyle(color: Color(0xFF9E7B5A), fontSize: 12)),
          ]
        ],
      ),
      actions: actions,
    );
  }
}
