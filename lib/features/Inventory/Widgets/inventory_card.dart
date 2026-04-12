import 'package:elbess_store/core/utils/size_config.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class InventoryCard extends StatelessWidget {
  final String productName;
  final String price;
  final String imagePath;
  final int total;
  final List<SizeInfo> sizes;

  const InventoryCard({
    super.key,
    required this.productName,
    required this.price,
    required this.imagePath,
    required this.total,
    required this.sizes,
  });

  @override
  Widget build(BuildContext context) {
    final ds = SizeConfig.defaultSize!;
    return Container(
      padding: EdgeInsets.all(ds * 1.2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ds * 1.5),
        border: Border.all(color: const Color(0xFFE8E8E8), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(ds),
            child: Container(
              color: Colors.grey[200],
              child: Image.asset(
                imagePath,
                width: ds * 9,
                height: ds * 9,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Gap(ds * 1.2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        productName,
                        style: TextStyle(
                          fontFamily: 'semi',
                          fontSize: ds * 1.5,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      price,
                      style: TextStyle(
                        fontFamily: 'medium',
                        fontSize: ds * 1.3,
                        color: const Color(0xFF8A5A44),
                      ),
                    ),
                  ],
                ),
                Gap(ds * 1.2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'sizes',
                      style: TextStyle(
                        fontFamily: 'medium',
                        fontSize: ds * 1.4,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'total : $total',
                      style: TextStyle(
                        fontFamily: 'medium',
                        fontSize: ds * 1.3,
                        color: const Color(0xFFE07A1B),
                      ),
                    ),
                  ],
                ),
                Gap(ds),
                Row(
                  children: sizes.map((s) {
                    return Padding(
                      padding: EdgeInsets.only(right: ds * 0.6),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: ds * 1.2,
                          vertical: ds * 0.5,
                        ),
                        decoration: BoxDecoration(
                          color: s.quantity == 0
                              ? const Color(0xFFFFDDD2)
                              : const Color(0xFFFFF0E6),
                          borderRadius: BorderRadius.circular(ds * 2),
                        ),
                        child: Text(
                          '${s.label}:${s.quantity}',
                          style: TextStyle(
                            fontFamily: 'semi',
                            fontSize: ds * 1.1,
                            color: s.quantity == 0
                                ? const Color(0xFFD94A2E)
                                : const Color(0xFFD48A3C),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SizeInfo {
  final String label;
  final int quantity;

  const SizeInfo({required this.label, required this.quantity});
}
