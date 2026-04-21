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
      padding: EdgeInsets.symmetric(horizontal: ds * 1.8, vertical: ds * 1.2),
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
                  style: TextStyle(fontSize: ds * 1.5, fontFamily: "semi", color: Colors.black),
                ),
                Gap(ds * 0.75),
                Wrap(
                  spacing: ds * 0.6,
                  runSpacing: ds * 0.4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      ordercount,
                      style: TextStyle(fontSize: ds * 1.3, fontFamily: "semi", color: Colors.grey.shade500),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: ds * 0.7, vertical: ds * 0.18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDDEAFF),
                        borderRadius: BorderRadius.circular(ds),
                      ),
                      child: Text(
                        badgeLabel,
                        style: TextStyle(
                          fontSize: ds * 1.0,
                          fontFamily: "semi",
                          color: const Color(0xFF3B82F6),
                        ),
                      ),
                    ),
                  ],
                ),
                Gap(ds * 0.8),
                Text(price, style: TextStyle(fontSize: ds * 1.4, fontFamily: "semi", color: AppColors.primary)),
              ],
            ),
          ),
          Gap(ds),
          Icon(CupertinoIcons.chevron_right, size: ds * 2.4, color: Colors.grey.shade400),
        ],
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ds * 1.5),
        border: Border.all(color: Colors.black, width: 0.5),
        color: Colors.white,
      ),
    );
  }
}