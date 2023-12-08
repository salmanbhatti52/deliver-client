// // ignore_for_file: avoid_print, use_build_context_synchronously

// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:deliver_client/utils/colors.dart';
// import 'package:deliver_client/utils/baseurl.dart';
// import 'package:deliver_client/widgets/buttons.dart';
// import 'package:deliver_client/models/forgot_password_model.dart';
// import 'package:flutter_pin_code_fields/flutter_pin_code_fields.dart';
// import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
// import 'package:deliver_client/screens/login/create_new_password_screen.dart';
// import 'package:deliver_client/models/forgort_password_verify_otp_model.dart';

// class VerifyOTPPasswordScreen extends StatefulWidget {
//   final String? email;
//   const VerifyOTPPasswordScreen({super.key, this.email});

//   @override
//   State<VerifyOTPPasswordScreen> createState() =>
//       _VerifyOTPPasswordScreenState();
// }

// class _VerifyOTPPasswordScreenState extends State<VerifyOTPPasswordScreen> {
//   TextEditingController otpController = TextEditingController();
//   final GlobalKey<FormState> otpNewPasswordFormKey = GlobalKey<FormState>();
//   bool isLoading = false;

//   ForgotPasswordModel forgotPasswordModel = ForgotPasswordModel();

//   resendOTP() async {
//     try {
//       String apiUrl = "$baseUrl/forgot_password_customers";
//       print("apiUrl: $apiUrl");
//       print("email: ${widget.email}");
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {
//           'Accept': 'application/json',
//         },
//         body: {
//           "email": widget.email,
//         },
//       );
//       final responseString = jsonDecode(response.body);
//       print("response: $responseString");
//       print("status: ${responseString['status']}");
//       if (responseString["status"] == "success") {
//         forgotPasswordModel = forgotPasswordModelFromJson(response.body);
//         final snackBar = SnackBar(
//           elevation: 0,
//           behavior: SnackBarBehavior.floating,
//           dismissDirection: DismissDirection.horizontal,
//           backgroundColor: transparentColor,
//           content: AwesomeSnackbarContent(
//             title: 'Hi There!',
//             message: "${forgotPasswordModel.message}",
//             contentType: ContentType.help,
//           ),
//         );
//         ScaffoldMessenger.of(context)
//           ..hideCurrentSnackBar()
//           ..showSnackBar(snackBar);
//         setState(() {
//           isLoading = false;
//         });
//       } else if (responseString["status"] == "error") {
//         final snackBar = SnackBar(
//           elevation: 0,
//           behavior: SnackBarBehavior.floating,
//           dismissDirection: DismissDirection.horizontal,
//           backgroundColor: transparentColor,
//           content: AwesomeSnackbarContent(
//             title: 'Oh Snap!',
//             message: "${responseString["message"]}",
//             contentType: ContentType.failure,
//           ),
//         );
//         ScaffoldMessenger.of(context)
//           ..hideCurrentSnackBar()
//           ..showSnackBar(snackBar);
//         setState(() {
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       print('Something went wrong = ${e.toString()}');
//       return null;
//     }
//   }

//   ForgotPasswordVerifyOtpModel verifyOtpModel = ForgotPasswordVerifyOtpModel();

//   verifyOTP() async {
//     try {
//       String apiUrl = "$baseUrl/verify_forgot_password_otp_customers";
//       print("apiUrl: $apiUrl");
//       print("email: ${widget.email}");
//       print("otp: ${otpController.text}");
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
//       print("response: $responseString");
//       print("statusCode: ${response.statusCode}");
//       if (response.statusCode == 200) {
//         verifyOtpModel = forgotPasswordVerifyOtpModelFromJson(responseString);
//         setState(() {});
//         print('forgotPasswordVerifyOtpModel status: ${verifyOtpModel.status}');
//       }
//     } catch (e) {
//       print('Something went wrong = ${e.toString()}');
//       return null;
//     }
//   }

//   Timer? timer;
//   int secondsRemaining = 120; // Total seconds for the timer (2 minutes)

//   void startTimer() {
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
//     print("initState Email: ${widget.email}");
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
//         ),
//         body: SingleChildScrollView(
//           child: Column(
//             children: [
//               SizedBox(height: size.height * 0.08),
//               Center(
//                 child: Image.asset(
//                     'assets/images/logo-big-icon.png',
//                     width: 300,
//                     height: 125,
//                   ),
//               ),
//               SizedBox(height: size.height * 0.06),
//               Text(
//                 "Forgot\nPassword?".toUpperCase(),
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   color: orangeColor,
//                   fontSize: 30,
//                   fontFamily: 'Syne-SemiBold',
//                 ),
//               ),
//               SizedBox(height: size.height * 0.01),
//               Text(
//                 "Enter 4 digit code received on\narsl**********@gmail.com",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   color: blackColor,
//                   fontSize: 16,
//                   fontFamily: 'Syne-Regular',
//                 ),
//               ),
//               SizedBox(height: size.height * 0.02),
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
//                     // print(output);
//                   },
//                 ),
//               ),
//               SizedBox(height: size.height * 0.02),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 80),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
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
//                             'assets/images/clock-inactive-icon.svg')
//                         : SvgPicture.asset(
//                             'assets/images/clock-active-icon.svg'),
//                     SizedBox(width: size.width * 0.02),
//                     secondsRemaining == 0
//                         ? GestureDetector(
//                             onTap: () async {
//                               secondsRemaining = 120;
//                               startTimer();
//                               await resendOTP();
//                               setState(() {
//                                 isLoading = false;
//                               });
//                             },
//                             child: Text(
//                               'Resend',
//                               textAlign: TextAlign.left,
//                               style: TextStyle(
//                                 color: orangeColor,
//                                 fontSize: 16,
//                                 fontFamily: 'Inter-SemiBold',
//                               ),
//                             ),
//                           )
//                         : Container(
//                             width: size.width * 0.2,
//                             color: transparentColor,
//                             child: Text(
//                               getTimerText(),
//                               textAlign: TextAlign.left,
//                               style: TextStyle(
//                                 color: blackColor,
//                                 fontSize: 16,
//                                 fontFamily: 'Inter-SemiBold',
//                               ),
//                             ),
//                           ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: size.height * 0.045),
//               GestureDetector(
//                 onTap: () async {
//                   setState(() {
//                     isLoading = true;
//                   });
//                   await verifyOTP();
//                   if (verifyOtpModel.status == 'success') {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => CreateNewPasswordScreen(
//                           email: widget.email,
//                           otp: otpController.text,
//                         ),
//                       ),
//                     );
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
