import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:deliver_client/screens/report_screen.dart';
import 'package:deliver_client/screens/payment/amount_to_pay_edit_screen.dart';

class InProgressHomeScreen extends StatefulWidget {
  const InProgressHomeScreen({super.key});

  @override
  State<InProgressHomeScreen> createState() => _InProgressHomeScreenState();
}

class _InProgressHomeScreenState extends State<InProgressHomeScreen> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: transparentColor,
      body: Stack(
        children: [
          Image.asset(
            'assets/images/tracking-location-background.png',
            width: size.width,
            height: size.height,
            fit: BoxFit.cover,
          ),
          Positioned(
            bottom: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
              child: Container(
                width: size.width,
                height: size.height * 0.51,
                decoration: BoxDecoration(
                  color: whiteColor,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: size.height * 0.04),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SvgPicture.asset(
                              'assets/images/small-black-send-icon.svg',
                            ),
                            SizedBox(width: size.width * 0.03),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Destination Address",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: textHaveAccountColor,
                                    fontSize: 14,
                                    fontFamily: 'Inter-Regular',
                                  ),
                                ),
                                SizedBox(height: size.height * 0.005),
                                Container(
                                  color: transparentColor,
                                  width: size.width * 0.7,
                                  child: AutoSizeText(
                                    "Rex House, 769 Isadore",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: blackColor,
                                      fontSize: 14,
                                      fontFamily: 'Inter-Medium',
                                    ),
                                    minFontSize: 14,
                                    maxFontSize: 14,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: size.height * 0.01),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SvgPicture.asset(
                              'assets/images/orange-distance-icon.svg',
                            ),
                            SizedBox(width: size.width * 0.02),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    "Estimated Distance to Destination",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: textHaveAccountColor,
                                      fontSize: 14,
                                      fontFamily: 'Inter-Regular',
                                    ),
                                  ),
                                ),
                                SizedBox(height: size.height * 0.005),
                                Text(
                                  "1.5 - 1.9 km",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: blackColor,
                                    fontSize: 14,
                                    fontFamily: 'Inter-Medium',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: size.height * 0.01),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SvgPicture.asset(
                              'assets/images/arrival-time-icon.svg',
                            ),
                            SizedBox(width: size.width * 0.02),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    "Estimated Time of Arrival",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: textHaveAccountColor,
                                      fontSize: 14,
                                      fontFamily: 'Inter-Regular',
                                    ),
                                  ),
                                ),
                                SizedBox(height: size.height * 0.005),
                                Text(
                                  "15 - 20m",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: blackColor,
                                    fontSize: 14,
                                    fontFamily: 'Inter-Medium',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: size.height * 0.02),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const AmountToPayEditScreen(),
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  color: transparentColor,
                                  width: 55,
                                  height: 55,
                                  child: Image.asset(
                                    'assets/images/user-profile.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: size.width * 0.03),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      color: transparentColor,
                                      width: size.width * 0.45,
                                      child: AutoSizeText(
                                        "Captain Jannie",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: drawerTextColor,
                                          fontSize: 16,
                                          fontFamily: 'Syne-SemiBold',
                                        ),
                                        minFontSize: 16,
                                        maxFontSize: 16,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(width: size.width * 0.1),
                                    Stack(
                                      children: [
                                        SvgPicture.asset(
                                            'assets/images/star-with-container-icon.svg'),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 1.5, left: 24),
                                          child: Text(
                                            "4.8",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: blackColor,
                                              fontSize: 14,
                                              fontFamily: 'Inter-Regular',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: size.height * 0.005),
                                Container(
                                  color: transparentColor,
                                  width: size.width * 0.45,
                                  child: AutoSizeText(
                                    "Yellow Toyota (NHN-5638)",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: textHaveAccountColor,
                                      fontSize: 14,
                                      fontFamily: 'Syne-Regular',
                                    ),
                                    minFontSize: 14,
                                    maxFontSize: 14,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(height: size.height * 0.002),
                                Row(
                                  children: [
                                    Row(
                                      children: [
                                        SvgPicture.asset(
                                            'assets/images/small-grey-location-icon.svg'),
                                        SizedBox(width: size.width * 0.01),
                                        Container(
                                          color: transparentColor,
                                          width: size.width * 0.3,
                                          child: AutoSizeText(
                                            "Near Rex House",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              color: textHaveAccountColor,
                                              fontSize: 14,
                                              fontFamily: 'Syne-Regular',
                                            ),
                                            minFontSize: 14,
                                            maxFontSize: 14,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(width: size.width * 0.01),
                                    Row(
                                      children: [
                                        SvgPicture.asset(
                                            'assets/images/small-grey-arrival-time-icon.svg'),
                                        SizedBox(width: size.width * 0.01),
                                        Container(
                                          color: transparentColor,
                                          width: size.width * 0.23,
                                          child: AutoSizeText(
                                            "ETA 15 - 20m",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              color: textHaveAccountColor,
                                              fontSize: 14,
                                              fontFamily: 'Syne-Regular',
                                            ),
                                            minFontSize: 14,
                                            maxFontSize: 14,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(width: size.width * 0.02),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const ReportScreen(),
                                          ),
                                        );
                                      },
                                      child: SvgPicture.asset(
                                          'assets/images/report-icon.svg'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: size.height * 0.02),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SvgPicture.asset(
                              'assets/images/small-white-send-icon.svg',
                            ),
                            SizedBox(width: size.width * 0.03),
                            Text(
                              "Pickup",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: textHaveAccountColor,
                                fontSize: 14,
                                fontFamily: 'Syne-Regular',
                              ),
                            ),
                            SizedBox(width: size.width * 0.02),
                            Container(
                              color: transparentColor,
                              width: size.width * 0.6,
                              child: AutoSizeText(
                                "Rex House, 900 Isadore",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: blackColor,
                                  fontSize: 14,
                                  fontFamily: 'Inter-Medium',
                                ),
                                minFontSize: 14,
                                maxFontSize: 14,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: size.height * 0.01),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SvgPicture.asset(
                              'assets/images/small-white-send-icon.svg',
                            ),
                            SizedBox(width: size.width * 0.03),
                            Text(
                              "Destination",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: textHaveAccountColor,
                                fontSize: 14,
                                fontFamily: 'Syne-Regular',
                              ),
                            ),
                            SizedBox(width: size.width * 0.02),
                            Container(
                              color: transparentColor,
                              width: size.width * 0.53,
                              child: AutoSizeText(
                                "Rex House, 769 Isadore",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: blackColor,
                                  fontSize: 14,
                                  fontFamily: 'Inter-Medium',
                                ),
                                minFontSize: 14,
                                maxFontSize: 14,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
