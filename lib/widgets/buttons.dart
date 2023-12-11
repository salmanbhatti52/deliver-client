import 'package:flutter/material.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';

Widget buttonGradient(buttonText, context) {
  return Center(
    child: Container(
      height: MediaQuery.of(context).size.height * 0.065,
      width: MediaQuery.of(context).size.width * 0.6,
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
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          buttonText,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: whiteColor,
            fontSize: 16,
            fontFamily: 'Syne-Medium',
          ),
        ),
      ),
    ),
  );
}

Widget buttonGradient1(String buttonText, BuildContext context) {
  final double screenHeight = MediaQuery.of(context).size.height;
  final double screenWidth = MediaQuery.of(context).size.width;
  double fontSize = screenHeight * 0.02;
  return Center(
    child: SizedBox(
      height: screenHeight * 0.065,
      width: screenWidth * 0.6,
      child: ElevatedButton(
        onPressed: () {
          // Add your button onPressed logic here
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor:
              Colors.orange, // Replace with your gradient definition
        ),
        child: Text(
          buttonText,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontFamily: 'Syne-Medium',
          ),
        ),
      ),
    ),
  );
}

Widget buttonGradientWithLoader(buttonText, context) {
  return Center(
    child: Container(
      height: MediaQuery.of(context).size.height * 0.065,
      width: MediaQuery.of(context).size.width * 0.6,
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
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 25,
            height: 25,
            child: Center(
              child: CircularProgressIndicator(
                color: whiteColor,
                strokeWidth: 4,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Text(
            buttonText,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: whiteColor,
              fontSize: 16,
              fontFamily: 'Syne-Medium',
            ),
          ),
        ],
      ),
    ),
  );
}

Widget buttonTransparentGradient(buttonText, context) {
  return Center(
    child: Container(
      height: MediaQuery.of(context).size.height * 0.065,
      width: MediaQuery.of(context).size.width * 0.6,
      decoration: BoxDecoration(
        color: transparentColor,
        border: GradientBoxBorder(
          gradient: LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            stops: const [0.1, 1.5],
            colors: [
              orangeColor,
              yellowColor,
            ],
          ),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          buttonText,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: orangeColor,
            fontSize: 16,
            fontFamily: 'Syne-Medium',
          ),
        ),
      ),
    ),
  );
}

Widget buttonTransparent(buttonText, context) {
  return Center(
    child: Container(
      height: MediaQuery.of(context).size.height * 0.065,
      width: MediaQuery.of(context).size.width * 0.7,
      decoration: BoxDecoration(
        color: const Color(0xFFEBEBEB),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          buttonText,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: blackColor,
            fontSize: 16,
            fontFamily: 'Syne-Medium',
          ),
        ),
      ),
    ),
  );
}

Widget buttonGradientSmall(buttonText, context) {
  return Center(
    child: Container(
      height: MediaQuery.of(context).size.height * 0.06,
      width: MediaQuery.of(context).size.width * 0.43,
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
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          buttonText,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Syne-Medium',
          ),
        ),
      ),
    ),
  );
}

Widget buttonGradientSmallWithLoader(buttonText, context) {
  return Center(
    child: Container(
      height: MediaQuery.of(context).size.height * 0.06,
      width: MediaQuery.of(context).size.width * 0.43,
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
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: Center(
              child: CircularProgressIndicator(
                color: whiteColor,
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Text(
            buttonText,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: whiteColor,
              fontSize: 14,
              fontFamily: 'Syne-Medium',
            ),
          ),
        ],
      ),
    ),
  );
}

Widget buttonTransparentGradientSmall(buttonText, context) {
  return Center(
    child: Container(
      height: MediaQuery.of(context).size.height * 0.06,
      width: MediaQuery.of(context).size.width * 0.43,
      decoration: BoxDecoration(
        color: transparentColor,
        borderRadius: BorderRadius.circular(10),
        border: GradientBoxBorder(
          gradient: LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            stops: const [0.1, 1.5],
            colors: [
              orangeColor,
              yellowColor,
            ],
          ),
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          buttonText,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: orangeColor,
            fontSize: 16,
            fontFamily: 'Syne-Medium',
          ),
        ),
      ),
    ),
  );
}

Widget buttonTransparentGradientSmallWithLoader(buttonText, context) {
  return Center(
    child: Container(
      height: MediaQuery.of(context).size.height * 0.06,
      width: MediaQuery.of(context).size.width * 0.43,
      decoration: BoxDecoration(
        color: transparentColor,
        borderRadius: BorderRadius.circular(10),
        border: GradientBoxBorder(
          gradient: LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            stops: const [0.1, 1.5],
            colors: [
              orangeColor,
              yellowColor,
            ],
          ),
          width: 2,
        ),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Center(
                child: CircularProgressIndicator(
                  color: orangeColor,
                  strokeWidth: 3,
                ),
              ),
            ),
            const SizedBox(width: 15),
            Text(
              buttonText,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: orangeColor,
                fontSize: 14,
                fontFamily: 'Syne-Medium',
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget bottomSheetButtonGradientBig(buttonText, context) {
  return Center(
    child: Container(
      height: MediaQuery.of(context).size.height * 0.065,
      width: MediaQuery.of(context).size.width * 0.7,
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
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          buttonText,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: whiteColor,
            fontSize: 16,
            fontFamily: 'Syne-Medium',
          ),
        ),
      ),
    ),
  );
}

Widget detailButtonGradientSmall(buttonText, context) {
  return Center(
    child: Container(
      height: MediaQuery.of(context).size.height * 0.046,
      width: MediaQuery.of(context).size.width * 0.25,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.1, 1.5],
          colors: [
            yellowColor,
            orangeColor,
          ],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          buttonText,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: whiteColor,
            fontSize: 14,
            fontFamily: 'Syne-Regular',
          ),
        ),
      ),
    ),
  );
}

Widget detailButtonTransparentGradientSmall(buttonText, context) {
  return Center(
    child: Container(
      height: MediaQuery.of(context).size.height * 0.046,
      width: MediaQuery.of(context).size.width * 0.25,
      decoration: BoxDecoration(
        border: GradientBoxBorder(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.1, 1.5],
            colors: [
              yellowColor,
              orangeColor,
            ],
          ),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          buttonText,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: orangeColor,
            fontSize: 14,
            fontFamily: 'Syne-Regular',
          ),
        ),
      ),
    ),
  );
}

Widget statusButtonSmall(buttonText, color, context) {
  return Center(
    child: Container(
      height: MediaQuery.of(context).size.height * 0.03,
      width: MediaQuery.of(context).size.width * 0.2,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          buttonText,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: whiteColor,
            fontSize: 12,
            fontFamily: 'Syne-Medium',
          ),
        ),
      ),
    ),
  );
}

Widget statusGradientButtonSmall(buttonText, color, context) {
  return Center(
    child: Container(
      height: MediaQuery.of(context).size.height * 0.03,
      width: MediaQuery.of(context).size.width * 0.25,
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
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          buttonText,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: whiteColor,
            fontSize: 10,
            fontFamily: 'Syne-Medium',
          ),
        ),
      ),
    ),
  );
}

Widget statusGradientButtonSmallWithLoader(buttonText, context) {
  return Center(
    child: Container(
      height: MediaQuery.of(context).size.height * 0.03,
      width: MediaQuery.of(context).size.width * 0.25,
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
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 10,
            height: 10,
            child: Center(
              child: CircularProgressIndicator(
                color: whiteColor,
                strokeWidth: 1,
              ),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            buttonText,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: whiteColor,
              fontSize: 10,
              fontFamily: 'Syne-Medium',
            ),
          ),
        ],
      ),
    ),
  );
}

Widget dialogButtonGradientSmall(buttonText, context) {
  return Center(
    child: Container(
      height: MediaQuery.of(context).size.height * 0.06,
      width: MediaQuery.of(context).size.width * 0.35,
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
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          buttonText,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: whiteColor,
            fontSize: 16,
            fontFamily: 'Syne-Medium',
          ),
        ),
      ),
    ),
  );
}

Widget dialogButtonGradientSmallWithLoader(buttonText, context) {
  return Center(
    child: Container(
      height: MediaQuery.of(context).size.height * 0.06,
      width: MediaQuery.of(context).size.width * 0.35,
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
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 15,
            height: 15,
            child: Center(
              child: CircularProgressIndicator(
                color: whiteColor,
                strokeWidth: 2,
              ),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            buttonText,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: whiteColor,
              fontSize: 12,
              fontFamily: 'Syne-Medium',
            ),
          ),
        ],
      ),
    ),
  );
}

Widget dialogButtonTransparentGradientSmall(buttonText, context) {
  return Center(
    child: Container(
      height: MediaQuery.of(context).size.height * 0.06,
      width: MediaQuery.of(context).size.width * 0.35,
      decoration: BoxDecoration(
        color: transparentColor,
        borderRadius: BorderRadius.circular(10),
        border: GradientBoxBorder(
          gradient: LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            stops: const [0.1, 1.5],
            colors: [
              orangeColor,
              yellowColor,
            ],
          ),
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          buttonText,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: orangeColor,
            fontSize: 16,
            fontFamily: 'Syne-Medium',
          ),
        ),
      ),
    ),
  );
}
