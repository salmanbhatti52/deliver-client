import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:speech_balloon/speech_balloon.dart';
import 'package:deliver_client/widgets/buttons.dart';
import 'package:deliver_client/widgets/pay_tips_boxes.dart';
import 'package:deliver_client/screens/home/home_page_screen.dart';

class PayTipScreen extends StatefulWidget {
  const PayTipScreen({super.key});

  @override
  State<PayTipScreen> createState() => _PayTipScreenState();
}

class _PayTipScreenState extends State<PayTipScreen> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: transparentColor,
      body: Stack(
        children: [
          Image.asset(
            'assets/images/payment-location-background.png',
            width: size.width,
            height: size.height,
            fit: BoxFit.cover,
          ),
          Positioned(
            top: 45,
            left: 0,
            right: 0,
            child: Text(
              "Send Tip",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: blackColor,
                fontSize: 20,
                fontFamily: 'Syne-Bold',
              ),
            ),
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
                height: size.height * 0.43,
                decoration: BoxDecoration(
                  color: whiteColor,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: size.height * 0.04),
                        SpeechBalloon(
                          nipLocation: NipLocation.bottom,
                          nipHeight: 12,
                          borderColor: borderColor,
                          width: size.width * 0.32,
                          height: size.height * 0.07,
                          borderRadius: 10,
                          offset: const Offset(10, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: Image.asset(
                                  'assets/images/user-profile.png',
                                  width: 35,
                                  height: 35,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Jannie",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: blackColor,
                                      fontSize: 14,
                                      fontFamily: 'Syne-SemiBold',
                                    ),
                                  ),
                                  Text(
                                    "Drive",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: textHaveAccountColor,
                                      fontSize: 12,
                                      fontFamily: 'Syne-Regular',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: size.height * 0.03),
                        Text(
                          "Do you want to leave a tip?",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: blackColor,
                            fontSize: 18,
                            fontFamily: 'Syne-SemiBold',
                          ),
                        ),
                        SizedBox(height: size.height * 0.01),
                        Text(
                          "100% tip goes to the driver",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: textHaveAccountColor,
                            fontSize: 16,
                            fontFamily: 'Syne-Regular',
                          ),
                        ),
                        SizedBox(height: size.height * 0.04),
                        payTipsBoxes(
                            title1: '₦5',
                            title2: '₦10',
                            title3: '₦20',
                            title4: '₦30',
                            context: context),
                        SizedBox(height: size.height * 0.04),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => tipPaid(context),
                            );
                          },
                          child: buttonGradient("PAY TIP", context),
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
        ],
      ),
    );
  }
}

Widget tipPaid(BuildContext context) {
  var size = MediaQuery.of(context).size;
  return GestureDetector(
    onTap: () {
      FocusManager.instance.primaryFocus?.unfocus();
    },
    child: WillPopScope(
      onWillPop: () {
        return Future.value(false);
      },
      child: Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
        ),
        insetPadding: const EdgeInsets.only(left: 20, right: 20),
        child: SizedBox(
          height: size.height * 0.35,
          child: Stack(
            children: [
              Center(
                child: Lottie.asset("assets/images/confetti-icon.json"),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => const HomePageScreen()),
                            (Route<dynamic> route) => false);
                      },
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child:
                              SvgPicture.asset("assets/images/close-icon.svg"),
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.005),
                    Text(
                      'Awesome!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: orangeColor,
                        fontSize: 24,
                        fontFamily: 'Syne-Bold',
                      ),
                    ),
                    Text(
                      'Thanks for tipping. It really boost\ndriver moral.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: blackColor,
                        fontSize: 18,
                        fontFamily: 'Syne-Regular',
                      ),
                    ),
                    SizedBox(height: size.height * 0.03),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
