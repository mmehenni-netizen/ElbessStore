import 'package:elbess_store/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
class CustomButton extends StatelessWidget {
  const CustomButton({super.key, required this.text, required this.onPressed});

  final String text;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
         height: 57,
          width: double.infinity,
        decoration: BoxDecoration(
         
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text(
        text,
        style: TextStyle(
      color: Colors.white,
      fontSize: 15,
         
      fontFamily: 'semi'
        ),
      ),
        ),
      ),
    );
  }
}

class OptionsButton extends StatelessWidget {
  const OptionsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  
                  Container(
                    
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Color(0xFFD9D9D9),width: 1),
                ),
                
                child: Center(
                  child: Image.asset(
                    'assets/Images/socialMediaLogos/google.png',
                    width: 20,
                    height: 20,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Gap(13),
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Color(0xFFD9D9D9),width: 1),
                ),
                child: Center(
                  child: Image.asset(
                    'assets/Images/socialMediaLogos/facebook.png',
                    width: 20,
                    height: 20,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Gap(13),
              
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Color(0xFFD9D9D9),width: 1),
                ),
                child: Center(
                  child: Image.asset(
                    'assets/Images/socialMediaLogos/apple.png',
                    width: 20,
                    height: 20,
                    fit: BoxFit.contain,
                  ),
                ),
              )
                ],

              );
  }
}
