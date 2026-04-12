import 'package:elbess_store/core/utils/size_config.dart';
import 'package:elbess_store/features/Inventory/Widgets/customsearchfield.dart';
import 'package:elbess_store/features/Inventory/Widgets/inventory_card.dart';
import 'package:elbess_store/features/Orders/Widgets/customordertype.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class Inventorybody extends StatefulWidget {
  const Inventorybody({super.key});

  @override
  State<Inventorybody> createState() => _InventorybodyState();
}

class _InventorybodyState extends State<Inventorybody> {
  int selectedIndex = 0;
  final List<String> type = ["All", "pants", "t-shirts", "hoodies", "cargos"];

  @override
  Widget build(BuildContext context) {
        SizeConfig().init(context);

        final ds = SizeConfig.defaultSize!;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: Padding(
          padding: EdgeInsets.only(left: ds * 2, right: ds * 2, bottom: ds * 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              SizedBox(height: ds * 5),
            Text("Manage Inventory", style: TextStyle(fontFamily: "semi",fontSize: ds * 2.3)),
            Gap(ds*3),
            Customsearchfield(),
            
            Gap(ds * 3),
            SingleChildScrollView(
              clipBehavior: Clip.none,
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: ds * 0.5),
                child: Row(
                children: List.generate(type.length, (index) {
                  final isSelected = selectedIndex == index;
                  return Padding(
                    padding: EdgeInsets.only(right: ds),
                    child: Customordertype(
                      label: type[index],
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                    ),
                  );
                }),
              ),
              ),
            ),
            Gap(ds * 2),

            ...List.generate(4, (index) {
              final products = [
                {"name": "oversized sweet-shirt", "price": "420.00 dz", "image": "assets/Images/clothes/item1.png"},
                {"name": "denim baggy jeans", "price": "540.00 dz", "image": "assets/Images/clothes/item2.png"},
                {"name": "oversized sweet-shirt", "price": "420.00 dz", "image": "assets/Images/clothes/item3.png"},
                {"name": "cargo pants", "price": "380.00 dz", "image": "assets/Images/clothes/item4.png"},
              ];
              return Padding(
                padding: EdgeInsets.only(bottom: ds * 1.5),
                child: InventoryCard(
                  productName: products[index]["name"]!,
                  price: products[index]["price"]!,
                  imagePath: products[index]["image"]!,
                  total: 15,
                  sizes: const [
                    SizeInfo(label: "S", quantity: 5),
                    SizeInfo(label: "M", quantity: 0),
                    SizeInfo(label: "L", quantity: 2),
                  ],
                ),
              );
            }),

          ],
        ),
      ),
    ),
    );
  }
}