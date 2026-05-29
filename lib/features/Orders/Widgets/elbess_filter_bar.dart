import 'package:flutter/material.dart';

typedef FilterChanged = void Function(String? status, String? period);

class ElbessFilterBar extends StatefulWidget {
  final FilterChanged? onFilterChanged;
  const ElbessFilterBar({Key? key, this.onFilterChanged}) : super(key: key);

  @override
  State<ElbessFilterBar> createState() => _ElbessFilterBarState();
}

class _ElbessFilterBarState extends State<ElbessFilterBar> {
  String? selectedStatus = 'All';
  String? selectedPeriod;
  String? _pressedLabel;

  static const _statusChips = [
    'All',
    'confirmed',
    'prepared',
    'shipped',
    'delivered',
    'canceled',
  ];

  static const _periodChips = [
    'Today',
    'Last 7 days',
    'Last 30 days',
  ];

  void _notify() {
    widget.onFilterChanged?.call(selectedStatus, selectedPeriod);
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    VoidCallback? onTap,
    IconData? leadingIcon,
  }) {
    final bgSelected = const Color(0xFF8B4513);
    final textSelected = Colors.white;
    final bgUnselected = Colors.white;
    final textUnselected = const Color(0xFF2C1A0E);
    final borderColor = const Color(0xFFD9C4B0);

    final isPressed = _pressedLabel == label;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressedLabel = label),
      onTapUp: (_) {
        setState(() => _pressedLabel = null);
        onTap?.call();
      },
      onTapCancel: () => setState(() => _pressedLabel = null),
      child: Transform.scale(
        scale: isPressed ? 0.95 : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: isSelected ? bgSelected : bgUnselected,
            borderRadius: BorderRadius.circular(50),
            border: isSelected ? null : Border.all(color: borderColor, width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leadingIcon != null) ...[
                Icon(leadingIcon, size: 18, color: isSelected ? textSelected : textUnselected),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  fontFamily: isSelected ? 'bold' : 'semi',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? textSelected : textUnselected,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // stacked layout: status row above, time + filter row below
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _statusChips.map((s) {
                final isSelected = selectedStatus == s;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildChip(
                    label: s,
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        if (s == 'All') {
                          selectedStatus = 'All';
                          selectedPeriod = null;
                        } else if (selectedStatus == s) {
                          selectedStatus = 'All';
                        } else {
                          selectedStatus = s;
                        }
                      });
                      _notify();
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _periodChips.map((p) {
                      final isSelected = selectedPeriod == p;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _buildChip(
                          label: p,
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              if (selectedPeriod == p) {
                                selectedPeriod = null;
                              } else {
                                selectedPeriod = p;
                              }
                            });
                            _notify();
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // special filter chip
              _buildChip(
                label: 'Filter',
                isSelected: false,
                leadingIcon: Icons.filter_list_rounded,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
                    builder: (_) => const Padding(
                      padding: EdgeInsets.all(20),
                      child: SizedBox(height: 120, child: Center(child: Text('Advanced Filters coming soon'))),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Demo screen
class ElbessFilterBarDemo extends StatelessWidget {
  const ElbessFilterBarDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Elbess Filter Bar Demo')),
      body: Column(
        children: [
          const ElbessFilterBar(
            onFilterChanged: null,
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: () {
                // usage example with callback
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(content: const Text('Place ElbessFilterBar in your UI and provide an onFilterChanged callback')),
                );
              },
              child: const Text('Usage Tip'),
            ),
          )
        ],
      ),
    );
  }
}
