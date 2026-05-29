import 'package:elbess_store/core/utils/size_config.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class Customstockwarncard extends StatelessWidget {
  final String productname;
  final String productcategory;
  final String productsleft;

  const Customstockwarncard({
    super.key,
    required this.productname,
    required this.productcategory,
    required this.productsleft,
  });

  @override
  Widget build(BuildContext context) {
    final ds = SizeConfig.defaultSize!;
    return Container(
      height: ds * 8,
      padding: EdgeInsets.symmetric(horizontal: ds * 1.8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ds * 1.5),
        border: Border.all(color: const Color(0xFFF1D4CC)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.035),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                productname,
                style: TextStyle(fontSize: ds * 1.6, fontFamily: 'semi', color: const Color(0xFF111827)),
              ),
              Gap(ds * 0.5),
              Text(
                productcategory,
                style: TextStyle(fontSize: ds * 1.3, fontFamily: 'semi', color: Colors.grey.shade600),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: ds * 1.4, vertical: ds * 0.7),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1EC),
              borderRadius: BorderRadius.circular(ds * 2.5),
              border: Border.all(color: const Color(0xFFFBC9BC)),
            ),
            child: Text(
              productsleft,
              style: TextStyle(fontSize: ds * 1.25, fontFamily: 'semi', color: const Color(0xFFD94A2E)),
            ),
          ),
        ],
      ),
    );
  }
}