import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/inventory_filter_model.dart';

class ElbessInventoryFilterSheet extends StatefulWidget {
  final InventoryFilterModel currentFilter;
  final void Function(InventoryFilterModel) onApply;

  const ElbessInventoryFilterSheet({Key? key, required this.currentFilter, required this.onApply}) : super(key: key);

  @override
  State<ElbessInventoryFilterSheet> createState() => _ElbessInventoryFilterSheetState();
}

class _ElbessInventoryFilterSheetState extends State<ElbessInventoryFilterSheet> with TickerProviderStateMixin {
  late InventoryFilterModel _filter;
  bool _loading = false;
  // animation flags
  final List<bool> _visible = List<bool>.filled(6, false);

  final List<String> _sizeOptions = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];
  final List<String> _categoryOptions = ['All', 'T-Shirts', 'Shirts', 'Polo', 'Pants', 'Jackets', 'Shoes'];
  final List<String> _sortOptions = [
    'Name A → Z',
    'Name Z → A',
    'Price: Low to High',
    'Price: High to Low',
    'Stock: Low to High',
    'Stock: High to Low',
    'Recently Added',
  ];

  @override
  void initState() {
    super.initState();
    _filter = widget.currentFilter.copyWith();
    // stagger in animations
    for (int i = 0; i < _visible.length; i++) {
      Future.delayed(Duration(milliseconds: 50 * i), () {
        if (mounted) setState(() => _visible[i] = true);
      });
    }
  }

  void _resetLocal() {
    setState(() {
      _filter = const InventoryFilterModel();
    });
  }

  void _toggleStock(String key) {
    final list = List<String>.from(_filter.stockStatus);
    if (list.contains(key)) list.remove(key); else list.add(key);
    setState(() {
      _filter = _filter.copyWith(stockStatus: list);
    });
  }

  void _toggleSize(String key) {
    final list = List<String>.from(_filter.sizes);
    if (list.contains(key)) list.remove(key); else list.add(key);
    setState(() {
      _filter = _filter.copyWith(sizes: list);
    });
  }

  Widget _sectionHeader(String text, int idx) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: _visible[idx] ? 1 : 0,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        offset: _visible[idx] ? Offset.zero : const Offset(0, 0.08),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF2C1A0E))),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 60, height: 6, decoration: BoxDecoration(color: Color(0xFFEDE8E5), borderRadius: BorderRadius.circular(6))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Filter Products', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF2C1A0E))),
                    TextButton(
                      onPressed: _resetLocal,
                      child: const Text('Reset All', style: TextStyle(color: Color(0xFF8B4513), fontWeight: FontWeight.w600)),
                    )
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFD9C4B0)),
              Expanded(
                child: SingleChildScrollView(
                  controller: controller,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Price Range
                      _sectionHeader('Price Range', 0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${_filter.priceRange.start.toInt()} DA', style: const TextStyle(color: Color(0xFF9E7B5A))),
                          Text('${_filter.priceRange.end.toInt()} DA', style: const TextStyle(color: Color(0xFF9E7B5A))),
                        ],
                      ),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: const Color(0xFF8B4513),
                          inactiveTrackColor: const Color(0xFFD9C4B0),
                          trackHeight: 4,
                          thumbColor: const Color(0xFF8B4513),
                          overlayColor: const Color(0x338B4513),
                        ),
                        child: RangeSlider(
                          values: _filter.priceRange,
                          min: 0,
                          max: 50000,
                          divisions: 500,
                          labels: RangeLabels('${_filter.priceRange.start.toInt()} DA', '${_filter.priceRange.end.toInt()} DA'),
                          onChanged: (r) => setState(() => _filter = _filter.copyWith(priceRange: r)),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(child: _numberField('Min DA', _filter.priceRange.start.toInt(), (v) {
                            final min = double.tryParse(v) ?? 0;
                            setState(() => _filter = _filter.copyWith(priceRange: RangeValues(min, _filter.priceRange.end)));
                          })),
                          const SizedBox(width: 12),
                          Expanded(child: _numberField('Max DA', _filter.priceRange.end.toInt(), (v) {
                            final max = double.tryParse(v) ?? 50000;
                            setState(() => _filter = _filter.copyWith(priceRange: RangeValues(_filter.priceRange.start, max)));
                          })),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: Color(0xFFEFE0D8)),

                      // Stock Status
                      _sectionHeader('Stock Status', 1),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _stockChip('In Stock'),
                          _stockChip('Low Stock'),
                          _stockChip('Out of Stock'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: Color(0xFFEFE0D8)),

                      // Size Availability
                      _sectionHeader('Has Size', 2),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _sizeOptions.map((s) => _sizeToggle(s)).toList(),
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: Color(0xFFEFE0D8)),

                      // Category
                      _sectionHeader('Category', 3),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(children: _categoryOptions.map((c) => Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: _categoryChip(c),
                        )).toList()),
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: Color(0xFFEFE0D8)),

                      // Sort By
                      _sectionHeader('Sort By', 4),
                      const SizedBox(height: 8),
                      Column(children: _sortOptions.map((s) {
                        final sel = _filter.sortBy == s;
                        return RadioListTile<String>(
                          value: s,
                          groupValue: _filter.sortBy,
                          onChanged: (v) => setState(() => _filter = _filter.copyWith(sortBy: v)),
                          title: Text(s, style: const TextStyle(color: Color(0xFF2C1A0E))),
                          activeColor: const Color(0xFF8B4513),
                        );
                      }).toList()),
                      const Divider(color: Color(0xFFEFE0D8)),

                      // Product Status
                      _sectionHeader('Visibility', 5),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(child: Text('Active products only', style: TextStyle(color: Color(0xFF2C1A0E)))),
                          CupertinoSwitch(
                            activeColor: const Color(0xFF8B4513),
                            value: _filter.activeOnly,
                            onChanged: (v) => setState(() => _filter = _filter.copyWith(activeOnly: v)),
                          )
                        ],
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
              // bottom buttons
              SafeArea(
                minimum: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(children: [
                  Expanded(
                    flex: 4,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF8B4513)),
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF8B4513),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _resetLocal,
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 6,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B4513),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _loading ? null : () async {
                        setState(() => _loading = true);
                        await Future.delayed(const Duration(milliseconds: 300));
                        widget.onApply(_filter);
                        if (mounted) Navigator.of(context).pop();
                      },
                      child: _loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Apply Filters'),
                    ),
                  ),
                ]),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _numberField(String placeholder, int value, void Function(String) onChanged) {
    final controller = TextEditingController(text: value.toString());
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: placeholder,
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: const Color(0xFF8B4513))),
      ),
      onSubmitted: onChanged,
    );
  }

  Widget _stockChip(String label) {
    final selected = _filter.stockStatus.contains(label);
    return GestureDetector(
      onTap: () => _toggleStock(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF8B4513) : Colors.white,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: const Color(0xFFD9C4B0)),
        ),
        child: Text(label, style: TextStyle(color: selected ? Colors.white : const Color(0xFF2C1A0E), fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _sizeToggle(String s) {
    final selected = _filter.sizes.contains(s);
    return GestureDetector(
      onTap: () => _toggleSize(s),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF8B4513) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF8B4513)),
        ),
        child: Text(s, style: TextStyle(color: selected ? Colors.white : const Color(0xFF8B4513), fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _categoryChip(String c) {
    final sel = (_filter.category ?? 'All') == c || (_filter.category == null && c == 'All');
    return GestureDetector(
      onTap: () => setState(() => _filter = _filter.copyWith(category: c == 'All' ? null : c)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: sel ? const Color(0xFF8B4513) : Colors.white,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: const Color(0xFFD9C4B0)),
        ),
        child: Text(c, style: TextStyle(color: sel ? Colors.white : const Color(0xFF2C1A0E), fontWeight: FontWeight.w600)),
      ),
    );
  }
}
