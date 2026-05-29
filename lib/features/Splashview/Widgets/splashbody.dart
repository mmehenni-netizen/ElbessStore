
import 'dart:async';

import 'package:elbess_store/features/Options_view/Presentation/options_view.dart';
import 'package:elbess_store/core/utils/pref_helpers.dart';
import 'package:elbess_store/root.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

class Splashbody extends StatefulWidget {
  const Splashbody({super.key});

  @override
  State<Splashbody> createState() => _SplashbodyState();
}

class _SplashbodyState extends State<Splashbody> {
  bool _fadeOut = false;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _fadeOut = true;
      });
    });
    Timer(const Duration(milliseconds: 3600), () {
      if (!mounted) return;
      _goNext();
    });
  }

  Future<void> _goNext() async {
    final token = await PrefHelpers.getToken();
    final storeId = await PrefHelpers.getStoreId();

    if (!mounted) return;

    if ((token != null && token.isNotEmpty) || (storeId != null && storeId.isNotEmpty)) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Root()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OptionsView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _fadeOut ? 0 : 1,
      duration: const Duration(milliseconds: 600),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/Images/appLogo/Logo.svg',
              width: 281,
              height: 42,
              fit: BoxFit.contain,
            ),
            Gap(6),
            Text(
              'Own Your Look',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF8A5A44),
                fontSize: 17,
                fontFamily: 'meduim',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
