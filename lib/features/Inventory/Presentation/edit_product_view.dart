import 'dart:io';

import 'package:elbess_store/core/utils/size_config.dart';
import 'package:elbess_store/features/Add/data/ProductModel.dart';
import 'package:elbess_store/features/Add/data/Product_repo.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';

class EditProductView extends StatefulWidget {
  final String productId;

  const EditProductView({super.key, required this.productId});

  @override
  State<EditProductView> createState() => _EditProductViewState();
}

class _EditProductViewState extends State<EditProductView> {
  final ProductRepo _productRepo = ProductRepo();
  final ImagePicker _picker = ImagePicker();
  final List<String> _categories = const [
    'T-SHIRTS',
    'SHIRTS',
    'POLO SHIRTS',
    'TROUSERS',
    'DENIM',
    'SWEATERS | CARDIGANS',
    'HOODIES | SWEATSHIRTS',
    'SHOES | BAGS',
  ];
  final List<String> _genders = const ['men', 'women', 'unisex'];
  final List<String> _sizes = const ['S', 'M', 'L', 'XL', 'XXL', 'XXXL'];

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _totalQuantityController = TextEditingController();

  late final Map<String, TextEditingController> _sizeControllers;
  final Set<String> _selectedSizes = {};

  ProductModel? _product;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;
  String? _selectedCategory;
  String? _selectedGender;
  String? _pickedImagePath;

  @override
  void initState() {
    super.initState();
    _sizeControllers = {
      for (final size in _sizes) size: TextEditingController(),
    };
    _loadProduct();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _totalQuantityController.dispose();
    for (final controller in _sizeControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadProduct() async {
    try {
      final product = await _productRepo.getProductById(widget.productId);
      if (!mounted) return;

      if (product == null) {
        setState(() {
          _isLoading = false;
          _error = 'Product not found';
        });
        return;
      }

      _product = product;
      _nameController.text = product.name;
      _descriptionController.text = product.description;
      _priceController.text = product.price.toStringAsFixed(2);
      _totalQuantityController.text = product.totalQuantity.toString();
      _selectedCategory = _categories.contains(product.category) ? product.category : _categories.first;
      _selectedGender = _genders.contains(product.gender) ? product.gender : _genders.first;

      for (final item in product.sizeQuantities) {
        if (_sizeControllers.containsKey(item.size)) {
          _selectedSizes.add(item.size);
          _sizeControllers[item.size]!.text = item.quantity.toString();
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null || !mounted) return;

    setState(() {
      _pickedImagePath = picked.path;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  List<SizeQuantityModel> _collectSizes() {
    final result = <SizeQuantityModel>[];
    for (final size in _selectedSizes) {
      final qty = int.tryParse(_sizeControllers[size]!.text.trim()) ?? 0;
      if (qty > 0) {
        result.add(SizeQuantityModel(size: size, quantity: qty));
      }
    }
    return result;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final sizeQuantities = _collectSizes();
    if (sizeQuantities.isEmpty) {
      _showMessage('Select at least one size and quantity');
      return;
    }

    final price = double.tryParse(_priceController.text.trim()) ?? 0;
    final totalQuantity = int.tryParse(_totalQuantityController.text.trim()) ?? 0;

    setState(() {
      _isSaving = true;
    });

    try {
      final updated = await _productRepo.updateProduct(
        productId: widget.productId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: price,
        totalQuantity: totalQuantity,
        category: _selectedCategory ?? _categories.first,
        gender: _selectedGender ?? _genders.first,
        sizeQuantities: sizeQuantities,
        imagePath: _pickedImagePath,
      );

      if (!mounted) return;

      if (updated == null) {
        _showMessage('Could not update product');
        return;
      }

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showMessage(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Widget _buildPreview(double radius) {
    if (_pickedImagePath != null && _pickedImagePath!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.file(
          File(_pickedImagePath!),
          width: double.infinity,
          height: 180,
          fit: BoxFit.cover,
        ),
      );
    }

    final currentImage = _product?.fullImageUrl ?? '';
    if (currentImage.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.network(
          currentImage,
          width: double.infinity,
          height: 180,
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: const Icon(Icons.image_outlined, size: 44, color: Colors.grey),
    );
  }

  Widget _buildSizeChip(String size, double ds) {
    final selected = _selectedSizes.contains(size);
    return InkWell(
      onTap: () {
        setState(() {
          if (selected) {
            _selectedSizes.remove(size);
            _sizeControllers[size]!.clear();
          } else {
            _selectedSizes.add(size);
            _sizeControllers[size]!.text = _sizeControllers[size]!.text.isEmpty ? '1' : _sizeControllers[size]!.text;
          }
        });
      },
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: EdgeInsets.symmetric(horizontal: ds * 1.2, vertical: ds * 0.7),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF8B4513) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? const Color(0xFF8B4513) : const Color(0xFFE0E0E0)),
        ),
        child: Text(
          size,
          style: TextStyle(
            fontFamily: 'semi',
            color: selected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final ds = SizeConfig.defaultSize ?? 10;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(_error!)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Edit Product',
          style: TextStyle(fontFamily: 'semi', color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(ds * 1.8),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(ds * 1.4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPreview(ds * 1.2),
                      Gap(ds),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.photo_library_outlined),
                          label: const Text('Change image'),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF8B4513),
                          ),
                        ),
                      ),
                      Gap(ds * 1.2),
                      _sectionText('Name'),
                      _field(controller: _nameController, hint: 'Product name'),
                      Gap(ds),
                      _sectionText('Description'),
                      _field(
                        controller: _descriptionController,
                        hint: 'Short product description',
                        maxLines: 3,
                      ),
                      Gap(ds),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _sectionText('Price'),
                                _field(
                                  controller: _priceController,
                                  hint: '0.00',
                                  keyboardType: TextInputType.number,
                                ),
                              ],
                            ),
                          ),
                          Gap(ds),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _sectionText('Total quantity'),
                                _field(
                                  controller: _totalQuantityController,
                                  hint: '0',
                                  keyboardType: TextInputType.number,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Gap(ds),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedCategory,
                              decoration: _inputDecoration('Category'),
                              items: _categories
                                  .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                                  .toList(),
                              onChanged: (value) => setState(() => _selectedCategory = value),
                            ),
                          ),
                          Gap(ds),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedGender,
                              decoration: _inputDecoration('Gender'),
                              items: _genders
                                  .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                                  .toList(),
                              onChanged: (value) => setState(() => _selectedGender = value),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Gap(ds * 1.6),
                Text(
                  'Sizes',
                  style: TextStyle(fontFamily: 'semi', fontSize: ds * 1.5),
                ),
                Gap(ds * 0.8),
                Wrap(
                  spacing: ds * 0.8,
                  runSpacing: ds * 0.8,
                  children: _sizes.map((size) => _buildSizeChip(size, ds)).toList(),
                ),
                Gap(ds),
                ..._selectedSizes.map((size) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: ds * 0.8),
                    child: TextFormField(
                      controller: _sizeControllers[size],
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration('Quantity for size $size'),
                      validator: (value) {
                        if (!_selectedSizes.contains(size)) return null;
                        final qty = int.tryParse(value?.trim() ?? '');
                        if (qty == null || qty <= 0) {
                          return 'Enter a valid quantity';
                        }
                        return null;
                      },
                    ),
                  );
                }),
                Gap(ds * 1.6),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B4513),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: ds * 1.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      _isSaving ? 'Saving...' : 'Save changes',
                      style: const TextStyle(fontFamily: 'semi'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontFamily: 'semi', color: Colors.black87),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE5E5E5))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF8B4513))),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: _inputDecoration(hint),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Required';
        }
        return null;
      },
    );
  }
}
