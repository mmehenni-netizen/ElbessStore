import 'package:elbess_store/core/utils/pref_helpers.dart';
import 'package:elbess_store/core/utils/size_config.dart';
import 'package:elbess_store/features/Add/data/ProductModel.dart';
import 'package:elbess_store/features/Add/data/Product_repo.dart';
import 'package:elbess_store/features/Inventory/Presentation/edit_product_view.dart';
import 'package:elbess_store/features/Inventory/Widgets/customsearchfield.dart';
import 'package:elbess_store/features/Inventory/Widgets/inventory_card.dart';
import 'package:elbess_store/features/Orders/Widgets/customordertype.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:elbess_store/models/inventory_filter_model.dart';
import 'package:elbess_store/widgets/elbess_filter_button.dart';
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
  late Future<List<ProductModel>> _inventoryFuture;
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
  InventoryFilterModel _activeFilter = const InventoryFilterModel();

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

  void _reloadInventory() {
    setState(() {
      _inventoryFuture = _loadInventory();
    });
  }

  Future<void> _editProduct(ProductModel product) async {
    if (product.id == null || product.id!.trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This product cannot be edited right now')),
      );
      return;
    }

    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProductView(productId: product.id!),
      ),
    );

    if (updated == true) {
      _reloadInventory();
    }
  }

  Future<void> _deleteProduct(ProductModel product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text('Delete product?'),
          content: Text('This will remove "${product.name}" from your inventory.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || product.id == null) {
      return;
    }

    try {
      final deleted = await productRepo.deleteProduct(product.id!);
      if (!mounted) return;
      if (deleted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${product.name} deleted')),
        );
        _reloadInventory();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not delete product')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  List<ProductModel> _filterProducts(List<ProductModel> products) {
    var list = products;

    // category filter (type chips still control selectedIndex)
    final selectedType = type[selectedIndex];
    if (selectedType != 'All') {
      list = list.where((p) => p.category == selectedType).toList();
    }

    // apply inventory filter model
    // price range
    list = list.where((p) => p.price >= _activeFilter.priceRange.start && p.price <= _activeFilter.priceRange.end).toList();

    // stock status (multi-select)
    if (_activeFilter.stockStatus.isNotEmpty) {
      list = list.where((p) {
        final total = p.totalQuantity;
        bool ok = false;
        for (final s in _activeFilter.stockStatus) {
          if (s == 'In Stock' && total > 0) ok = true;
          if (s == 'Low Stock' && total > 0 && total < 10) ok = true;
          if (s == 'Out of Stock' && total == 0) ok = true;
        }
        return ok;
      }).toList();
    }

    // sizes
    if (_activeFilter.sizes.isNotEmpty) {
      list = list.where((p) {
        final sizes = p.sizeQuantities.map((e) => e.size).toList();
        return _activeFilter.sizes.any((s) => sizes.contains(s));
      }).toList();
    }

    // category selection inside sheet
    if ((_activeFilter.category ?? '').isNotEmpty) {
      list = list.where((p) => p.category == _activeFilter.category).toList();
    }

    // active only
    if (_activeFilter.activeOnly) {
      // product model doesn't have an 'active' flag in the model; skip unless available
    }

    // search query
    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.trim().toLowerCase();
      list = list.where((product) => product.name.toLowerCase().contains(query)).toList();
    }

    // sorting
    switch (_activeFilter.sortBy) {
      case 'Name A → Z':
        list.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'Name Z → A':
        list.sort((a, b) => b.name.compareTo(a.name));
        break;
      case 'Price: Low to High':
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Price: High to Low':
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Stock: Low to High':
        list.sort((a, b) => a.totalQuantity.compareTo(b.totalQuantity));
        break;
      case 'Stock: High to Low':
        list.sort((a, b) => b.totalQuantity.compareTo(a.totalQuantity));
        break;
      case 'Recently Added':
        // no createdAt available; fallback to id ordering
        list = list.reversed.toList();
        break;
      default:
        break;
    }

    return list;
  }

  List<SizeInfo> _buildSizes(ProductModel product) {
    return product.sizeQuantities
        .map((item) => SizeInfo(label: item.size, quantity: item.quantity))
        .toList();
  }

  Widget _buildHeader(double ds) {
    return Padding(
      padding: EdgeInsets.only(left: ds * 2, right: ds * 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: ds * 5),
          Text(
            "Manage Inventory",
            style: TextStyle(fontFamily: "semi", fontSize: ds * 2.3),
          ),
          Gap(ds * 3),
          Row(
            children: [
              Expanded(
                child: Customsearchfield(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              ElbessFilterButton(
                currentFilter: _activeFilter,
                onApply: (f) {
                  setState(() {
                    _activeFilter = f;
                  });
                },
              ),
            ],
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
        ],
      ),
    );
  }

  SliverPadding _buildLoadingState(double ds) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: ds * 2),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          return Padding(
            padding: EdgeInsets.only(bottom: ds * 1.5),
            child: Skeletonizer(
              enabled: true,
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
            ),
          );
        }, childCount: 4),
      ),
    );
  }

  SliverToBoxAdapter _buildMessageState(
    double ds,
    String message, {
    Color? color,
  }) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(ds * 2, ds * 4, ds * 2, 0),
        child: Center(
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'medium',
              fontSize: ds * 1.2,
              color: color ?? Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }

  SliverPadding _buildInventoryList(double ds, List<ProductModel> inventory) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(ds * 2, 0, ds * 2, ds * 12),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final product = inventory[index];
          return Padding(
            padding: EdgeInsets.only(bottom: ds * 1.5),
            child: InventoryCard(
              productName: product.name,
              price: '${product.price.toStringAsFixed(2)} dz',
              imagePath: product.fullImageUrl,
              total: product.totalQuantity,
              sizes: _buildSizes(product),
              onEdit: () => _editProduct(product),
              onDelete: () => _deleteProduct(product),
            ),
          );
        }, childCount: inventory.length),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final ds = SizeConfig.defaultSize!;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: FutureBuilder<List<ProductModel>>(
        future: _inventoryFuture,
        builder: (context, snapshot) {
          final inventory = _filterProducts(snapshot.data ?? const []);

          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(ds)),
              if (snapshot.connectionState == ConnectionState.waiting)
                _buildLoadingState(ds)
              else if (snapshot.hasError)
                _buildMessageState(
                  ds,
                  snapshot.error.toString(),
                  color: Colors.red.shade700,
                )
              else ...[
                if (inventory.isEmpty)
                  _buildMessageState(ds, 'No products found')
                else
                  _buildInventoryList(ds, inventory),
              ],
            ],
          );
        },
      ),
    );
  }
}
