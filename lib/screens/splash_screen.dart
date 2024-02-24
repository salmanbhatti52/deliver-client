// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deliver_client/screens/onboarding_screen.dart';
import 'package:deliver_client/screens/login/login_screen.dart';
import 'package:deliver_client/screens/home/home_page_screen.dart';

String? userId;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isOnboardingShown = false;

  Future<void> checkIfOnboardingShown() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isOnboardingShown = prefs.getBool('onboardingShown') ?? false;
  }

  Future<void> markOnboardingAsShown() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingShown', true);
  }

  sharedPrefs() async {
    await checkIfOnboardingShown();

    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    userId = sharedPref.getString('userId');

    if (userId != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePageScreen()),
      );
      debugPrint("current session starts with userId = $userId");
    } else {
      if (!isOnboardingShown) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnBoardingScreen()),
        );
        markOnboardingAsShown(); // Mark onboarding as shown
        debugPrint("Navigating to OnboardingScreen");
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
        debugPrint("userId value is = $userId");
      }
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      sharedPrefs();
    });
  }

  initScreen(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo-big-icon.png',
                width: 300,
                height: 125,
              ),
              Container(
                color: transparentColor,
                child: DefaultTextStyle(
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: blackColor,
                    fontSize: 32,
                    fontFamily: 'Inter-Light',
                  ),
                  child: AnimatedTextKit(
                    repeatForever: false,
                    animatedTexts: [
                      TypewriterAnimatedText(
                        'We Get It There',
                        speed: const Duration(milliseconds: 100),
                      ),
                    ],
                    onTap: () {},
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return initScreen(context);
  }
}

// // ignore_for_file: use_build_context_synchronously
//
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:deliver_client/utils/colors.dart';
// import 'package:animated_text_kit/animated_text_kit.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:deliver_client/screens/login/login_screen.dart';
// import 'package:deliver_client/screens/home/home_page_screen.dart';
//
// String? userId;
//
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
//
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen> {
//   sharedPrefs() async {
//     SharedPreferences sharedPref = await SharedPreferences.getInstance();
//     userId = (sharedPref.getString('userId'));
//     debugPrint("userId in LoginPrefs is = $userId");
//
//     if (userId != null) {
//       Navigator.pushReplacement(context,
//           MaterialPageRoute(builder: (context) => const HomePageScreen()));
//       debugPrint("current session starts with userId = $userId");
//     } else {
//       Navigator.pushReplacement(context,
//           MaterialPageRoute(builder: (context) => const LoginScreen()));
//       debugPrint("userId value is = $userId");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return initScreen(context);
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     Future.delayed(const Duration(seconds: 3), () {
//       sharedPrefs();
//     });
//   }
//
//   initScreen(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () {
//         return Future.value(false);
//       },
//       child: Scaffold(
//           backgroundColor: bgColor,
//           body: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Image.asset(
//                   'assets/images/logo-big-icon.png',
//                   width: 300,
//                   height: 125,
//                 ),
//                 Container(
//                   color: transparentColor,
//                   child: DefaultTextStyle(
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       color: blackColor,
//                       fontSize: 32,
//                       fontFamily: 'Inter-Light',
//                     ),
//                     child: AnimatedTextKit(
//                       repeatForever: false,
//                       animatedTexts: [
//                         TypewriterAnimatedText(
//                           'We Get It There',
//                           speed: const Duration(milliseconds: 100),
//                         ),
//                       ],
//                       onTap: () {},
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           )),
//     );
//   }
// }
