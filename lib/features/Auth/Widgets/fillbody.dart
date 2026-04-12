import 'package:elbess_store/core/constants/button.dart';
import 'package:elbess_store/core/constants/textfield.dart';
import 'package:elbess_store/core/utils/size_config.dart';
import 'package:elbess_store/root.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class Fillbody extends StatelessWidget {
  const Fillbody({super.key});

  @override
  Widget build(BuildContext context) {
    final sh = SizeConfig.screenHeight!;
    final sw = SizeConfig.screenWidth!;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Gap(sh * 0.02),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(Icons.arrow_back_ios_new_outlined, size: 20),
                  ),
                  Gap(sw * 0.05),
                  Text(
                    'Fill your store details',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: sw * 0.05,
                      fontFamily: 'meduim',
                      fontWeight: FontWeight.w500,
                    ),
                  )
                ],
              ),
              Gap(sh * 0.03),
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: const Color(0xFFEAEAEA),
                      child: Icon(
                        Icons.person,
                        size: 46,
                        color: const Color(0xFFD7D7D7),
                      ),
                    ),
                    Positioned(
                      right: -2,
                      bottom: 2,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: const Color(0xFF8A5A44),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Gap(sh * 0.03),
              FillTextField(hint: "Store name"),
              Gap(sh * 0.02),
              FillTextField(hint: "Description"),
              Gap(sh * 0.02),
              FillTextField(hint: "Category"),
              
              Gap(sh * 0.2),
              CustomButton(text: "Continue", onPressed: () {
                Navigator.push(context, PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => Root(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                          .animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 400),
                ));
              }),
              Gap(sh * 0.02),

              
            ],
          ),
        ),
      ),
    ),

    );
  }
}
