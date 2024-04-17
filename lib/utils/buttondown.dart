import 'package:flutter/material.dart';

Widget detailsButtonDown(context) {
  return Container(
    width: 30,
    height: 30,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      color: Colors.white,
      gradient: const LinearGradient(
        colors: [
          Color(0xffFF6302),
          Color(0xffFBC403),
        ],
        begin: Alignment.centerRight,
        end: Alignment.centerLeft,
      ),
    ),
    child: const Icon(
      Icons.keyboard_arrow_down_outlined,
       color: Colors.white,
      size: 18,
    ),
  );
}

Widget detailsButtonUp(context) {
  return Container(
    width: 30,
    height: 30,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
       color: Colors.white,
      gradient: const LinearGradient(
        colors: [
          Color(0xffFF6302),
          Color(0xffFBC403),
        ],
        begin: Alignment.centerRight,
        end: Alignment.centerLeft,
      ),
    ),
    child: const Icon(
      Icons.keyboard_arrow_up_outlined,
       color: Colors.white,
      size: 18,
    ),
  );
}
