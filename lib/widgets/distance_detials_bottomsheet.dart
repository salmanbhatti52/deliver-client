import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:deliver_client/widgets/buttons.dart';
import 'package:deliver_client/screens/driver_found_screen.dart';

Future<dynamic> distanceDetailsSheet(BuildContext context) {
  var size = MediaQuery.of(context).size;
  return showModalBottomSheet(
    context: context,
    backgroundColor: whiteColor,
    // barrierColor: sheetBarrierColor,
    // isDismissible: false,
    elevation: 0,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
    ),
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) => SizedBox(
          width: size.width,
          height: size.height * 0.45,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                color: transparentColor,
                width: size.width * 0.75,
                height: size.height * 0.09,
                child: Stack(
                  children: [
                    Positioned(
                      top: 13,
                      left: 0,
                      child: Text(
                        "Fare",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: orangeColor,
                          fontSize: 37,
                          fontFamily: 'Syne-Bold',
                        ),
                      ),
                    ),
                    Positioned(
                      top: 18,
                      left: 0,
                      right: 40,
                      child: SvgPicture.asset('assets/images/naira-icon.svg'),
                    ),
                    Positioned(
                      right: 0,
                      child: Text(
                        '40.0',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: blackColor,
                          fontSize: 59,
                          fontFamily: 'Inter-Bold',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: size.height * 0.06),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    SvgPicture.asset('assets/images/orange-distance-icon.svg'),
                    SizedBox(width: size.width * 0.02),
                    Text(
                      'Estimated Distance',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: textHaveAccountColor,
                        fontSize: 14,
                        fontFamily: 'Syne-Medium',
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '1.5 - 1.9 km',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: blackColor,
                        fontSize: 14,
                        fontFamily: 'Inter-SemiBOld',
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: size.height * 0.02),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    SvgPicture.asset('assets/images/orange-distance-icon.svg'),
                    SizedBox(width: size.width * 0.02),
                    Text(
                      'Estimated Distance',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: textHaveAccountColor,
                        fontSize: 14,
                        fontFamily: 'Syne-Medium',
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '1.5 - 1.9 km',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: blackColor,
                        fontSize: 14,
                        fontFamily: 'Inter-SemiBOld',
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: size.height * 0.02),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    SvgPicture.asset('assets/images/orange-distance-icon.svg'),
                    SizedBox(width: size.width * 0.02),
                    Text(
                      'Time',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: textHaveAccountColor,
                        fontSize: 14,
                        fontFamily: 'Syne-Medium',
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '25 min',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: blackColor,
                        fontSize: 14,
                        fontFamily: 'Inter-SemiBOld',
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: size.height * 0.05),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DriverFoundScreen(),
                    ),
                  );
                },
                child: bottomSheetButtonGradientBig("ACCEPT", context),
              ),
            ],
          ),
        ),
      );
    },
  );
}
