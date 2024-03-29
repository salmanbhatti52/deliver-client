import 'package:flutter/material.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:deliver_client/widgets/buttons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deliver_client/widgets/onboarding_list.dart';
import 'package:deliver_client/screens/login/login_screen.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  Future<void> markOnboardingAsShown() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingShown', true);
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: whiteColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(height: size.height * 0.0),
            Container(
              color: whiteColor,
              width: size.width,
              height: size.height * 0.8,
              child: onBoardingList(context),
            ),
            GestureDetector(
              onTap: () {
                markOnboardingAsShown(); // Mark onboarding as shown
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              },
              child: buttonGradient("Get Started", context),
            ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     GestureDetector(
            //       onTap: () {
            //         markOnboardingAsShown(); // Mark onboarding as shown
            //         Navigator.pushReplacement(
            //           context,
            //           MaterialPageRoute(
            //             builder: (context) => const LoginScreen(),
            //           ),
            //         );
            //       },
            //       child: buttonGradientSmall('SIGN IN', context),
            //     ),
            //     GestureDetector(
            //       onTap: () {
            //         markOnboardingAsShown(); // Mark onboarding as shown
            //         // Navigator.push(
            //         //   context,
            //         //   MaterialPageRoute(
            //         //     builder: (context) => const SignUpScreen(),
            //         //   ),
            //         // );
            //       },
            //       child: buttonTransparentGradientSmall('SIGN UP', context),
            //     ),
            //   ],
            // )
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:deliver_client/utils/colors.dart';
// import 'package:deliver_client/widgets/buttons.dart';
// import 'package:deliver_client/widgets/onboarding_list.dart';
// import 'package:deliver_client/screens/login/login_screen.dart';
//
// class OnBoardingScreen extends StatefulWidget {
//   const OnBoardingScreen({super.key});
//
//   @override
//   State<OnBoardingScreen> createState() => _OnBoardingScreenState();
// }
//
// class _OnBoardingScreenState extends State<OnBoardingScreen> {
//   @override
//   Widget build(BuildContext context) {
//     var size = MediaQuery.of(context).size;
//     return Scaffold(
//       backgroundColor: whiteColor,
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             SizedBox(height: size.height * 0.04),
//             Container(
//               color: whiteColor,
//               width: size.width,
//               height: size.height * 0.8,
//               child: onBoardingList(context),
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 GestureDetector(
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const LoginScreen(),
//                       ),
//                     );
//                   },
//                   child: buttonGradientSmall('SIGN IN', context),
//                 ),
//                 GestureDetector(
//                     onTap: () {
//                       // Navigator.push(
//                       //   context,
//                       //   MaterialPageRoute(
//                       //     builder: (context) => const SignUpScreen(),
//                       //   ),
//                       // );
//                     },
//                     child: buttonTransparentGradientSmall('SIGN UP', context)),
//               ],
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
