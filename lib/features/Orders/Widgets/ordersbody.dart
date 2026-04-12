import 'package:elbess_store/core/utils/size_config.dart';
import 'package:elbess_store/features/Orders/Widgets/customordertype.dart';
import 'package:elbess_store/features/Orders/Widgets/ordercard.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class Ordersbody extends StatefulWidget {
  const Ordersbody({super.key});

  @override
  State<Ordersbody> createState() => _OrdersbodyState();
}

class _OrdersbodyState extends State<Ordersbody> {
  int selectedIndex = 0;
  final List<String> type = ["All", "confirmed", "prepared", "shipped", "delivered"];

  @override
  Widget build(BuildContext context) {
        SizeConfig().init(context);

        final ds = SizeConfig.defaultSize!;

    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: Padding(
          padding: EdgeInsets.only(left: ds * 2, right: ds * 2, bottom: ds * 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              SizedBox(height: ds * 5),
            Text("Manage Orders", style: TextStyle(fontFamily: "semi",fontSize: ds * 2.3)),
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
              final orders = [
                {"number": "110", "status": "confirmed", "price": "420.00 dz", "name": "oversized sweet-shirt", "qty": "2x / L", "customer": "Ahmed Ali", "colors": "black-black", "location": "relizene,hmadna / home"},
                {"number": "110", "status": "prepared", "price": "540.00 dz", "name": "denim baggy jeans", "qty": "3x / M", "customer": "Mohamed", "colors": "no color", "location": "relizene,hmadna / home"},
                {"number": "110", "status": "shipped", "price": "540.00 dz", "name": "oversized sweet-shirt", "qty": "2x / L", "customer": "Ahmed Ali", "colors": "black-black", "location": "relizene,hmadna / home"},
                {"number": "110", "status": "delivered", "price": "540.00 dz", "name": "oversized sweet-shirt", "qty": "2x / L", "customer": "Ahmed Ali", "colors": "black-black", "location": "relizene,hmadna / home"},
              ];
              return Padding(
                padding: EdgeInsets.only(bottom: ds * 1.5),
                child: Ordercard(
                  orderNumber: orders[index]["number"]!,
                  status: orders[index]["status"]!,
                  price: orders[index]["price"]!,
                  productName: orders[index]["name"]!,
                  qty: orders[index]["qty"]!,
                  customer: orders[index]["customer"]!,
                  colors: orders[index]["colors"]!,
                  location: orders[index]["location"]!,
                ),
              );
            }),

          ],
        ),
      ),
    );
  }
}