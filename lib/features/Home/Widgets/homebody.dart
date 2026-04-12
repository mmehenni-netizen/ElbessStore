import 'package:elbess_store/core/constants/colors.dart';
import 'package:elbess_store/core/utils/size_config.dart';
import 'package:elbess_store/features/Home/Widgets/customcard.dart';
import 'package:elbess_store/features/Home/Widgets/customstockwarncard.dart';
import 'package:elbess_store/features/Home/Widgets/homeordercard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:gap/gap.dart';

class Homebody extends StatelessWidget {
  final PageController? pageController;
  const Homebody({super.key, this.pageController});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final ds = SizeConfig.defaultSize!;

    return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.only(left: ds * 2, right: ds * 2, bottom: ds * 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: ds * 5),
          
            Text("Welcome,",style: TextStyle( fontSize: ds * 1.8, fontFamily: "semi",color: Colors.black),),
            Text("Stepx",style: TextStyle( fontSize: ds * 3, fontFamily: "bold",color:AppColors.primary ),),
            Gap(ds * 2.5),
            Row(
              children: [
                Customcard(txt: "Total orders", icn: CupertinoIcons.cube_box, nmbr: "128", clr: Color(0xffC3DBFF)),
                Gap(ds * 2),
                Customcard(txt: "Revenus", icn: CupertinoIcons.graph_square, nmbr: "12040 dz", clr: Color(0xffD8FFDA))
                
              ],
            ), Gap(ds * 2),
            Row(
              children: [
                Customcard(txt: "Low Stock", icn: CupertinoIcons.exclamationmark_triangle, nmbr: "12", clr: Color(0xffFFC192)),
                Gap(ds * 2),
                Customcard(txt: "Delivered", icn: CupertinoIcons.time, nmbr: "84", clr: Color(0xffF9B6FF))
                
              ],
            ),
            Gap(ds * 5),
            Row(
              children: [
                Icon(CupertinoIcons.exclamationmark_triangle, color: Colors.red, size: ds * 2,),
                Gap(ds),
                Text("Low Stock Warning", style: TextStyle(fontSize: ds * 2.3, fontFamily: "semi", color: Colors.black),)
              ],
            ),
            Gap(ds * 1.5),
            ...List.generate(2, (index) {
              final items = [
                {"name": "Classic White Tee", "category": "T-shirt", "left": "3 left"},
                {"name": "Black Hoodie", "category": "Hoodie", "left": "5 left"},
              ];
              return Padding(
                padding: EdgeInsets.only(bottom: ds * 1.5),
                child: Customstockwarncard(
                  productname: items[index]["name"]!,
                  productcategory: items[index]["category"]!,
                  productsleft: items[index]["left"]!,
                ),
              );
            }),
            Gap(ds * 2.5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Last Orders", style: TextStyle(fontSize: ds * 2.3, fontFamily: "semi", color: Colors.black),),
              GestureDetector(
                onTap: () {
                  pageController?.animateToPage(1, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
                },
                child: Text("View all",style: TextStyle(fontSize: ds * 1.2, fontFamily: "regular", color: AppColors.primary),),
              )
            ],
          ),
          Gap(ds * 1.5),
          ...List.generate(3, (index) {
            final orders = [
              {"img": "assets/Images/clothes/item1.png", "name": "Classic White Tee", "count": "#100", "price": "2400 dz"},
              {"img": "assets/Images/clothes/item2.png", "name": "Black Hoodie", "count": "#191", "price": "5000 dz"},
              {"img": "assets/Images/clothes/item3.png", "name": "Blue Jeans", "count": "#232", "price": "3600 dz"},
            ];
            return Padding(
              padding: EdgeInsets.only(bottom: ds * 1.5),
              child: Homeordercard(
                img: orders[index]["img"]!,
                productname: orders[index]["name"]!,
                ordercount: orders[index]["count"]!,
                price: orders[index]["price"]!,
              ),
            );
          }),

              
            ],
          ),
        ),
    );
  }
}

