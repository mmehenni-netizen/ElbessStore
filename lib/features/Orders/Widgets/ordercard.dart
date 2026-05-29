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
  final String? time;
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
    this.time,
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

  String _statusLabel() {
    if (status.isEmpty) return status;
    return status[0].toUpperCase() + status.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final ds = SizeConfig.defaultSize!;
    final statusColor = _statusColor();
    return Material(
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.08),
      borderRadius: BorderRadius.circular(ds * 2.2),
      child: Container(
        padding: EdgeInsets.all(ds * 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(ds * 2.2),
          border: Border.all(color: Colors.black.withOpacity(0.08), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          "#$orderNumber",
                          style: TextStyle(fontSize: ds * 1.4, fontFamily: "semi", color: Colors.grey.shade500),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      if (time != null && time!.isNotEmpty) ...[
                        Gap(ds * 0.6),
                        Flexible(
                          child: Text(
                            time!,
                            style: TextStyle(fontSize: ds * 1.0, fontFamily: "regular", color: Colors.grey.shade400),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                      Gap(ds),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: ds * 1.2, vertical: ds * 0.45),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(ds * 2),
                          border: Border.all(color: statusColor.withOpacity(0.35), width: 1),
                        ),
                        child: Text(
                          _statusLabel(),
                          style: TextStyle(fontSize: ds * 1.15, fontFamily: "semi", color: statusColor),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  price,
                  style: TextStyle(fontSize: ds * 1.6, fontFamily: "semi", color: AppColors.primary),
                ),
              ],
            ),
            Gap(ds * 0.8),
            Text(
              productName,
              style: TextStyle(fontSize: ds * 2, fontFamily: "bold", color: Colors.black),
            ),
            Gap(ds * 1.5),
            Divider(color: Colors.grey.shade200, thickness: 1),
            Gap(ds * 1),
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
            Center(
              child: InkWell(
                onTap: onUpdateStatus,
                borderRadius: BorderRadius.circular(ds * 3),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: ds * 2.4, vertical: ds * 1.1),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(ds * 3),
                    gradient: LinearGradient(
                      colors: [statusColor.withOpacity(0.13), statusColor.withOpacity(0.06)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    border: Border.all(color: statusColor.withOpacity(0.5), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: ds * 2.1,
                        height: ds * 2.1,
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.18),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(CupertinoIcons.refresh, size: ds * 1.3, color: statusColor),
                      ),
                      Gap(ds * 0.7),
                      Text(
                        "Update Status",
                        style: TextStyle(fontSize: ds * 1.45, fontFamily: "semi", color: Colors.black87),
                      ),
                      Gap(ds * 0.6),
                      Icon(CupertinoIcons.chevron_right, size: ds * 1.3, color: Colors.black54),
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
