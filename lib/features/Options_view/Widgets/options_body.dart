import 'package:elbess_store/core/constants/optionsbtn.dart';
import 'package:elbess_store/core/utils/size_config.dart';
import 'package:elbess_store/features/Auth/Presentation/Pages/login_view.dart';
import 'package:elbess_store/features/Subscription/subscription_screen.dart';
import 'package:elbess_store/features/Auth/Presentation/Pages/signup_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

class OptionsBody extends StatefulWidget {
  const OptionsBody({super.key});

  @override
  State<OptionsBody> createState() => _OptionsBodyState();
}

class _OptionsBodyState extends State<OptionsBody> {
  @override
  Widget build(BuildContext context) {
    final sh = SizeConfig.screenHeight!;
    final sw = SizeConfig.screenWidth!;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
            child: SizedBox(
              width: double.infinity,
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Gap(sh * 0.18),
              SvgPicture.asset('assets/Images/appLogo/Logo.svg',height: sh * 0.05),
              Gap(sh * 0.04),
              Text("Build your store",style: TextStyle(fontSize: sw * 0.06,fontFamily: "bold"),),
           Gap(sh * 0.08),
              GestureDetector(
              onTap: () {
                Navigator.push(context, PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const SubscriptionScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                          .animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 400),
                ));
              },
              child: OptionsBtn(continuee: "Create a new store")),
                  Gap(sh * 0.03),

                   GestureDetector(
                     onTap: () {
                       Navigator.push(context, PageRouteBuilder(
                         pageBuilder: (context, animation, secondaryAnimation) => const LoginView(),
                         transitionsBuilder: (context, animation, secondaryAnimation, child) {
                           return SlideTransition(
                             position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                                 .animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
                             child: child,
                           );
                         },
                         transitionDuration: const Duration(milliseconds: 400),
                       ));
                     },
                     child: Optionsbtn2(text: "Login to an existing store")),
                   Gap(sh * 0.02),
            Gap(sh * 0.06),
      
          
            ],
              ),
            ),
          ),
        ),
      )
    );
  }
}
