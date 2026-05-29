import 'package:flutter/material.dart';
import '../models/inventory_filter_model.dart';
import 'elbess_inventory_filter_sheet.dart';

class ElbessFilterButton extends StatelessWidget {
  final InventoryFilterModel currentFilter;
  final void Function(InventoryFilterModel) onApply;

  const ElbessFilterButton({Key? key, required this.currentFilter, required this.onApply}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final activeCount = currentFilter.isActive ? 1 : 0; // could compute number of active options

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () async {
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => ElbessInventoryFilterSheet(
            currentFilter: currentFilter,
            onApply: onApply,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFD9C4B0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.filter_list, size: 18, color: Color(0xFF2C1A0E)),
            const SizedBox(width: 8),
            const Text('Filter', style: TextStyle(color: Color(0xFF2C1A0E), fontWeight: FontWeight.w600)),
            if (activeCount > 0) ...[
              const SizedBox(width: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22,
                height: 22,
                decoration: BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                child: Center(child: Text('$activeCount', style: const TextStyle(color: Colors.white, fontSize: 12))),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
