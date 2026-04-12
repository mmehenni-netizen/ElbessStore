import 'package:elbess_store/core/constants/button.dart';
import 'package:elbess_store/core/constants/colors.dart';
import 'package:elbess_store/core/utils/size_config.dart';
import 'package:elbess_store/features/Add/Widgets/add_section.dart';
import 'package:elbess_store/features/Add/Widgets/add_text_field.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class Addbody extends StatefulWidget {
  const Addbody({super.key});

  @override
  State<Addbody> createState() => _AddbodyState();
}

class _AddbodyState extends State<Addbody> {
  String selectedCategory = 't-shirts';
  final List<String> categories = ['t-shirts', 'hoodies', 'pants', 'cargos', 'jackets'];
  final List<String> sizeLabels = ['S', 'M', 'L', 'Xl'];
  final Set<String> selectedSizes = {};

  @override
  Widget build(BuildContext context) {
    final ds = SizeConfig.defaultSize!;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: ds * 2, vertical: ds * 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Gap(ds * 2),
              Text(
                "Post Product",
                style: TextStyle(fontFamily: 'semi', fontSize: ds * 2.5),
              ),
              Gap(ds * 2),

              // Product Images Section
              AddSection(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("product images", style: TextStyle(fontFamily: 'semi', fontSize: ds * 1.4)),
                    Gap(ds * 1.5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Add image button
                        Container(
                          width: ds * 7,
                          height: ds * 7,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F0ED),
                            borderRadius: BorderRadius.circular(ds * 1.2),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: ds * 3.2,
                                height: ds * 3.2,
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.primary, width: 1.5),
                                  borderRadius: BorderRadius.circular(ds * 0.8),
                                ),
                                child: Icon(Icons.add, color: AppColors.primary, size: ds * 2),
                              ),
                              Gap(ds * 0.4),
                              Text("add image", style: TextStyle(fontSize: ds * 0.9, fontFamily: 'medium', color: AppColors.primary)),
                            ],
                          ),
                        ),
                        Gap(ds * 1.5),
                        // Upload button
                        Container(
                          width: ds * 7,
                          height: ds * 7,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(ds * 1.2),
                          ),
                          child: Icon(Icons.upload_outlined, color: Colors.grey.shade600, size: ds * 3),
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
                      child: AddTextField(hint: "eg,Black oversize hoddie"),
                    ),
                    Gap(ds * 1.5),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("price", style: TextStyle(fontFamily: 'semi', fontSize: ds * 1.4)),
                              Gap(ds * 0.8),
                              AddTextField(hint: "eg,430.00"),
                            ],
                          ),
                        ),
                        Gap(ds * 2),
                        Expanded(
                          flex: 3,
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
                  text: "Save&post product",
                  onPressed: () {},
                ),
              ),
              Gap(ds * 3),
            ],
          ),
        ),
      ),
    ),
    );
  }

}