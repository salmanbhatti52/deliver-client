import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:deliver_client/widgets/loyalty_point_list.dart';
import 'package:deliver_client/screens/home/home_page_screen.dart';

String? userEmail;

class LoyaltyPointScreen extends StatefulWidget {
  const LoyaltyPointScreen({super.key});

  @override
  State<LoyaltyPointScreen> createState() => _LoyaltyPointScreenState();
}

class _LoyaltyPointScreenState extends State<LoyaltyPointScreen> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomePageScreen()),
            (Route<dynamic> route) => false);
        return false;
      },
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: bgColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: SvgPicture.asset(
                'assets/images/back-icon.svg',
                width: 22,
                height: 22,
                fit: BoxFit.scaleDown,
              ),
            ),
          ),
          title: Text(
            "Loyalty Points",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: blackColor,
              fontSize: 20,
              fontFamily: 'Syne-Bold',
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: size.height * 0.02),
              Container(
                color: transparentColor,
                width: size.width,
                height: size.height * 0.35,
                child: Stack(
                  children: [
                    Positioned(
                      top: -15,
                      right: -160,
                      child: SvgPicture.asset('assets/images/ring-icon.svg'),
                    ),
                    Positioned(
                      bottom: 0,
                      right: -10,
                      child: SvgPicture.asset('assets/images/coins-icon.svg'),
                    ),
                    Positioned(
                      top: 10,
                      left: 0,
                      right: 0,
                      child: Text(
                        "Total Earn Point",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: orangeColor,
                          fontSize: 18,
                          fontFamily: 'Syne-Bold',
                        ),
                      ),
                    ),
                    Positioned(
                      top: 122,
                      left: 20,
                      child: RichText(
                        overflow: TextOverflow.clip,
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: "379",
                          style: TextStyle(
                            color: orangeColor,
                            fontSize: 48,
                            fontFamily: 'Syne-Bold',
                          ),
                          children: [
                            TextSpan(
                              text: 'pt',
                              style: TextStyle(
                                color: orangeColor,
                                fontSize: 28,
                                fontFamily: 'Syne-Bold',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: size.height * 0.03),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "History of Points",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: drawerTextColor,
                      fontSize: 18,
                      fontFamily: 'Syne-Bold',
                    ),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.02),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  color: transparentColor,
                  height: size.height * 0.449,
                  child: loyaltyPointList(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
