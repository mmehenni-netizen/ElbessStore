import 'package:elbess_store/core/utils/pref_helpers.dart';
import 'package:elbess_store/core/utils/size_config.dart';
import 'package:elbess_store/features/Add/data/ProductModel.dart';
import 'package:elbess_store/features/Add/data/Product_repo.dart';
import 'package:elbess_store/features/Home/data/home_dashboard_repo.dart';
import 'package:elbess_store/features/Home/Widgets/customstockwarncard.dart';
import 'package:elbess_store/features/Home/Widgets/homeordercard.dart';
import 'package:elbess_store/features/Home/Widgets/weekly_overview_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  late Future<List<ProductModel>> _productsFuture;
  late Future<WeeklyOverviewSummary> _dashboardFuture;
  int? _lastObservedPageIndex;

  @override
  void initState() {
    super.initState();
    _loadStoreName();
    _refreshHomeData();
    _lastObservedPageIndex = widget.pageController?.initialPage ?? 0;
    widget.pageController?.addListener(_handlePageChange);
  }

  @override
  void dispose() {
    widget.pageController?.removeListener(_handlePageChange);
    super.dispose();
  }

  void _refreshHomeData() {
    _productsFuture = getAllProduct();
    _dashboardFuture = getDashboardOverview();
  }

  void _handlePageChange() {
    final currentPageIndex = widget.pageController?.page?.round();
    if (currentPageIndex == null) {
      return;
    }

    if (currentPageIndex == 0 && _lastObservedPageIndex != 0 && mounted) {
      setState(_refreshHomeData);
    }

    _lastObservedPageIndex = currentPageIndex;
  }

  Future<void> _loadStoreName() async {
    final savedName = await PrefHelpers.getStoreName();
    if (!mounted) {
      return;
    }

    setState(() {
      _storeName = (savedName == null || savedName.trim().isEmpty) ? 'Store' : savedName.trim();
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

    return ColoredBox(
      color: Colors.white,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.only(left: ds * 2, right: ds * 2, bottom: ds * 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: ds * 5),
              _DashboardHeader(storeName: _storeName, ds: ds),
              Gap(ds * 2.2),
              FutureBuilder<WeeklyOverviewSummary>(
                future: _dashboardFuture,
                builder: (context, snapshot) {
                  final summary = snapshot.data ?? WeeklyOverviewSummary.empty();
                  return WeeklyOverviewCard(summary: summary);
                },
              ),
              Gap(ds * 2.6),
              const _SectionTitle(
                title: 'Low stock',
                subtitle: 'Items that need attention',
                icon: CupertinoIcons.exclamationmark_triangle,
                accentColor: Color(0xFFF97316),
              ),
              Gap(ds * 1.2),
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
                        padding: EdgeInsets.only(bottom: ds * 1.2),
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
                  _SectionTitleText(title: 'Recent orders', ds: ds),
                  GestureDetector(
                    onTap: () {
                      widget.pageController?.animateToPage(
                        1,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Text(
                      'View all',
                      style: TextStyle(
                        fontSize: ds * 1.2,
                        fontFamily: 'semi',
                        color: const Color(0xFF4F6DF5),
                      ),
                    ),
                  ),
                ],
              ),
              Gap(ds * 1.2),
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
                        padding: EdgeInsets.only(bottom: ds * 1.2),
                        child: Homeordercard(
                          productname: order.title,
                          ordercount: order.metaLabel,
                          badgeLabel: order.badgeLabel,
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
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.storeName, required this.ds});

  final String storeName;
  final double ds;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ds * 1.5),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(ds * 1.8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard',
            style: TextStyle(
              fontSize: ds * 1.2,
              fontFamily: 'semi',
              color: const Color(0xFF64748B),
            ),
          ),
          Gap(ds * 0.4),
          Text(
            storeName,
            style: TextStyle(
              fontSize: ds * 2.2,
              fontFamily: 'bold',
              color: const Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final ds = SizeConfig.defaultSize!;
    return Row(
      children: [
        Container(
          width: ds * 3.2,
          height: ds * 3.2,
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(ds * 1.1),
          ),
          child: Icon(icon, color: accentColor, size: ds * 1.8),
        ),
        Gap(ds),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: ds * 2.1,
                  fontFamily: 'semi',
                  color: const Color(0xFF111827),
                ),
              ),
              Gap(ds * 0.2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: ds * 1.15,
                  fontFamily: 'regular',
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionTitleText extends StatelessWidget {
  const _SectionTitleText({required this.title, required this.ds});

  final String title;
  final double ds;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: ds * 2.1,
        fontFamily: 'semi',
        color: const Color(0xFF111827),
      ),
    );
  }
}
