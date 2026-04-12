import 'package:elbess_store/core/utils/size_config.dart';
import 'package:flutter/material.dart';

class AddTextField extends StatelessWidget {
  final String hint;

  const AddTextField({super.key, required this.hint});

  @override
  Widget build(BuildContext context) {
    final ds = SizeConfig.defaultSize!;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: ds * 1.2),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(ds * 2),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontFamily: 'medium', fontSize: ds * 1.2, color: Colors.grey),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: ds * 1),
        ),
        style: TextStyle(fontFamily: 'medium', fontSize: ds * 1.2, color: Colors.black),
      ),
    );
  }
}
