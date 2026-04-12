import 'package:elbess_store/core/constants/button.dart';
import 'package:elbess_store/core/constants/colors.dart';
import 'package:elbess_store/core/constants/textfield.dart';
import 'package:elbess_store/core/utils/size_config.dart';
import 'package:elbess_store/features/Auth/Presentation/Pages/fill_profile_view.dart';
import 'package:elbess_store/features/Auth/Presentation/Pages/login_view.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart' show Gap;

class Signupbody extends StatefulWidget {
  const Signupbody({super.key});

  @override
  State<Signupbody> createState() => _SignupbodyState();
}

class _SignupbodyState extends State<Signupbody> {
  @override
  Widget build(BuildContext context) {
    final sh = SizeConfig.screenHeight!;
    final sw = SizeConfig.screenWidth!;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Gap(sh * 0.02),
             GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(Icons.arrow_back_ios_new_outlined, size: 20),
              ),
              Gap(sh * 0.05),
              SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create your ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: sw * 0.085,
                        fontFamily: 'semi',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Store',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: sw * 0.085,
                        fontFamily: 'semi',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Gap(sh * 0.03),
              CustomTextField(
                title: "Email",
                hinttext: "enter your email",
                prefixIcon: Icons.email_outlined,
              ),
              Gap(sh * 0.012),
              CustomTextField(
                title: "Password",
                hinttext: "enter your password",
                prefixIcon: Icons.lock_outline,
                obscureText: true,
              ),
              Gap(sh * 0.012),
              CustomTextField(
                title: "Confirm password",
                hinttext: "confirm your password",
                prefixIcon: Icons.lock_outline,
                obscureText: true,
              ),
              Gap(sh * 0.04),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: sw * 0.025),
                child: CustomButton(
                  text: "Sign up",
                  onPressed: () {
                    Navigator.push(context, PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => const FillProfileView(),
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
                ),
              ),
              Gap(sh * 0.04),
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Color(0xFFD4D4D4),
                      thickness: 1,
                    ),
                  ),
                  Gap(7),
                  Text(
                    'Or',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontFamily: 'semi',
                    ),
                  ),
                  Gap(12),
                  Expanded(
                    child: Divider(
                      color: Color(0xFFD4D4D4),
                      thickness: 1,
                    ),
                  ),
                ],
              ),
              Gap(sh * 0.015),
            
              Gap(sh * 0.02),
              Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Don't have an account? ",style: TextStyle(fontSize: sw * 0.03,fontFamily: "medium",color: Colors.grey),),
            GestureDetector(
              onTap: (){
                setState(() {
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
                });
              },
              child: Text("Log in",style: TextStyle(fontSize: sw * 0.03,fontFamily: "semi",color: AppColors.primary),))

          ],
        )
              
            ],
          ),
        ),
      )
    );
  }
}
