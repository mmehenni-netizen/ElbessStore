import 'package:elbess_store/core/utils/size_config.dart';
import 'package:flutter/material.dart';

class AddSection extends StatelessWidget {
  final Widget child;

  const AddSection({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final ds = SizeConfig.defaultSize!;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ds * 1.5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ds * 1.2),
        border: Border.all(color: const Color(0xFFE8E8E8), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
