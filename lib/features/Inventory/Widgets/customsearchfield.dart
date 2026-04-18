import 'package:elbess_store/core/utils/size_config.dart';
import 'package:flutter/material.dart';

class Customsearchfield extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const Customsearchfield({super.key, this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final ds = SizeConfig.defaultSize!;
    return TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: "search a product",
                hintStyle: TextStyle(color: Colors.grey, fontSize: ds * 1.5),
                prefixIcon: Icon(Icons.search, color: Colors.grey, size: ds * 2.2),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: ds * 1.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ds * 2.5),
                  borderSide: BorderSide.none,
                ),
              ),
            );
  }
}