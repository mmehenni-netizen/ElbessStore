import 'package:elbess_store/features/Inventory/Widgets/inventorybody.dart';
import 'package:flutter/material.dart';

class Inventoryview extends StatelessWidget {
  const Inventoryview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Inventorybody(),
    );
  }
}