import 'package:flutter/material.dart';

extension IntExtension on int? {
  int validate({int value = 0}) {
    return this ?? value;
  }

  double get responsiveHeight => (this?.toDouble() ?? 0) / 100 * MediaQueryData.fromView(WidgetsBinding.instance.window).size.height;

  double get responsiveWidth => (this?.toDouble() ?? 0) / 100 * MediaQueryData.fromView(WidgetsBinding.instance.window).size.width;

  Widget get kH => SizedBox(
        height: responsiveHeight,
      );

  Widget get kW => SizedBox(
        width: responsiveWidth,
      );
}