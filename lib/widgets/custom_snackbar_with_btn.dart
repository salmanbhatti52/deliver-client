import 'package:flutter/material.dart';
import 'package:deliver_client/utils/colors.dart';

class CustomSnackBarWithBtn extends SnackBar {
  final String message;
  final String buttonText;
  final VoidCallback onPressed;

  CustomSnackBarWithBtn({
    Key? key,
    required this.message,
    required this.buttonText,
    required this.onPressed,
  }) : super(
    key: key,
    elevation: 0,
    width: double.infinity,
    behavior: SnackBarBehavior.floating,
    backgroundColor: transparentColor,
    duration: const Duration(seconds: 5),
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                color: whiteColor,
                fontFamily: 'Syne-Regular',
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onPressed,
            child: Container(
              width: 120,
              height: 40,
              decoration: BoxDecoration(
                color: grantPermissionColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  buttonText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: whiteColor,
                    fontFamily: 'Syne-Medium',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
