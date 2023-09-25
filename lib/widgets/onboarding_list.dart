import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:deliver_client/utils/colors.dart';

Widget onBoardingList(BuildContext context) {
  return PageView.builder(
    physics: const AlwaysScrollableScrollPhysics(),
    scrollDirection: Axis.horizontal,
    itemCount: myList.length,
    itemBuilder: (BuildContext context, int index) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: SvgPicture.asset("${myList[index].image}"),
          ),
          Text(
            "${myList[index].title}".toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: orangeColor,
              fontSize: 20,
              fontFamily: 'Inter-Bold',
            ),
          ),
          Text(
            "${myList[index].subtitle}",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: blackColor,
              fontSize: 16,
              fontFamily: 'Inter-Regular',
            ),
          ),
          SvgPicture.asset("${myList[index].image2}"),
        ],
      );
    },
  );
}

List myList = [
  MyList(
    "assets/images/onboarding-icon-1.svg",
    "Fast and Reliable Service",
    "Experience a reliable and efficient\nparcel delivery service at your\nfingertips.\nTrust us to safely and swiftly deliver\nyour packages to their destination.",
    "assets/images/onboarding-pageview-icon-1.svg",
  ),
  MyList(
    "assets/images/onboarding-icon-2.svg",
    "Real-Time Tracking",
    "Stay updated on the progress of your\ndelivery in real time. Track your\npackage from pickup to drop-off,\nensuring you're always in the loop.\n",
    "assets/images/onboarding-pageview-icon-2.svg",
  ),
  MyList(
    "assets/images/onboarding-icon-3.svg",
    "Safe and Secure Delivery",
    "Rest assured knowing that your\npackage is in safe hands. Our\nprofessional couriers will handle your\nitems with care and deliver them\nsecurely.",
    "assets/images/onboarding-pageview-icon-3.svg",
  ),
];

class MyList {
  String? image;
  String? title;
  String? subtitle;
  String? image2;

  MyList(this.image, this.title, this.subtitle, this.image2);
}
