
import 'package:elbess_store/core/utils/size_config.dart';
import 'package:elbess_store/features/Add/Presentation/addview.dart';
import 'package:elbess_store/features/Home/Widgets/homebody.dart';
import 'package:elbess_store/features/Inventory/Presentation/inventoryview.dart';
import 'package:elbess_store/features/Orders/Presentation/ordersview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Root extends StatefulWidget {
  const Root({super.key});

  @override
  State<Root> createState() => _RootState();
}

class _RootState extends State<Root> {
  late PageController pageController;
  late List<Widget Function()> _pageBuilders;
  final Map<int, Widget> _pageCache = {};
  int currentScreen = 0;
  final List<IconData> _icons = [
    CupertinoIcons.home,
    CupertinoIcons.cube_box,
    CupertinoIcons.tray_full,
    CupertinoIcons.add_circled_solid,
    
  ];
  final List<String> _labels = [
    'Home',
    'Orders',
    'Inventory',
    'Add',
  ];
  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: currentScreen);
    _pageBuilders = [
      () => Homebody(pageController: pageController),
      () => const Ordersview(),
      () => const Inventoryview(),
      () => const Addview(),
    ];
  }

  Widget _getPage(int index) {
    return _pageCache.putIfAbsent(index, () => _pageBuilders[index]());
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final sh = SizeConfig.screenHeight!;
    final sw = SizeConfig.screenWidth!;

    return Scaffold(
      extendBody: true,
      body: PageView.builder(
        physics: NeverScrollableScrollPhysics(),
        controller: pageController,
        itemCount: _pageBuilders.length,
        itemBuilder: (context, index) => _getPage(index),
        onPageChanged: (index) {
          setState(() {
            currentScreen = index;
          });
        },
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.fromLTRB(sw * 0.03, 0, sw * 0.04, sh * 0.02),
        padding: EdgeInsets.symmetric(horizontal: sw * 0.025, vertical: 1),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            // ignore: deprecated_member_use
            colors: [Color(0xFF8A5A44), Color(0xFF8A5A44).withOpacity(0.76)],
          ),
          borderRadius: BorderRadius.circular(50),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: List.generate(_icons.length, (index) {
              final bool isSelected = currentScreen == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      currentScreen = index;
                    });
                    pageController.animateToPage(
                      index,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 220),
                    curve: Curves.easeInOut,
                    margin: EdgeInsets.symmetric(horizontal: sw * 0.01),
                    padding: EdgeInsets.symmetric(vertical: sh * 0.006),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _icons[index],
                          color: isSelected
                              ? Color(0xFFEDE0D4)
                              : Color(0XFFDDB892),
                          size: isSelected ? sw * 0.055 : sw * 0.05,
                        ),
                        SizedBox(height: sh * 0.003),
                        Text(
                          _labels[index],
                          style: TextStyle(
                            color: isSelected
                                ? Color(0xFFEDE0D4)
                                : Color(0XFFDDB892),
                            fontSize: sw * 0.028,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

