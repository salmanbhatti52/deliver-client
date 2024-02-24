// // ignore_for_file: use_build_context_synchronously

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:deliver_client/utils/colors.dart';
// import 'package:deliver_client/utils/baseurl.dart';
// import 'package:deliver_client/widgets/buttons.dart';
// import 'package:deliver_client/models/send_otp_model.dart';
// import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
// import 'package:deliver_client/screens/signup/verify_email_signup_screen.dart';
// import 'package:deliver_client/screens/signup/verify_phone_signup_screen.dart';

// class VerifyScreen extends StatefulWidget {
//   final String? email;
//   final String? phoneNumber;
//   const VerifyScreen({super.key, this.email, this.phoneNumber});

//   // static String verify = "";

//   @override
//   State<VerifyScreen> createState() => _VerifyScreenState();
// }

// class _VerifyScreenState extends State<VerifyScreen> {
//   bool isLoading = false;

//   SendOtpModel sendOtpModel = SendOtpModel();

//   sendOtp() async {
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
//       }
//     } catch (e) {
//       debugPrint('Something went wrong = ${e.toString()}');
//       return null;
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     debugPrint("initState Email: ${widget.email}");
//     debugPrint("initState PhoneNumber: ${widget.phoneNumber}");
//   }

//   @override
//   Widget build(BuildContext context) {
//     var size = MediaQuery.of(context).size;
//     return Scaffold(
//       backgroundColor: bgColor,
//       appBar: AppBar(
//         backgroundColor: bgColor,
//         elevation: 0,
//         scrolledUnderElevation: 0,
//         leading: GestureDetector(
//           onTap: () {
//             Navigator.pop(context);
//           },
//           child: Padding(
//             padding: const EdgeInsets.only(left: 20),
//             child: SvgPicture.asset(
//               'assets/images/back-icon.svg',
//               width: 22,
//               height: 22,
//               fit: BoxFit.scaleDown,
//             ),
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             SizedBox(height: size.height * 0.06),
//             Center(
//               child: SvgPicture.asset(
//                 'assets/images/verify-icon.svg',
//               ),
//             ),
//             SizedBox(height: size.height * 0.04),
//             Text(
//               "Verify Yourself",
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: blackColor,
//                 fontSize: 20,
//                 fontFamily: 'Syne-Bold',
//               ),
//             ),
//             SizedBox(height: size.height * 0.06),
//             Text(
//               "Verify your identity using email or\nphone number.",
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: blackColor,
//                 fontSize: 16,
//                 fontFamily: 'Inter-Regular',
//               ),
//             ),
//             SizedBox(height: size.height * 0.06),
//             GestureDetector(
//               onTap: () async {
//                 setState(() {
//                   isLoading = true;
//                 });
//                 await sendOtp();
//                 if (sendOtpModel.status == 'success') {
//                   final snackBar = SnackBar(
//                     elevation: 0,
//                     behavior: SnackBarBehavior.floating,
//                     dismissDirection: DismissDirection.horizontal,
//                     backgroundColor: transparentColor,
//                     content: AwesomeSnackbarContent(
//                       title: 'Hi There!',
//                       message: "${sendOtpModel.message}",
//                       contentType: ContentType.help,
//                     ),
//                   );
//                   ScaffoldMessenger.of(context)
//                     ..hideCurrentSnackBar()
//                     ..showSnackBar(snackBar);
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => VerifyEmailSignUpScreen(
//                         email: widget.email,
//                       ),
//                     ),
//                   );
//                   setState(() {
//                     isLoading = false;
//                   });
//                 }
//                 if (sendOtpModel.status != 'success') {
//                   final snackBar = SnackBar(
//                     elevation: 0,
//                     behavior: SnackBarBehavior.floating,
//                     dismissDirection: DismissDirection.horizontal,
//                     backgroundColor: transparentColor,
//                     content: AwesomeSnackbarContent(
//                       title: 'Oh Snap!',
//                       message: "${sendOtpModel.message}",
//                       contentType: ContentType.failure,
//                     ),
//                   );
//                   ScaffoldMessenger.of(context)
//                     ..hideCurrentSnackBar()
//                     ..showSnackBar(snackBar);
//                   setState(() {
//                     isLoading = false;
//                   });
//                 }
//               },
//               child: isLoading
//                   ? buttonGradientWithLoader("Please Wait...", context)
//                   : buttonGradient("VERIFY EMAIL", context),
//             ),
//             SizedBox(height: size.height * 0.02),
//             GestureDetector(
//               onTap: () async {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => VerifyPhoneSignUpScreen(
//                           phoneNumber: widget.phoneNumber,
//                         ),
//                       ),
//                 );
//               },
//               child: buttonTransparentGradient("VERIFY PHONE NUMBER", context),
//             ),
//             SizedBox(height: size.height * 0.02),
//           ],
//         ),
//       ),
//     );
//   }
// }
