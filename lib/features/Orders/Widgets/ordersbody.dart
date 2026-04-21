import 'package:elbess_store/core/utils/pref_helpers%20.dart';
import 'package:elbess_store/features/Orders/data/OrderModel.dart';
import 'package:elbess_store/core/utils/size_config.dart';
import 'package:elbess_store/features/Orders/Widgets/customordertype.dart';
import 'package:elbess_store/features/Orders/Widgets/ordercard.dart';
import 'package:elbess_store/features/Orders/data/orderRepo.dart';
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
  final OrderRepo _orderRepo = OrderRepo();
  final List<Map<String, String>> _orders = [];

  final List<String> _statusOptions = [
    "confirmed",
    "prepared",
    "shipped",
    "delivered",
  ];

  @override
  void initState() {
    super.initState();
    getOrders();
  }

  String _statusLabel(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }

  Color _statusColor(String value) {
    switch (value.toLowerCase()) {
      case 'confirmed':
        return const Color(0xFF7B8794);
      case 'prepared':
        return const Color(0xFFE67E22);
      case 'shipped':
        return const Color(0xFF27AE60);
      case 'delivered':
        return const Color(0xFFE74C3C);
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String value) {
    switch (value.toLowerCase()) {
      case 'confirmed':
        return Icons.verified_outlined;
      case 'prepared':
        return Icons.inventory_2_outlined;
      case 'shipped':
        return Icons.local_shipping_outlined;
      case 'delivered':
        return Icons.task_alt_outlined;
      default:
        return Icons.circle_outlined;
    }
  }

  Future<void> _showStatusSelector(int orderIndex) async {
    final selectedStatus = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final ds = SizeConfig.defaultSize!;
        final currentStatus = _orders[orderIndex]["status"] ?? "";
        return Container(
          margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(ds * 2.4)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(ds * 2, ds, ds * 2, ds * 2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: ds * 3.6,
                      height: ds * 0.45,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(ds),
                      ),
                    ),
                  ),
                  Gap(ds * 1.4),
                  Text(
                    "Update Order Status",
                    style: TextStyle(fontFamily: "semi", fontSize: ds * 1.9),
                  ),
                  Gap(ds * 0.5),
                  Text(
                    "Order #${_orders[orderIndex]["number"]}",
                    style: TextStyle(fontFamily: "regular", fontSize: ds * 1.3, color: Colors.grey.shade600),
                  ),
                  Gap(ds * 1.5),
                  ..._statusOptions.map((status) {
                    final isSelected = status == currentStatus;
                    final color = _statusColor(status);
                    return Padding(
                      padding: EdgeInsets.only(bottom: ds * 0.9),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(ds * 1.4),
                        onTap: () => Navigator.pop(context, status),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: EdgeInsets.symmetric(horizontal: ds * 1.2, vertical: ds * 1.05),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(ds * 1.4),
                            color: isSelected ? color.withOpacity(0.1) : Colors.grey.shade50,
                            border: Border.all(
                              color: isSelected ? color.withOpacity(0.5) : Colors.grey.shade300,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: ds * 2.6,
                                height: ds * 2.6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected ? color.withOpacity(0.18) : Colors.white,
                                ),
                                child: Icon(_statusIcon(status), color: color, size: ds * 1.55),
                              ),
                              Gap(ds),
                              Expanded(
                                child: Text(
                                  _statusLabel(status),
                                  style: TextStyle(
                                    fontFamily: "semi",
                                    fontSize: ds * 1.45,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              if (isSelected) Icon(Icons.check_circle_rounded, color: color, size: ds * 1.7),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (selectedStatus == null || selectedStatus == _orders[orderIndex]["status"]) {
      return;
    }

    setState(() {
      _orders[orderIndex]["status"] = selectedStatus;
    });
  }
  Future<void> getOrders() async {
    final id = await PrefHelpers.getStoreId();
    if (id == null || id.trim().isEmpty) {
      return;
    }

    try {
      final res = await _orderRepo.getOrders(id.trim());
      if (!mounted) {
        return;
      }

      setState(() {
        _orders
          ..clear()
          ..addAll(res.map(_mapOrderToUi));
      });
    } catch (_) {}
  }

  Map<String, String> _mapOrderToUi(OrderModel order) {
    final orderNumber = order.id.length >= 4
        ? order.id.substring(order.id.length - 4).toUpperCase()
        : order.id;
    final deliveryType = order.domicile ? 'home' : 'store';
    final address = order.location.trim();
    final locationText = address.isEmpty ? deliveryType : '$address / $deliveryType';
    final productName = order.type.trim().isNotEmpty
        ? order.type.trim()
      : (order.productName.trim().isNotEmpty)
        ? order.productName.trim()
        : (order.product?.trim().isNotEmpty == true ? order.product!.trim() : 'Order item');
    final customerName = order.name.trim().isNotEmpty ? order.name.trim() : 'Customer';
    final contactText = order.numero.trim().isNotEmpty ? '${order.numero} - $customerName' : customerName;
    final effectivePrice = order.price > 0 ? order.price : order.productPrice * order.quantity;
    final size = order.size.trim().isNotEmpty
        ? order.size.trim()
        : (order.products.isNotEmpty && order.products.first.size.trim().isNotEmpty
            ? order.products.first.size.trim()
            : '-');

    return {
      "number": orderNumber,
      "status": order.status,
      "price": effectivePrice > 0 ? '${effectivePrice.toStringAsFixed(2)} dz' : '0 dz',
      "name": productName,
      "qty": '${order.quantity}x / $size',
      "customer": contactText,
      "colors": order.products.isEmpty ? 'no color' : order.products.first.color,
      "location": locationText,
    };
  }
  @override
  Widget build(BuildContext context) {
        SizeConfig().init(context);

        final ds = SizeConfig.defaultSize!;
    final selectedType = type[selectedIndex];
    final visibleOrders = selectedType == "All"
        ? _orders
        : _orders.where((order) => order["status"] == selectedType).toList();

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

            ...List.generate(visibleOrders.length, (index) {
              final order = visibleOrders[index];
              final orderIndex = _orders.indexOf(order);
              return Padding(
                padding: EdgeInsets.only(bottom: ds * 1.5),
                child: Ordercard(
                  orderNumber: order["number"]!,
                  status: order["status"]!,
                  price: order["price"]!,
                  productName: order["name"]!,
                  qty: order["qty"]!,
                  customer: order["customer"]!,
                  colors: order["colors"]!,
                  location: order["location"]!,
                  onUpdateStatus: () => _showStatusSelector(orderIndex),
                ),
              );
            }),

          ],
        ),
      ),
    );
  }
}