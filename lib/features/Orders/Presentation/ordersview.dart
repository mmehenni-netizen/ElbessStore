import 'package:elbess_store/features/Orders/Widgets/ordersbody.dart';
import 'package:flutter/material.dart';

class Ordersview extends StatelessWidget {
  const Ordersview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Ordersbody(),
    );
  }
}