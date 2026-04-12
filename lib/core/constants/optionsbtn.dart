import 'package:elbess_store/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class OptionsBtn extends StatefulWidget {
  const OptionsBtn({super.key, required this.continuee});
  final String continuee;


  @override
  State<OptionsBtn> createState() => _OptionsBtnState();
}

class _OptionsBtnState extends State<OptionsBtn> {
  @override
  Widget build(BuildContext context) {
    return  Padding(padding: EdgeInsets.symmetric(horizontal: 20),
         child: Material(
          elevation: 2,
          borderRadius: BorderRadius.circular(10),
          shadowColor: Color(0xffE4E4E4),
           child: Container(
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Color(0xffE4E4E4),
                  width: 1,
                )
               
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    
                    Gap(12),
                    Text(
                      widget.continuee,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, fontFamily: "semi",color: Colors.white),
                    )
                  ],
                ),
              ),
            ),
         )
          );
  }
}
class Optionsbtn2 extends StatelessWidget {
  const Optionsbtn2({super.key, required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.symmetric(horizontal: 20),
         child: Material(
          elevation: 2,
          borderRadius: BorderRadius.circular(10),
          shadowColor: Color(0xffE4E4E4),
           child: Container(
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.primary,
                  width: 1,
                )
               
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    
                    Gap(12),
                    Text(
                      text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, fontFamily: "semi",color: AppColors.primary),
                    )
                  ],
                ),
              ),
            ),
         ),
    );
  }
}