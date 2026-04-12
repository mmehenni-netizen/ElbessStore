import 'package:elbess_store/core/constants/colors.dart';
import 'package:elbess_store/core/utils/size_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class Homeordercard extends StatelessWidget {
  const Homeordercard({super.key, required this.img, required this.productname, required this.ordercount, required this.price});
  final String img;
  final String productname;
  final String ordercount;
  final String price;
  @override
  Widget build(BuildContext context) {
    final ds = SizeConfig.defaultSize!;
    return Container(
                  padding: EdgeInsets.symmetric(horizontal: ds * 1.8),
                  child: Row(
                   
                    children: [
                      Container(
                        child: Image.asset(img),
                        height: ds * 8,
                        width: ds * 8.3,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(ds),
                        ),
                      ),Gap(ds),
                      Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Gap(ds * 1.2),
                          Text(productname, style: TextStyle(fontSize: ds * 1.5, fontFamily: "semi", color: Colors.black),)
                         ,Gap(ds * 0.7),
                         Row(
                          children: [Text(ordercount, style: TextStyle(fontSize: ds * 1.3, fontFamily: "semi", color: Colors.grey.shade500),)],
                         ),Gap(ds),
                                                   Text(price, style: TextStyle(fontSize: ds * 1.4, fontFamily: "semi", color: AppColors.primary),)

                      ])),
                      Icon(CupertinoIcons.chevron_right, size: ds * 3, color: Colors.grey.shade400),
                      
                      
                      
                    ],
                  ),
                  height: ds * 10,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(ds * 1.5),
                    border: Border.all(color: Colors.black, width: 0.5),
                    color: Colors.white,
                    
                  ),
              );
  }
}