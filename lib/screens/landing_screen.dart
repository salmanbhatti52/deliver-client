import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:deliver_client/widgets/buttons.dart';
import 'package:deliver_client/screens/onboarding_screen.dart';
import 'package:deliver_client/screens/login/login_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: transparentColor,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                child: SvgPicture.asset(
                  "assets/images/landing-background.svg",
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: size.height * 0.15),
            Text(
              "Register and get your packaged\ndelivered on time and safely.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: sheetBarrierColor,
                fontSize: 20,
                fontFamily: 'Inter-Regular',
              ),
            ),
            SizedBox(height: size.height * 0.1),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const OnBoardingScreen()));
              },
              child: buttonGradient('REGISTER', context),
            ),
            SizedBox(height: size.height * 0.16),
            RichText(
              overflow: TextOverflow.clip,
              textAlign: TextAlign.center,
              text: TextSpan(
                text: "Have an account already? ",
                style: TextStyle(
                  color: orangeColor,
                  fontSize: 12,
                  fontFamily: 'Inter-Light',
                ),
                children: [
                  TextSpan(
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        // Handle the tap event, e.g., navigate to a new screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                    text: 'Login',
                    style: TextStyle(
                      color: orangeColor,
                      fontSize: 14,
                      fontFamily: 'Inter-Bold',
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: size.height * 0.02),
          ],
        ),
      ),
    );
  }
}
