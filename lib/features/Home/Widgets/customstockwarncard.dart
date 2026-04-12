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
    return  Material(
              elevation: 4,
              shadowColor: Colors.grey.shade300,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ds * 1.5)),
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: ds * 1.8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(productname, style: TextStyle(fontSize: ds * 1.6, fontFamily: "semi", color: Colors.black),),
                          Gap(ds * 0.5),
                      Text(productcategory, style: TextStyle(fontSize: ds * 1.4, fontFamily: "semi", color: Colors.grey.shade500),),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: ds * 1.4, vertical: ds * 0.7),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(ds * 2.5),
                        ),
                        child: Text(productsleft, style: TextStyle(fontSize: ds * 1.4, fontFamily: "semi", color: Colors.red),),
                      ),
                      
                      
                    ],
                  ),
                  height: ds * 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(ds * 1.5),
                    color: Colors.white,
                    
                  ),
              ),
            );
  }
}