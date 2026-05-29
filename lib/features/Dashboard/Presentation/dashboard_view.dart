import 'package:elbess_store/widgets/elbess_app_bar.dart';
import 'package:elbess_store/widgets/elbess_bottom_nav.dart';
import 'package:flutter/material.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ElbessAppBar(title: 'Dashboard', subtitle: 'Good morning 👋'),
      body: const Center(child: Text('Dashboard placeholder - implement widgets here')),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF8B4513),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: ElbessBottomNav(currentIndex: _tab, onTab: (i) => setState(() => _tab = i)),
    );
  }
}
