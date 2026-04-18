import 'package:elbess_store/core/utils/pref_helpers%20.dart';
import 'package:elbess_store/core/utils/size_config.dart';
import 'package:elbess_store/features/Add/data/ProductModel.dart';
import 'package:elbess_store/features/Add/data/Product_repo.dart';
import 'package:elbess_store/features/Inventory/Widgets/customsearchfield.dart';
import 'package:elbess_store/features/Inventory/Widgets/inventory_card.dart';
import 'package:elbess_store/features/Orders/Widgets/customordertype.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:skeletonizer/skeletonizer.dart';

class Inventorybody extends StatefulWidget {
  const Inventorybody({super.key});

  @override
  State<Inventorybody> createState() => _InventorybodyState();
}

class _InventorybodyState extends State<Inventorybody> {
  int selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late final Future<List<ProductModel>> _inventoryFuture;
  final List<String> type =  [
    "All",
  "T-SHIRTS",
  "SHIRTS",
  "POLO SHIRTS",
  "TROUSERS",
  "DENIM",
  "SWEATERS | CARDIGANS",
  "HOODIES | SWEATSHIRTS",
  "SHOES | BAGS",
];
  final ProductRepo productRepo = ProductRepo();

  @override
  void initState() {
    super.initState();
    _inventoryFuture = _loadInventory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<ProductModel>> _loadInventory() async {
    final storeId = await PrefHelpers.getStoreId();
    if (storeId == null || storeId.trim().isEmpty) {
      throw Exception('Missing store id. Please login again.');
    }

    return productRepo.getInventory(storeId.trim());
  }

  List<ProductModel> _filterProducts(List<ProductModel> products) {
    final selectedType = type[selectedIndex];
    final filteredByType = selectedType == 'All'
        ? products
        : products.where((product) => product.category == selectedType).toList();

    if (_searchQuery.trim().isEmpty) {
      return filteredByType;
    }

    final query = _searchQuery.trim().toLowerCase();
    return filteredByType
        .where((product) => product.name.toLowerCase().contains(query))
        .toList();
  }

  List<SizeInfo> _buildSizes(ProductModel product) {
    return product.sizeQuantities
        .map((item) => SizeInfo(label: item.size, quantity: item.quantity))
        .toList();
  }

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
            Customsearchfield(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            
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

            FutureBuilder<List<ProductModel>>(
              future: _inventoryFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Skeletonizer(
                    enabled: true,
                    child: Column(
                      children: List.generate(4, (index) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: ds * 1.5),
                          child: InventoryCard(
                            productName: 'Loading product',
                            price: '000.00 dz',
                            imagePath: '',
                            total: 0,
                            sizes: const [
                              SizeInfo(label: 'S', quantity: 0),
                              SizeInfo(label: 'M', quantity: 0),
                              SizeInfo(label: 'L', quantity: 0),
                            ],
                          ),
                        );
                      }),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Padding(
                    padding: EdgeInsets.only(top: ds * 4),
                    child: Center(
                      child: Text(
                        snapshot.error.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'medium',
                          fontSize: ds * 1.2,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ),
                  );
                }

                final inventory = _filterProducts(snapshot.data ?? const []);

                if (inventory.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.only(top: ds * 4),
                    child: Center(
                      child: Text(
                        'No products found',
                        style: TextStyle(
                          fontFamily: 'medium',
                          fontSize: ds * 1.3,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  );
                }

                return Column(
                  children: inventory.map((product) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: ds * 1.5),
                      child: InventoryCard(
                        productName: product.name,
                        price: '${product.price.toStringAsFixed(2)} dz',
                        imagePath: product.fullImageUrl,
                        total: product.totalQuantity,
                        sizes: _buildSizes(product),
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