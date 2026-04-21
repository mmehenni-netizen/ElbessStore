import 'package:elbess_store/core/constants/button.dart';
import 'package:elbess_store/core/constants/colors.dart';
import 'package:elbess_store/core/utils/size_config.dart';
import 'package:elbess_store/features/Add/Widgets/add_section.dart';
import 'package:elbess_store/features/Add/Widgets/add_text_field.dart';
import 'package:elbess_store/features/Add/data/ProductModel.dart';
import 'package:elbess_store/features/Add/data/Product_repo.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';

class Addbody extends StatefulWidget {
  const Addbody({super.key});

  @override
  State<Addbody> createState() => _AddbodyState();
}

class _AddbodyState extends State<Addbody> {
  late String selectedCategory;
  late String selectedGender;
 final List<String> categories = [
  "T-SHIRTS",
  "SHIRTS",
  "POLO SHIRTS",
  "TROUSERS",
  "DENIM",
  "SWEATERS | CARDIGANS",
  "HOODIES | SWEATSHIRTS",
  "SHOES | BAGS",
];
  final List<String> genders = ['men', 'women', 'unisex'];
  final List<String> sizeLabels = ['S', 'M', 'L', 'XL', 'XXL', 'XXXL'];
  final Set<String> selectedSizes = {};
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  late final Map<String, TextEditingController> _sizeControllers;
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];
  final ProductRepo _productRepo = ProductRepo();
  ProductModel? _addedProduct;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    selectedCategory = categories.first;
    selectedGender = genders.first;
    _sizeControllers = {
      for (final size in sizeLabels) size: TextEditingController(),
    };
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    for (final controller in _sizeControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImages = [pickedImage];
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _resetForm() {
    _nameController.clear();
    _descriptionController.clear();
    _priceController.clear();
    for (final controller in _sizeControllers.values) {
      controller.clear();
    }
    setState(() {
      selectedSizes.clear();
      _selectedImages.clear();
      selectedCategory = categories.first;
      selectedGender = genders.first;
    });
  }

  Widget _buildSuccessPanel(double ds) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: double.infinity,
      padding: EdgeInsets.all(ds * 1.6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFE8F7EE),
            const Color(0xFFDDF4E6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ds * 2),
        border: Border.all(color: const Color(0xFFA9E1BE)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB8E6C7).withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: ds * 4.6,
                height: ds * 4.6,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.65),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: Colors.green.shade700,
                  size: ds * 2.6,
                ),
              ),
              Gap(ds),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Product published',
                      style: TextStyle(
                        fontFamily: 'semi',
                        fontSize: ds * 1.55,
                        color: Colors.green.shade900,
                      ),
                    ),
                    Gap(ds * 0.2),
                    Text(
                      'Your product is now saved and ready for the store.',
                      style: TextStyle(
                        fontFamily: 'medium',
                        fontSize: ds * 1.05,
                        color: Colors.green.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Gap(ds * 1.3),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: ds * 1.2, vertical: ds),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.55),
              borderRadius: BorderRadius.circular(ds * 1.2),
            ),
            child: Text(
              'Last added: ${_addedProduct!.name}',
              style: TextStyle(
                fontFamily: 'semi',
                fontSize: ds * 1.25,
                color: const Color(0xFF1F5132),
              ),
            ),
          ),
          Gap(ds * 1.2),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _addedProduct = null;
                    });
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.green.shade900,
                    padding: EdgeInsets.symmetric(vertical: ds * 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ds * 1.1),
                    ),
                    backgroundColor: Colors.white.withOpacity(0.45),
                  ),
                  child: const Text('Continue editing'),
                ),
              ),
              Gap(ds),
              Expanded(
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _addedProduct = null;
                    });
                    _resetForm();
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Add another'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: ds * 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ds * 1.1),
                    ),
                    backgroundColor: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

Future<void> addProduct() async {
  final name = _nameController.text.trim();
  final description = _descriptionController.text.trim();
  final price = double.tryParse(_priceController.text.trim());

  if (name.isEmpty) {
    _showSnackBar('Product name is required');
    return;
  }

  if (description.isEmpty) {
    _showSnackBar('Product description is required');
    return;
  }

  if (price == null || price <= 0) {
    _showSnackBar('Please enter a valid price');
    return;
  }

  final sizeQuantities = <SizeQuantityModel>[];
  for (final size in selectedSizes) {
    final qtyText = _sizeControllers[size]?.text.trim() ?? '';
    final qty = int.tryParse(qtyText);
    if (qty == null || qty <= 0) {
      _showSnackBar('Enter a valid quantity for size $size');
      return;
    }
    sizeQuantities.add(SizeQuantityModel(size: size, quantity: qty));
  }

  if (sizeQuantities.isEmpty) {
    _showSnackBar('Select at least one size with quantity');
    return;
  }

  final totalQuantity = sizeQuantities.fold<int>(0, (sum, item) => sum + item.quantity);

  setState(() {
    _isSaving = true;
  });

  try {
    final added = await _productRepo.addProduct(
      name: name,
      description: description,
      price: price,
      totalQuantity: totalQuantity,
      category: selectedCategory,
      gender: selectedGender,
      sizeQuantities: sizeQuantities,
      imagePath: _selectedImages.isNotEmpty ? _selectedImages.first.path : null,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _addedProduct = added;
    });

    _showSnackBar('Product posted successfully');
    _resetForm();
  } catch (e) {
    if (!mounted) {
      return;
    }
    _showSnackBar(e.toString().replaceFirst('Exception: ', ''));
  } finally {
    if (mounted) {
      setState(() {
        _isSaving = false;
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    final ds = SizeConfig.defaultSize!;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6FA),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFFFFF), Color(0xFFF4F6FA)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: ds * 2, vertical: ds * 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Gap(ds * 1.5),
                  Text(
                    "Post Product",
                    style: TextStyle(fontFamily: 'semi', fontSize: ds * 2.5),
                  ),
                  Gap(ds * 1.2),

                  if (_addedProduct != null) ...[
                    _buildSuccessPanel(ds),
                    Gap(ds * 1.8),
                  ],


                  AddSection(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("product images", style: TextStyle(fontFamily: 'semi', fontSize: ds * 1.4)),
                        if (_selectedImages.isNotEmpty) ...[
                          Gap(ds * 0.6),
                          Text(
                            '${_selectedImages.length} image(s) selected',
                            style: TextStyle(
                              fontFamily: 'medium',
                              fontSize: ds * 1.1,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                        Gap(ds * 1.5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                width: ds * 7.2,
                                height: ds * 7.2,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primary.withOpacity(0.12),
                                      AppColors.primary.withOpacity(0.05),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(ds * 1.4),
                                  border: Border.all(color: AppColors.primary.withOpacity(0.18)),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: ds * 3.4,
                                      height: ds * 3.4,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(ds * 0.9),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primary.withOpacity(0.12),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Icon(Icons.add_rounded, color: AppColors.primary, size: ds * 2.2),
                                    ),
                                    Gap(ds * 0.45),
                                    Text(
                                      "add image",
                                      style: TextStyle(
                                        fontSize: ds * 0.95,
                                        fontFamily: 'semi',
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Gap(ds * 2),

              // Product Name & Price Section
              AddSection(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("product name", style: TextStyle(fontFamily: 'semi', fontSize: ds * 1.4)),
                    Gap(ds),
                    SizedBox(
                      width: double.infinity,
                      child: AddTextField(
                        hint: "eg,Black oversize hoddie",
                        controller: _nameController,
                      ),
                    ),
                    Gap(ds * 1.2),
                    Text("description", style: TextStyle(fontFamily: 'semi', fontSize: ds * 1.4)),
                    Gap(ds * 0.8),
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: ds * 1.2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(ds * 1.2),
                        ),
                        child: TextField(
                          controller: _descriptionController,
                          minLines: 3,
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText: "write product description",
                            hintStyle: TextStyle(fontFamily: 'medium', fontSize: ds * 1.2, color: Colors.grey),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: ds),
                          ),
                          style: TextStyle(fontFamily: 'medium', fontSize: ds * 1.2, color: Colors.black),
                          textInputAction: TextInputAction.newline,
                        ),
                      ),
                    ),
                    Gap(ds * 1.5),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("price", style: TextStyle(fontFamily: 'semi', fontSize: ds * 1.4)),
                              Gap(ds * 0.8),
                              AddTextField(
                                hint: "eg,430.00",
                                controller: _priceController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              ),
                            ],
                          ),
                        ),
                        Gap(ds * 2),
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Category", style: TextStyle(fontFamily: 'semi', fontSize: ds * 1.2)),
                              Gap(ds * 0.8),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: ds * 1.2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(ds * 2),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: selectedCategory,
                                    isExpanded: true,
                                    icon: Icon(Icons.keyboard_arrow_down, size: ds * 2),
                                    style: TextStyle(fontFamily: 'medium', fontSize: ds * 1.3, color: Colors.black),
                                    items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                                    onChanged: (val) {
                                      if (val != null) setState(() => selectedCategory = val);
                                    },
                                  ),
                                ),
                              ),
                              Gap(ds),
                              Text("Gender", style: TextStyle(fontFamily: 'semi', fontSize: ds * 1.2)),
                              Gap(ds * 0.8),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: ds * 1.2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(ds * 2),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: selectedGender,
                                    isExpanded: true,
                                    icon: Icon(Icons.keyboard_arrow_down, size: ds * 2),
                                    style: TextStyle(fontFamily: 'medium', fontSize: ds * 1.3, color: Colors.black),
                                    items: genders.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                                    onChanged: (val) {
                                      if (val != null) setState(() => selectedGender = val);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Gap(ds * 2),

              // Size & Quantities Section
              AddSection(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Size&Quantities", style: TextStyle(fontFamily: 'semi', fontSize: ds * 1.4)),
                    Gap(ds * 1.5),
                    ...sizeLabels.map((size) {
                      final isSelected = selectedSizes.contains(size);
                      return Padding(
                        padding: EdgeInsets.only(bottom: ds),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    selectedSizes.remove(size);
                                  } else {
                                    selectedSizes.add(size);
                                  }
                                });
                              },
                              child: Container(
                                width: ds * 3.8,
                                height: ds * 3.8,
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primary : Colors.white,
                                  borderRadius: BorderRadius.circular(ds * 2),
                                  border: isSelected ? null : Border.all(color: const Color(0xFFD4D4D4), width: 1),
                                ),
                                child: Center(
                                  child: Text(
                                    size,
                                    style: TextStyle(
                                      fontFamily: 'semi',
                                      fontSize: ds * 1.3,
                                      color: isSelected ? Colors.white : Colors.black54,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Gap(ds),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: ds * 1.2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(ds * 2),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _sizeControllers[size],
                                        enabled: isSelected,
                                        decoration: InputDecoration(
                                          hintText: "available stock",
                                          hintStyle: TextStyle(fontFamily: 'medium', fontSize: ds * 1.2, color: Colors.grey),
                                          border: InputBorder.none,
                                          isDense: true,
                                          contentPadding: EdgeInsets.symmetric(vertical: ds * 1.2),
                                        ),
                                        style: TextStyle(fontFamily: 'medium', fontSize: ds * 1.2, color: Colors.black),
                                        keyboardType: TextInputType.number,
                                      ),
                                    ),
                                    Text("pcs", style: TextStyle(fontFamily: 'medium', fontSize: ds * 1.2, color: Colors.grey)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              Gap(ds * 3),

                  // Save Button
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: ds * 3),
                    child: CustomButton(
                      text: _isSaving ? "Posting..." : "Save&post product",
                      onPressed: () {
                        if (_isSaving) {
                          return;
                        }
                        addProduct();
                      },
                    ),
                  ),
                  if (_addedProduct != null) ...[
                    Gap(ds * 1.5),
                    Center(
                      child: Text(
                        'Last added: ${_addedProduct!.name}',
                        style: TextStyle(
                          fontFamily: 'medium',
                          fontSize: ds * 1.2,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                  ],
                  Gap(ds * 3),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}