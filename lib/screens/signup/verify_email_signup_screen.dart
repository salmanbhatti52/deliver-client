// // ignore_for_file: avoid_print, use_build_context_synchronously

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:deliver_client/utils/colors.dart';
// import 'package:deliver_client/utils/baseurl.dart';
// import 'package:deliver_client/widgets/buttons.dart';
// import 'package:deliver_client/models/send_otp_model.dart';
// import 'package:deliver_client/models/verify_otp_model.dart';
// import 'package:deliver_client/screens/login/login_screen.dart';
// import 'package:flutter_pin_code_fields/flutter_pin_code_fields.dart';
// import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

// class VerifyEmailSignUpScreen extends StatefulWidget {
//   final String? email;
//   const VerifyEmailSignUpScreen({super.key, this.email});

//   @override
//   State<VerifyEmailSignUpScreen> createState() =>
//       _VerifyEmailSignUpScreenState();
// }

// class _VerifyEmailSignUpScreenState extends State<VerifyEmailSignUpScreen> {
//   TextEditingController otpController = TextEditingController();
//   bool isLoading = false;

//   SendOtpModel sendOtpModel = SendOtpModel();

//   resendOTP() async {
//     try {
//       String apiUrl = "$baseUrl/verify_email_customers";
//       debugPrint("apiUrl: $apiUrl");
//       debugPrint("email: ${widget.email}");
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {
//           'Accept': 'application/json',
//         },
//         body: {
//           "email": widget.email,
//         },
//       );
//       final responseString = response.body;
//       debugPrint("response: $responseString");
//       debugPrint("statusCode: ${response.statusCode}");
//       if (response.statusCode == 200) {
//         sendOtpModel = sendOtpModelFromJson(responseString);
//         setState(() {});
//         debugPrint('sendOtpModel status: ${sendOtpModel.status}');
//         debugPrint('OTP Resent!');
//       }
//     } catch (e) {
//       debugPrint('Something went wrong = ${e.toString()}');
//       return null;
//     }
//   }

//   VerifyOtpModel verifyOtpModel = VerifyOtpModel();

//   verifyOTP() async {
//     try {
//       String apiUrl = "$baseUrl/verify_email_otp_customers";
//       debugPrint("apiUrl: $apiUrl");
//       debugPrint("email: ${widget.email}");
//       debugPrint("otp: ${otpController.text}");
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {
//           'Accept': 'application/json',
//         },
//         body: {
//           "email": widget.email,
//           "otp": otpController.text,
//         },
//       );
//       final responseString = response.body;
//       debugPrint("response: $responseString");
//       debugPrint("statusCode: ${response.statusCode}");
//       if (response.statusCode == 200) {
//         verifyOtpModel = verifyOtpModelFromJson(responseString);
//         setState(() {});
//         debugPrint('verifyOtpModel status: ${verifyOtpModel.status}');
//       }
//     } catch (e) {
//       debugPrint('Something went wrong = ${e.toString()}');
//       return null;
//     }
//   }

//   Timer? timer;
//   int secondsRemaining = 120; // Total seconds for the timer (2 minutes)

//   startTimer() {
//     timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       setState(() {
//         if (secondsRemaining > 0) {
//           secondsRemaining--;
//         } else {
//           timer.cancel();
//         }
//       });
//     });
//   }

//   String getTimerText() {
//     int minutes = secondsRemaining ~/ 60;
//     int seconds = secondsRemaining % 60;
//     return '${minutes}m:${seconds.toString().padLeft(2, '0')}s';
//   }

//   @override
//   void initState() {
//     super.initState();
//     startTimer();
//     debugPrint("initState Email: ${widget.email}");
//   }

//   @override
//   void dispose() {
//     timer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     var size = MediaQuery.of(context).size;
//     return GestureDetector(
//       onTap: () {
//         FocusManager.instance.primaryFocus?.unfocus();
//       },
//       child: Scaffold(
//         backgroundColor: bgColor,
//         appBar: AppBar(
//           backgroundColor: bgColor,
//           elevation: 0,
//           scrolledUnderElevation: 0,
//           leading: GestureDetector(
//             onTap: () {
//               Navigator.pop(context);
//               timer?.cancel();
//             },
//             child: Padding(
//               padding: const EdgeInsets.only(left: 20),
//               child: SvgPicture.asset(
//                 'assets/images/back-icon.svg',
//                 width: 22,
//                 height: 22,
//                 fit: BoxFit.scaleDown,
//               ),
//             ),
//           ),
//           title: Padding(
//             padding: const EdgeInsets.only(left: 20),
//             child: Text(
//               "Email Verification",
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: blackColor,
//                 fontSize: 20,
//                 fontFamily: 'Syne-Bold',
//               ),
//             ),
//           ),
//           centerTitle: true,
//         ),
//         body: SingleChildScrollView(
//           child: Column(
//             children: [
//               SizedBox(height: size.height * 0.04),
//               Center(
//                 child: SvgPicture.asset(
//                   'assets/images/email-verification-icon.svg',
//                 ),
//               ),
//               SizedBox(height: size.height * 0.04),
//               Text(
//                 "Please enter the verification code sent to\nyour email address below, check your \nspam folder if you do not receive it in your\ninbox.",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   color: blackColor,
//                   fontSize: 16,
//                   fontFamily: 'Syne-Regular',
//                 ),
//               ),
//               SizedBox(height: size.height * 0.05),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 20),
//                 child: Text(
//                   "Enter Code",
//                   textAlign: TextAlign.left,
//                   style: TextStyle(
//                     color: blackColor,
//                     fontSize: 16,
//                     fontFamily: 'Syne-SemiBold',
//                   ),
//                 ),
//               ),
//               SizedBox(height: size.height * 0.01),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 20),
//                 child: PinCodeFields(
//                   controller: otpController,
//                   length: 4,
//                   fieldBorderStyle: FieldBorderStyle.square,
//                   responsive: false,
//                   animation: Animations.rotateRight,
//                   animationDuration: const Duration(milliseconds: 250),
//                   animationCurve: Curves.bounceInOut,
//                   switchInAnimationCurve: Curves.bounceIn,
//                   switchOutAnimationCurve: Curves.bounceOut,
//                   fieldHeight: 48,
//                   fieldWidth: 60,
//                   borderWidth: 1,
//                   activeBorderColor: orangeColor,
//                   activeBackgroundColor: filledColor,
//                   borderRadius: BorderRadius.circular(10),
//                   keyboardType: TextInputType.number,
//                   inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//                   autoHideKeyboard: false,
//                   fieldBackgroundColor: filledColor,
//                   borderColor: transparentColor,
//                   textStyle: TextStyle(
//                     color: blackColor,
//                     fontSize: 14,
//                     fontFamily: 'Inter-Regular',
//                   ),
//                   onComplete: (output) {
//                     // Your logic with pin code
//                     // debugPrint(output);
//                   },
//                 ),
//               ),
//               SizedBox(height: size.height * 0.04),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 20),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     SizedBox(width: size.width * 0.02),
//                     Text(
//                       "OTP valid for",
//                       textAlign: TextAlign.left,
//                       style: TextStyle(
//                         color: blackColor,
//                         fontSize: 14,
//                         fontFamily: 'Syne-Regular',
//                       ),
//                     ),
//                     SizedBox(width: size.width * 0.02),
//                     secondsRemaining == 0
//                         ? SvgPicture.asset(
//                             'assets/images/clock-inactive-icon.svg',
//                           )
//                         : SvgPicture.asset(
//                             'assets/images/clock-active-icon.svg',
//                           ),
//                     SizedBox(width: size.width * 0.02),
//                     Container(
//                       width: size.width * 0.2,
//                       color: transparentColor,
//                       child: Text(
//                         getTimerText(),
//                         textAlign: TextAlign.left,
//                         style: TextStyle(
//                           color: blackColor,
//                           fontSize: 16,
//                           fontFamily: 'Inter-SemiBold',
//                         ),
//                       ),
//                     ),
//                     SizedBox(width: size.width * 0.02),
//                   ],
//                 ),
//               ),
//               SizedBox(height: size.height * 0.04),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 20),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       "Don't Receive the Code? ",
//                       textAlign: TextAlign.left,
//                       style: TextStyle(
//                         color: blackColor,
//                         fontSize: 14,
//                         fontFamily: 'Syne-Regular',
//                       ),
//                     ),
//                     secondsRemaining == 0
//                         ? GestureDetector(
//                             onTap: () async {
//                               secondsRemaining = 120;
//                               startTimer();
//                               await resendOTP();
//                               if (sendOtpModel.status == 'success') {
//                                 final snackBar = SnackBar(
//                                   elevation: 0,
//                                   behavior: SnackBarBehavior.floating,
//                                   dismissDirection: DismissDirection.horizontal,
//                                   backgroundColor: transparentColor,
//                                   content: AwesomeSnackbarContent(
//                                     title: 'Hi There!',
//                                     message: "${sendOtpModel.message}",
//                                     contentType: ContentType.help,
//                                   ),
//                                 );
//                                 ScaffoldMessenger.of(context)
//                                   ..hideCurrentSnackBar()
//                                   ..showSnackBar(snackBar);
//                               }
//                               if (sendOtpModel.status != 'success') {
//                                 final snackBar = SnackBar(
//                                   elevation: 0,
//                                   behavior: SnackBarBehavior.floating,
//                                   dismissDirection: DismissDirection.horizontal,
//                                   backgroundColor: transparentColor,
//                                   content: AwesomeSnackbarContent(
//                                     title: 'Oh Snap!',
//                                     message: "${sendOtpModel.message}",
//                                     contentType: ContentType.failure,
//                                   ),
//                                 );
//                                 ScaffoldMessenger.of(context)
//                                   ..hideCurrentSnackBar()
//                                   ..showSnackBar(snackBar);
//                               }
//                               setState(() {});
//                             },
//                             child: Text(
//                               'Resend Code',
//                               textAlign: TextAlign.left,
//                               style: TextStyle(
//                                 color: orangeColor,
//                                 fontSize: 16,
//                                 fontFamily: 'Syne-SemiBold',
//                               ),
//                             ),
//                           )
//                         : Text(
//                             'Resend Code',
//                             textAlign: TextAlign.left,
//                             style: TextStyle(
//                               color: supportTextColor,
//                               fontSize: 16,
//                               fontFamily: 'Syne-SemiBold',
//                             ),
//                           ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: size.height * 0.03),
//               GestureDetector(
//                 onTap: () async {
//                   setState(() {
//                     isLoading = true;
//                   });
//                   await verifyOTP();
//                   if (verifyOtpModel.status == 'success') {
//                     final snackBar = SnackBar(
//                       elevation: 0,
//                       behavior: SnackBarBehavior.floating,
//                       dismissDirection: DismissDirection.horizontal,
//                       backgroundColor: transparentColor,
//                       content: AwesomeSnackbarContent(
//                         title: 'Hi There!',
//                         message: "${verifyOtpModel.message}",
//                         contentType: ContentType.success,
//                       ),
//                     );
//                     ScaffoldMessenger.of(context)
//                       ..hideCurrentSnackBar()
//                       ..showSnackBar(snackBar);
//                     Navigator.of(context).pushAndRemoveUntil(
//                         MaterialPageRoute(
//                           builder: (context) => const LoginScreen(),
//                         ),
//                         (Route<dynamic> route) => false);
//                     timer?.cancel();
//                     setState(() {
//                       isLoading = false;
//                     });
//                   }
//                   if (verifyOtpModel.status != 'success') {
//                     final snackBar = SnackBar(
//                       elevation: 0,
//                       behavior: SnackBarBehavior.floating,
//                       dismissDirection: DismissDirection.horizontal,
//                       backgroundColor: transparentColor,
//                       content: AwesomeSnackbarContent(
//                         title: 'Oh Snap!',
//                         message: "${verifyOtpModel.message}",
//                         contentType: ContentType.failure,
//                       ),
//                     );
//                     ScaffoldMessenger.of(context)
//                       ..hideCurrentSnackBar()
//                       ..showSnackBar(snackBar);
//                     setState(() {
//                       isLoading = false;
//                     });
//                   }
//                 },
//                 child: isLoading
//                     ? buttonGradientWithLoader("Please Wait...", context)
//                     : buttonGradient("Next", context),
//               ),
//               SizedBox(height: size.height * 0.02),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
