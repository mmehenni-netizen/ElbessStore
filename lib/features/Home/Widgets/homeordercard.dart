import 'package:elbess_store/core/constants/colors.dart';
import 'package:elbess_store/core/utils/size_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class Homeordercard extends StatelessWidget {
  const Homeordercard({
    super.key,
    required this.productname,
    required this.ordercount,
    required this.badgeLabel,
    required this.price,
  });
  final String productname;
  final String ordercount;
  final String badgeLabel;
  final String price;
  @override
  Widget build(BuildContext context) {
    final ds = SizeConfig.defaultSize!;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: ds * 1.7, vertical: ds * 1.25),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productname,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: ds * 1.5, fontFamily: 'semi', color: const Color(0xFF111827)),
                ),
                Gap(ds * 0.75),
                Wrap(
                  spacing: ds * 0.6,
                  runSpacing: ds * 0.4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      ordercount,
                      style: TextStyle(fontSize: ds * 1.3, fontFamily: 'semi', color: Colors.grey.shade600),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: ds * 0.7, vertical: ds * 0.18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5FF),
                        borderRadius: BorderRadius.circular(ds),
                        border: Border.all(color: const Color(0xFFD7E3FF)),
                      ),
                      child: Text(
                        badgeLabel,
                        style: TextStyle(
                          fontSize: ds * 1.0,
                          fontFamily: 'semi',
                          color: const Color(0xFF4F6DF5),
                        ),
                      ),
                    ),
                  ],
                ),
                Gap(ds * 0.8),
                Text(price, style: TextStyle(fontSize: ds * 1.4, fontFamily: 'semi', color: const Color(0xFF0F172A))),
              ],
            ),
          ),
          Gap(ds),
          Container(
            width: ds * 3,
            height: ds * 3,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(ds * 1.2),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Icon(CupertinoIcons.chevron_right, size: ds * 1.8, color: Colors.grey.shade500),
          ),
        ],
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ds * 1.6),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
    );
  }
}