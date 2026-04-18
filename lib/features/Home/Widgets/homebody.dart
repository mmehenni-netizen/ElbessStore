import 'package:elbess_store/core/constants/colors.dart';
import 'package:elbess_store/core/utils/pref_helpers%20.dart';
import 'package:elbess_store/core/utils/size_config.dart';
import 'package:elbess_store/features/Add/data/ProductModel.dart';
import 'package:elbess_store/features/Add/data/Product_repo.dart';
import 'package:elbess_store/features/Home/data/home_dashboard_repo.dart';
import 'package:elbess_store/features/Home/Widgets/customstockwarncard.dart';
import 'package:elbess_store/features/Home/Widgets/homeordercard.dart';
import 'package:elbess_store/features/Home/Widgets/weekly_overview_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:gap/gap.dart';

class Homebody extends StatefulWidget {
  final PageController? pageController;
  const Homebody({super.key, this.pageController});

  @override
  State<Homebody> createState() => _HomebodyState();
}

class _HomebodyState extends State<Homebody> {
  String _storeName = 'Store';
  final ProductRepo _productRepo = ProductRepo();
  final HomeDashboardRepository _dashboardRepository = HomeDashboardRepository();
  late final Future<List<ProductModel>> _productsFuture;
  late final Future<WeeklyOverviewSummary> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _loadStoreName();
    _productsFuture = getAllProduct();
    _dashboardFuture = getDashboardOverview();
  }

  Future<void> _loadStoreName() async {
    final savedName = await PrefHelpers.getStoreName();
    if (!mounted) {
      return;
    }

    setState(() {
      _storeName = (savedName == null || savedName.trim().isEmpty)
          ? 'Store'
          : savedName.trim();
    });
  }

  Future<List<ProductModel>> getAllProduct() async {
    final storeId = await PrefHelpers.getStoreId();
    if (storeId == null || storeId.trim().isEmpty) {
      throw Exception('Missing store id. Please login again.');
    }

    return _productRepo.getInventory(storeId.trim());
  }

  Future<WeeklyOverviewSummary> getDashboardOverview() async {
    final storeId = await PrefHelpers.getStoreId();
    if (storeId == null || storeId.trim().isEmpty) {
      throw Exception('Missing store id. Please login again.');
    }

    return _dashboardRepository.getWeeklyOverview(storeId.trim());
  }

  List<ProductModel> _getLowStockProducts(List<ProductModel> products) {
    return products.where((product) => product.totalQuantity <= 5).toList();
  }

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
            FutureBuilder<WeeklyOverviewSummary>(
              future: _dashboardFuture,
              builder: (context, snapshot) {
                final summary = snapshot.data ?? WeeklyOverviewSummary.empty();
                return WeeklyOverviewCard(summary: summary);
              },
            ),
            Gap(ds * 3),

            Row(
              children: [
                Icon(CupertinoIcons.exclamationmark_triangle, color: Colors.red, size: ds * 2,),
                Gap(ds),
                Text("Low Stock Warning", style: TextStyle(fontSize: ds * 2.3, fontFamily: "semi", color: Colors.black),)
              ],
            ),
            Gap(ds * 1.5),
            FutureBuilder<List<ProductModel>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: ds * 1.5),
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: ds * 1.5),
                    child: Text(
                      snapshot.error.toString(),
                      style: TextStyle(
                        fontFamily: 'medium',
                        fontSize: ds * 1.1,
                        color: Colors.red.shade700,
                      ),
                    ),
                  );
                }

                final lowStockProducts = _getLowStockProducts(snapshot.data ?? const []);

                if (lowStockProducts.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: ds * 1.5),
                    child: Text(
                      'No low stock products',
                      style: TextStyle(
                        fontFamily: 'medium',
                        fontSize: ds * 1.1,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  );
                }

                return Column(
                  children: lowStockProducts.map((product) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: ds * 1.5),
                      child: Customstockwarncard(
                        productname: product.name,
                        productcategory: product.category,
                        productsleft: '${product.totalQuantity} left',
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            Gap(ds * 2.5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Last Orders", style: TextStyle(fontSize: ds * 2.3, fontFamily: "semi", color: Colors.black),),
              GestureDetector(
                onTap: () {
                  widget.pageController?.animateToPage(1, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
                },
                child: Text("View all",style: TextStyle(fontSize: ds * 1.2, fontFamily: "regular", color: AppColors.primary),),
              )
            ],
          ),
          Gap(ds * 1.5),
          FutureBuilder<WeeklyOverviewSummary>(
            future: _dashboardFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: ds * 1.5),
                  child: const Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: ds * 1.5),
                  child: Text(
                    snapshot.error.toString(),
                    style: TextStyle(
                      fontFamily: 'medium',
                      fontSize: ds * 1.1,
                      color: Colors.red.shade700,
                    ),
                  ),
                );
              }

              final recentOrders = (snapshot.data ?? WeeklyOverviewSummary.empty()).recentOrders;

              if (recentOrders.isEmpty) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: ds * 1.5),
                  child: Text(
                    'No recent orders',
                    style: TextStyle(
                      fontFamily: 'medium',
                      fontSize: ds * 1.1,
                      color: Colors.grey.shade700,
                    ),
                  ),
                );
              }

              return Column(
                children: recentOrders.take(3).map((order) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: ds * 1.5),
                    child: Homeordercard(
                      img: order.imageAsset,
                      productname: order.title,
                      ordercount: '${order.orderNumber} · ${order.quantityLabel} · ${order.status}',
                      price: order.priceLabel,
                    ),
                  );
                }).toList(),
              );
            },
          ),

              
            ],
          ),
        ),
    );
  }
}

