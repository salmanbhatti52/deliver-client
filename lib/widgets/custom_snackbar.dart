import 'package:flutter/material.dart';
import 'package:deliver_client/utils/colors.dart';

class CustomSnackBar extends SnackBar {
  final String message;

  CustomSnackBar({
    Key? key,
    required this.message,
    required Size size,
  }) : super(
    key: key,
    elevation: 0,
    width: size.width,
    behavior: SnackBarBehavior.floating,
    backgroundColor: transparentColor,
    duration: const Duration(seconds: 2),
    content: Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          stops: const [0.1, 1.5],
          colors: [
            orangeColor,
            yellowColor,
          ],
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 2,
            spreadRadius: 2,
            offset: const Offset(0, 3),
            color: blackColor.withOpacity(0.2),
          ),
        ],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          width: 2,
          color: borderColor,
        ),
      ),
      child: Text(
        message,
        style: TextStyle(
          fontSize: 12,
          color: whiteColor,
          fontFamily: 'Syne-Bold',
        ),
      ),
    ),
  );
}
