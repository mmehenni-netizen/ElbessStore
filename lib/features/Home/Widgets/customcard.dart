import 'package:elbess_store/core/utils/size_config.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class Customcard extends StatelessWidget {
  final IconData icn;
  final String nmbr;
  final String txt;
  final Color clr ;

  const Customcard({super.key, required this.icn, required this.nmbr, required this.txt, required this.clr});

  @override
  Widget build(BuildContext context) {
    final ds = SizeConfig.defaultSize!;
    return Expanded(
      child: Material(
                  elevation: 4,
                  shadowColor: clr,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ds * 2)),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: ds * 1.6, horizontal: ds * 1.8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(ds * 2),
                      color: clr,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Material(
                          shadowColor: Color(0xFFD6E4F9),
                          elevation: 4,
                          shape: CircleBorder(),
                          child: CircleAvatar(radius: ds * 2, backgroundColor: Colors.white, child: Icon(icn, size: ds * 2.2, color: HSLColor.fromColor(clr).withLightness(0.35).toColor()),)),
                        Gap(ds * 1.2),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: ds * 0.2),
                          child: Text(nmbr,style: TextStyle(fontSize: ds * 2.5, fontFamily: "bold",color: Colors.black),),
                        ),
                        Gap(ds * 0.5),
                        Text(txt ,style: TextStyle(fontSize: ds * 1.3, fontFamily: "meduim",color: Colors.grey.shade500,))
                      ],
                    ),
                  ),
                ),
    );
  }
}