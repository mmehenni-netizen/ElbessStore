import 'package:elbess_store/core/utils/size_config.dart';
import 'package:flutter/material.dart';

class Customordertype extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const Customordertype({super.key, required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final ds = SizeConfig.defaultSize!;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: ds * 2.2, vertical: ds * 1),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF8A5A44) : Colors.white,
          borderRadius: BorderRadius.circular(ds * 3),
          border: Border.all(
            color: isSelected ? Color(0xFF8A5A44) : Colors.grey.shade400,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: ds * 1.5,
              fontFamily: "semi",
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}