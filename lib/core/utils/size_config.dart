import 'package:flutter/widgets.dart';

class SizeConfig {
	static double? screenWidth;
	static double? screenHeight;
	static double? defaultSize;
	static Orientation? orientation;

	void init(BuildContext context) {
		final mq = MediaQuery.of(context);
		screenWidth = mq.size.width;
		screenHeight = mq.size.height;
		orientation = mq.orientation;

		defaultSize = orientation == Orientation.landscape
				? screenHeight! * .024
				: screenWidth! * .024;

		// ignore: avoid_print
		print('this is the default size $defaultSize');
	}
}
