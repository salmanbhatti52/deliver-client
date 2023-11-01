// ignore_for_file: avoid_print,

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:speech_balloon/speech_balloon.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:deliver_client/widgets/buttons.dart';
import 'package:deliver_client/widgets/who_will_pay_bottomsheet.dart';

class ConfirmMultipleDetailsScreen extends StatefulWidget {
  final List<Map<String, dynamic>>? dataForIndexes;
  const ConfirmMultipleDetailsScreen({super.key, this.dataForIndexes});

  @override
  State<ConfirmMultipleDetailsScreen> createState() =>
      _ConfirmMultipleDetailsScreenState();
}

class _ConfirmMultipleDetailsScreenState
    extends State<ConfirmMultipleDetailsScreen> {
  List<Map<String, dynamic>>? datalist;

  @override
  initState() {
    super.initState();
    datalist = widget.dataForIndexes;
    print("datalist  $datalist");
    // print(
    //     "Data for 0: ${widget.dataForIndexes![0]['pickupLatLng']['latitude']}");
     if (datalist != null) {
      for (var i = 0; i < datalist!.length; i++) {
        final dataForIndex = datalist![i];
        final dataIndex = dataForIndex.keys.first; // Get the index

        print("Data for Index $dataIndex: ${dataForIndex[dataIndex]}");
      }
    }
    // print("Data for 0: ${widget.dataForIndexes![0]}");
    // print("Data for 1: ${widget.dataForIndexes![1]}");
    // print("Data for 2: ${widget.dataForIndexes![2]}");
    // print("Data for 3: ${widget.dataForIndexes![3]}");
    // print("Data for 4: ${widget.dataForIndexes![4]}");
    // print("Data for 5: ${widget.dataForIndexes![5]}");
    // print("Data for 6: ${widget.dataForIndexes![6]}");
    // print("Data for 7: ${widget.dataForIndexes![7]}");
    // print("Data for 8: ${widget.dataForIndexes![8]}");
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: bgColor,
        body: Stack(
          children: [
            Image.asset(
              'assets/images/home-location-background.png',
              fit: BoxFit.cover,
            ),
            Positioned(
              top: 40,
              left: 20,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: SvgPicture.asset(
                  'assets/images/back-icon.svg',
                  fit: BoxFit.scaleDown,
                ),
              ),
            ),
            Positioned(
              top: 240,
              right: 120,
              child: Image.asset(
                'assets/images/bike-icon.png',
                width: 100,
                height: 100,
              ),
            ),
            Positioned(
              top: 101,
              right: 4,
              child: SvgPicture.asset('assets/images/bike-path-icon.svg'),
            ),
            Positioned(
              top: 225,
              right: 135,
              child: SpeechBalloon(
                nipLocation: NipLocation.bottom,
                nipHeight: 12,
                color: orangeColor,
                borderColor: borderColor,
                width: size.width * 0.3,
                height: size.height * 0.05,
                borderRadius: 10,
                offset: const Offset(10, 0),
                child: Center(
                  child: Text(
                    "4 hours 5 mins",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: whiteColor,
                      fontSize: 12,
                      fontFamily: 'Syne-SemiBold',
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 85,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: size.width * 0.6,
                  height: size.height * 0.45,
                  color: whiteColor,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: size.height * 0.02),
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
                                  right: 35,
                                  child: SvgPicture.asset(
                                    'assets/images/naira-icon.svg',
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  child: Text(
                                    '80.0',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: blackColor,
                                      fontSize: 56,
                                      fontFamily: 'Inter-Bold',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                'Discount: ',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: blackColor,
                                  fontSize: 14,
                                  fontFamily: 'Inter-Medium',
                                ),
                              ),
                              SizedBox(width: size.width * 0.01),
                              Text(
                                '₦ ',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: orangeColor,
                                  fontSize: 14,
                                  fontFamily: 'Inter-Medium',
                                ),
                              ),
                              Text(
                                '6.03',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: blackColor,
                                  fontSize: 14,
                                  fontFamily: 'Inter-Medium',
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: size.height * 0.005),
                          Row(
                            children: [
                              Text(
                                'Total Price: ',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: blackColor,
                                  fontSize: 14,
                                  fontFamily: 'Inter-Medium',
                                ),
                              ),
                              SizedBox(width: size.width * 0.01),
                              Text(
                                '₦ ',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: orangeColor,
                                  fontSize: 14,
                                  fontFamily: 'Inter-Medium',
                                ),
                              ),
                              Text(
                                '80.03',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: blackColor,
                                  fontSize: 14,
                                  fontFamily: 'Inter-Medium',
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: size.height * 0.03),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SvgPicture.asset(
                                'assets/images/orange-location-big-icon.svg',
                              ),
                              SizedBox(width: size.width * 0.04),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pickup',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: textHaveAccountColor,
                                      fontSize: 14,
                                      fontFamily: 'Syne-Regular',
                                    ),
                                  ),
                                  SizedBox(height: size.height * 0.01),
                                  Container(
                                    color: transparentColor,
                                    width: size.width * 0.54,
                                    child: AutoSizeText(
                                      "Neon Café, 23/A Park Avenue",
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
                          Divider(
                            thickness: 1,
                            color: dividerColor,
                            indent: 30,
                            endIndent: 30,
                          ),
                          SizedBox(height: size.height * 0.01),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SvgPicture.asset(
                                  'assets/images/send-small-icon.svg'),
                              SizedBox(width: size.width * 0.04),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Dropoff  1',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: textHaveAccountColor,
                                          fontSize: 14,
                                          fontFamily: 'Syne-Regular',
                                        ),
                                      ),
                                      SizedBox(width: size.width * 0.35),
                                      Text(
                                        '₦ ',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: orangeColor,
                                          fontSize: 14,
                                          fontFamily: 'Inter-Medium',
                                        ),
                                      ),
                                      Text(
                                        '46.03',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: blackColor,
                                          fontSize: 14,
                                          fontFamily: 'Inter-Medium',
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: size.height * 0.01),
                                  Container(
                                    color: transparentColor,
                                    width: size.width * 0.54,
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
                          Divider(
                            thickness: 1,
                            color: dividerColor,
                            indent: 30,
                            endIndent: 30,
                          ),
                          SizedBox(height: size.height * 0.01),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SvgPicture.asset(
                                  'assets/images/send-small-icon.svg'),
                              SizedBox(width: size.width * 0.04),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Dropoff  2',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: textHaveAccountColor,
                                          fontSize: 14,
                                          fontFamily: 'Syne-Regular',
                                        ),
                                      ),
                                      SizedBox(width: size.width * 0.35),
                                      Text(
                                        '₦ ',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: orangeColor,
                                          fontSize: 14,
                                          fontFamily: 'Inter-Medium',
                                        ),
                                      ),
                                      Text(
                                        '20.00',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: blackColor,
                                          fontSize: 14,
                                          fontFamily: 'Inter-Medium',
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: size.height * 0.01),
                                  Container(
                                    color: transparentColor,
                                    width: size.width * 0.54,
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
                          Divider(
                            thickness: 1,
                            color: dividerColor,
                            indent: 30,
                            endIndent: 30,
                          ),
                          SizedBox(height: size.height * 0.01),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SvgPicture.asset(
                                  'assets/images/send-small-icon.svg'),
                              SizedBox(width: size.width * 0.04),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Dropoff  3',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: textHaveAccountColor,
                                          fontSize: 14,
                                          fontFamily: 'Syne-Regular',
                                        ),
                                      ),
                                      SizedBox(width: size.width * 0.35),
                                      Text(
                                        '₦ ',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: orangeColor,
                                          fontSize: 14,
                                          fontFamily: 'Inter-Medium',
                                        ),
                                      ),
                                      Text(
                                        '20.00',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: blackColor,
                                          fontSize: 14,
                                          fontFamily: 'Inter-Medium',
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: size.height * 0.01),
                                  Container(
                                    color: transparentColor,
                                    width: size.width * 0.54,
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
                          SizedBox(height: size.height * 0.02),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 15,
              left: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  // whoWillPaySheet(
                  //   payNow: "Pay Now",
                  //   imagepayNow: "assets/images/pay-now-icon.svg",
                  //   sender: "Sender",
                  //   payLater: "Pay on Delivery",
                  //   imagepayLater: "assets/images/pay-later-icon.svg",
                  //   receiver: "Receiver",
                  //   context,
                  // );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WhoWillPaySheet(),
                    ),
                  );
                },
                child: buttonGradient("CONFIRM", context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
