import 'package:elbess_store/core/constants/colors.dart';
import 'package:elbess_store/core/utils/size_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class Ordercard extends StatelessWidget {
  final String orderNumber;
  final String status;
  final String price;
  final String productName;
  final String qty;
  final String customer;
  final String colors;
  final String location;
  final VoidCallback? onUpdateStatus;

  const Ordercard({
    super.key,
    required this.orderNumber,
    required this.status,
    required this.price,
    required this.productName,
    required this.qty,
    required this.customer,
    required this.colors,
    required this.location,
    this.onUpdateStatus,
  });

  Color _statusColor() {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Color(0xFF7B8794);
      case 'prepared':
        return Color(0xFFE67E22);
      case 'shipped':
        return Color(0xFF27AE60);
      case 'delivered':
        return Color(0xFFE74C3C);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ds = SizeConfig.defaultSize!;
    return Material(
      elevation: 3,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(ds * 2),
      child: Container(
        padding: EdgeInsets.all(ds * 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(ds * 2),
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: #number, status badge, price
            Row(
              children: [
                Text(
                  "#$orderNumber",
                  style: TextStyle(fontSize: ds * 1.4, fontFamily: "semi", color: Colors.grey.shade500),
                ),
                Gap(ds),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: ds * 1.2, vertical: ds * 0.3),
                  decoration: BoxDecoration(
                    color: _statusColor().withOpacity(0.15),
                    borderRadius: BorderRadius.circular(ds * 2),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(fontSize: ds * 1.1, fontFamily: "semi", color: _statusColor()),
                  ),
                ),
                Spacer(),
                Text(
                  price,
                  style: TextStyle(fontSize: ds * 1.6, fontFamily: "semi", color: AppColors.primary),
                ),
              ],
            ),
            Gap(ds * 0.8),
            // Product name
            Text(
              productName,
              style: TextStyle(fontSize: ds * 2, fontFamily: "bold", color: Colors.black),
            ),
            Gap(ds * 1.5),
            // Divider
            Divider(color: Colors.grey.shade200, thickness: 1),
            Gap(ds * 1),
            // Details grid
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Qty&Size", style: TextStyle(fontSize: ds * 1.2, fontFamily: "regular", color: Colors.grey.shade500)),
                      Gap(ds * 0.4),
                      Text(qty, style: TextStyle(fontSize: ds * 1.4, fontFamily: "semi", color: Colors.black)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("customer", style: TextStyle(fontSize: ds * 1.2, fontFamily: "regular", color: Colors.grey.shade500)),
                      Gap(ds * 0.4),
                      Text(customer, style: TextStyle(fontSize: ds * 1.4, fontFamily: "semi", color: Colors.black)),
                    ],
                  ),
                ),
              ],
            ),
            Gap(ds * 1.2),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("colors", style: TextStyle(fontSize: ds * 1.2, fontFamily: "regular", color: Colors.grey.shade500)),
                      Gap(ds * 0.4),
                      Text(colors, style: TextStyle(fontSize: ds * 1.4, fontFamily: "semi", color: Colors.black)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("location/type", style: TextStyle(fontSize: ds * 1.2, fontFamily: "regular", color: Colors.grey.shade500)),
                      Gap(ds * 0.4),
                      Text(location, style: TextStyle(fontSize: ds * 1.4, fontFamily: "semi", color: Colors.black)),
                    ],
                  ),
                ),
              ],
            ),
            Gap(ds * 2),
            // Update Status button
            Center(
              child: GestureDetector(
                onTap: onUpdateStatus,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: ds * 3, vertical: ds * 1.2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(ds * 3),
                    border: Border.all(color: Colors.grey.shade400, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Update Status",
                        style: TextStyle(fontSize: ds * 1.5, fontFamily: "semi", color: Colors.black),
                      ),
                      Gap(ds * 0.5),
                      Icon(CupertinoIcons.chevron_right, size: ds * 1.5, color: Colors.black),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
